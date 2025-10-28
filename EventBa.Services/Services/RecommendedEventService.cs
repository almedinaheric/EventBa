using AutoMapper;
using EventBa.Model.Responses;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;

namespace EventBa.Services.Services;

public class RecommendedEventService : IRecommendedEventService
{
    private readonly EventBaDbContext _context;
    private readonly IMapper _mapper;
    static MLContext? _mlContext = null;
    static readonly object isLocked = new object();
    static ITransformer? modeltr = null;

    public RecommendedEventService(EventBaDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public void TrainModel()
    {
        lock (isLocked)
        {
            if (_mlContext == null)
            {
                _mlContext = new MLContext();
                var data = new List<EventEntry>();

                // Get co-occurrences from favorite events
                var favoriteCoOccurrences = _context.Users
                    .Include(u => u.FavoriteEvents)
                    .ToList()
                    .Where(u => u.FavoriteEvents.Count > 1);

                foreach (var user in favoriteCoOccurrences)
                {
                    foreach (var event1 in user.FavoriteEvents)
                    {
                        var relatedEvents = user.FavoriteEvents.Where(e => e.Id != event1.Id);
                        foreach (var event2 in relatedEvents)
                        {
                            data.Add(new EventEntry
                            {
                                EventID = (uint)Math.Abs(event1.Id.GetHashCode()),
                                CoEventID = (uint)Math.Abs(event2.Id.GetHashCode())
                            });
                        }
                    }
                }

                // Get co-occurrences from ticket purchases (attended events)
                var purchaseCoOccurrences = _context.Users
                    .Include(u => u.TicketPurchases)
                    .ThenInclude(tp => tp.Event)
                    .ToList()
                    .Where(u => u.TicketPurchases.Count > 1);

                foreach (var user in purchaseCoOccurrences)
                {
                    var userEvents = user.TicketPurchases.Select(tp => tp.Event).ToList();
                    foreach (var event1 in userEvents)
                    {
                        var relatedEvents = userEvents.Where(e => e.Id != event1.Id);
                        foreach (var event2 in relatedEvents)
                        {
                            data.Add(new EventEntry
                            {
                                EventID = (uint)Math.Abs(event1.Id.GetHashCode()),
                                CoEventID = (uint)Math.Abs(event2.Id.GetHashCode())
                            });
                        }
                    }
                }

                // Add category-based co-occurrences (events in same category)
                var eventsByCategory = _context.Events
                    .Include(e => e.Category)
                    .Where(e => e.IsPublished)
                    .ToList()
                    .GroupBy(e => e.CategoryId);

                foreach (var categoryGroup in eventsByCategory)
                {
                    var eventsInCategory = categoryGroup.ToList();
                    if (eventsInCategory.Count > 1)
                    {
                        foreach (var event1 in eventsInCategory)
                        {
                            var relatedEvents = eventsInCategory.Where(e => e.Id != event1.Id).Take(5);
                            foreach (var event2 in relatedEvents)
                            {
                                data.Add(new EventEntry
                                {
                                    EventID = (uint)Math.Abs(event1.Id.GetHashCode()),
                                    CoEventID = (uint)Math.Abs(event2.Id.GetHashCode())
                                });
                            }
                        }
                    }
                }

                if (data.Count == 0)
                {
                    // If no training data, skip training
                    return;
                }

                var trainData = _mlContext.Data.LoadFromEnumerable(data);
                MatrixFactorizationTrainer.Options options = new MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(EventEntry.EventID),
                    MatrixRowIndexColumnName = nameof(EventEntry.CoEventID),
                    LabelColumnName = "Label",
                    LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01,
                    Lambda = 0.025,
                    NumberOfIterations = 100,
                    C = 0.00001
                };

                var est = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                modeltr = est.Fit(trainData);
            }
        }
    }

    public async Task<List<EventResponseDto>> GetRecommendedEventsForUser(Guid userId)
    {
        var user = await _context.Users
            .Include(u => u.Categories)
            .Include(u => u.FavoriteEvents)
            .Include(u => u.TicketPurchases)
            .ThenInclude(tp => tp.Event)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
            return new List<EventResponseDto>();

        // Check if we have cached recommendations
        var cachedRecommendations = await _context.RecommendedEvents
            .Where(re => re.UserId == userId)
            .Include(re => re.Event)
            .ThenInclude(e => e.Category)
            .Include(re => re.Event)
            .ThenInclude(e => e.EventGalleryImages)
            .Include(re => re.Event)
            .ThenInclude(e => e.Tickets)
            .ToListAsync();

        if (cachedRecommendations.Any())
        {
            var cachedEvents = cachedRecommendations
                .Where(re => re.Event.IsPublished)
                .Select(re => re.Event)
                .ToList();
            return _mapper.Map<List<EventResponseDto>>(cachedEvents);
        }

        // Generate new recommendations
        var recommendedEvents = new List<Event>();

        // 1. Content-based filtering: Get events from user's interest categories
        if (user.Categories.Any())
        {
            var categoryIds = user.Categories.Select(c => c.Id).ToList();
            var categoryBasedEvents = await _context.Events
                .Include(e => e.Category)
                .Include(e => e.EventGalleryImages)
                .Include(e => e.Tickets)
                .Where(e => e.IsPublished &&
                           categoryIds.Contains(e.CategoryId) &&
                           !user.FavoriteEvents.Any(fe => fe.Id == e.Id))
                .Take(10)
                .ToListAsync();

            recommendedEvents.AddRange(categoryBasedEvents);
        }

        // 2. Collaborative filtering using ML (if model is trained)
        if (modeltr != null && _mlContext != null)
        {
            var userInteractedEvents = user.FavoriteEvents
                .Concat(user.TicketPurchases.Select(tp => tp.Event))
                .DistinctBy(e => e.Id)
                .ToList();

            if (userInteractedEvents.Any())
            {
                var allEvents = await _context.Events
                    .Include(e => e.Category)
                    .Include(e => e.EventGalleryImages)
                    .Include(e => e.Tickets)
                    .Where(e => e.IsPublished &&
                               !user.FavoriteEvents.Any(fe => fe.Id == e.Id) &&
                               !user.TicketPurchases.Any(tp => tp.EventId == e.Id))
                    .ToListAsync();

                var predictionResults = new List<Tuple<Event, float>>();

                foreach (var interactedEvent in userInteractedEvents.Take(3))
                {
                    foreach (var candidateEvent in allEvents)
                    {
                        try
                        {
                            var predictionEngine = _mlContext.Model.CreatePredictionEngine<EventEntry, CoEventPrediction>(modeltr);
                            var prediction = predictionEngine.Predict(new EventEntry
                            {
                                EventID = (uint)Math.Abs(interactedEvent.Id.GetHashCode()),
                                CoEventID = (uint)Math.Abs(candidateEvent.Id.GetHashCode())
                            });

                            var existing = predictionResults.FirstOrDefault(pr => pr.Item1.Id == candidateEvent.Id);
                            if (existing != null)
                            {
                                predictionResults.Remove(existing);
                                predictionResults.Add(new Tuple<Event, float>(candidateEvent, existing.Item2 + prediction.Score));
                            }
                            else
                            {
                                predictionResults.Add(new Tuple<Event, float>(candidateEvent, prediction.Score));
                            }
                        }
                        catch
                        {
                            // Skip if prediction fails
                            continue;
                        }
                    }
                }

                var mlRecommendedEvents = predictionResults
                    .OrderByDescending(x => x.Item2)
                    .Take(10)
                    .Select(x => x.Item1)
                    .ToList();

                recommendedEvents.AddRange(mlRecommendedEvents);
            }
        }

        // 3. If still no recommendations, get popular events from user's interest categories
        if (!recommendedEvents.Any() && user.Categories.Any())
        {
            var categoryIds = user.Categories.Select(c => c.Id).ToList();
            var popularEvents = await _context.Events
                .Include(e => e.Category)
                .Include(e => e.EventGalleryImages)
                .Include(e => e.EventStatistics)
                .Include(e => e.Tickets)
                .Where(e => e.IsPublished && categoryIds.Contains(e.CategoryId))
                .OrderByDescending(e => e.EventStatistics.Sum(es => es.TotalFavorites))
                .Take(10)
                .ToListAsync();

            recommendedEvents.AddRange(popularEvents);
        }

        // 4. If still no recommendations, get featured events
        if (!recommendedEvents.Any())
        {
            var featuredEvents = await _context.Events
                .Include(e => e.Category)
                .Include(e => e.EventGalleryImages)
                .Include(e => e.Tickets)
                .Where(e => e.IsPublished && e.IsFeatured)
                .Take(10)
                .ToListAsync();

            recommendedEvents.AddRange(featuredEvents);
        }

        // Remove duplicates and take final set
        var finalRecommendations = recommendedEvents
            .DistinctBy(e => e.Id)
            .Take(10)
            .ToList();

        // Cache recommendations
        foreach (var recommendedEvent in finalRecommendations)
        {
            var existingRecommendation = await _context.RecommendedEvents
                .FirstOrDefaultAsync(re => re.UserId == userId && re.EventId == recommendedEvent.Id);

            if (existingRecommendation == null)
            {
                _context.RecommendedEvents.Add(new RecommendedEvent
                {
                    UserId = userId,
                    EventId = recommendedEvent.Id,
                    CreatedAt = DateTime.UtcNow
                });
            }
        }

        await _context.SaveChangesAsync();

        return _mapper.Map<List<EventResponseDto>>(finalRecommendations);
    }

    public async Task DeleteAllRecommendations()
    {
        await _context.RecommendedEvents.ExecuteDeleteAsync();
    }

    public class EventEntry
    {
        [KeyType(count: 10000)]
        public uint EventID { get; set; }

        [KeyType(count: 10000)]
        public uint CoEventID { get; set; }

        public float Label { get; set; }
    }

    public class CoEventPrediction
    {
        public float Score { get; set; }
    }
}

