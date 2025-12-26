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
    static Dictionary<uint, uint>? _eventIdToIndexMap = null;
    static Dictionary<uint, uint>? _indexToEventIdMap = null;

    public RecommendedEventService(EventBaDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public void TrainModel()
    {
        lock (isLocked)
        {
            try
            {
                if (_mlContext == null || modeltr == null)
                {
                    if (_mlContext == null)
                    {
                        _mlContext = new MLContext();
                    }

                    var data = new List<EventEntry>();

                    try
                    {
                        var favoriteCoOccurrences = _context.Users
                            .Include(u => u.FavoriteEvents)
                            .ToList()
                            .Where(u => u.FavoriteEvents != null && u.FavoriteEvents.Count > 1);

                        foreach (var user in favoriteCoOccurrences)
                        {
                            if (user.FavoriteEvents == null) continue;
                            
                            foreach (var event1 in user.FavoriteEvents)
                            {
                                var relatedEvents = user.FavoriteEvents.Where(e => e != null && e.Id != event1.Id);
                                foreach (var event2 in relatedEvents)
                                {
                                    if (event2 == null) continue;
                                    
                                    var eventId1 = (uint)Math.Abs(event1.Id.GetHashCode());
                                    var eventId2 = (uint)Math.Abs(event2.Id.GetHashCode());
                                    
                                    if (eventId1 == 0) eventId1 = 1;
                                    if (eventId2 == 0) eventId2 = 1;
                                    if (eventId1 == eventId2) continue;
                                    
                                    data.Add(new EventEntry
                                    {
                                        EventID = eventId1,
                                        CoEventID = eventId2,
                                        Label = 1.0f
                                    });
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error processing favorite events: {ex.Message}");
                    }

                    try
                    {
                        var purchaseCoOccurrences = _context.Users
                            .Include(u => u.TicketPurchases)
                            .ThenInclude(tp => tp.Event)
                            .ToList()
                            .Where(u => u.TicketPurchases != null && u.TicketPurchases.Count > 1);

                        foreach (var user in purchaseCoOccurrences)
                        {
                            if (user.TicketPurchases == null) continue;
                            
                            var userEvents = user.TicketPurchases
                                .Where(tp => tp.Event != null)
                                .Select(tp => tp.Event!)
                                .DistinctBy(e => e.Id)
                                .ToList();
                            
                            foreach (var event1 in userEvents)
                            {
                                var relatedEvents = userEvents.Where(e => e != null && e.Id != event1.Id);
                                foreach (var event2 in relatedEvents)
                                {
                                    if (event2 == null) continue;
                                    
                                    var eventId1 = (uint)Math.Abs(event1.Id.GetHashCode());
                                    var eventId2 = (uint)Math.Abs(event2.Id.GetHashCode());
                                    
                                    if (eventId1 == 0) eventId1 = 1;
                                    if (eventId2 == 0) eventId2 = 1;
                                    if (eventId1 == eventId2) continue;
                                    
                                    data.Add(new EventEntry
                                    {
                                        EventID = eventId1,
                                        CoEventID = eventId2,
                                        Label = 1.0f
                                    });
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error processing ticket purchases: {ex.Message}");
                    }

                    try
                    {
                        var eventsByCategory = _context.Events
                            .Include(e => e.Category)
                            .Where(e => e.IsPublished && e.Category != null)
                            .ToList()
                            .GroupBy(e => e.CategoryId);

                        foreach (var categoryGroup in eventsByCategory)
                        {
                            var eventsInCategory = categoryGroup.Where(e => e != null).ToList();
                            if (eventsInCategory.Count > 1)
                            {
                                foreach (var event1 in eventsInCategory)
                                {
                                    var relatedEvents = eventsInCategory.Where(e => e != null && e.Id != event1.Id).Take(5);
                                    foreach (var event2 in relatedEvents)
                                    {
                                        if (event2 == null) continue;
                                        
                                        var eventId1 = (uint)Math.Abs(event1.Id.GetHashCode());
                                        var eventId2 = (uint)Math.Abs(event2.Id.GetHashCode());
                                        
                                        if (eventId1 == 0) eventId1 = 1;
                                        if (eventId2 == 0) eventId2 = 1;
                                        if (eventId1 == eventId2) continue;
                                        
                                        data.Add(new EventEntry
                                        {
                                            EventID = eventId1,
                                            CoEventID = eventId2,
                                            Label = 0.7f
                                        });
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error processing events by category: {ex.Message}");
                    }

                    try
                    {
                        var userInterests = _context.Users
                            .Include(u => u.Categories)
                            .ToList()
                            .Where(u => u.Categories != null && u.Categories.Any());

                        foreach (var user in userInterests)
                        {
                            if (user.Categories == null) continue;
                            
                            var userCategoryIds = user.Categories.Select(c => c.Id).ToList();
                            var eventsInUserCategories = _context.Events
                                .Where(e => e.IsPublished && e.Category != null && userCategoryIds.Contains(e.CategoryId))
                                .ToList();

                            if (eventsInUserCategories.Count > 1)
                            {
                                foreach (var event1 in eventsInUserCategories)
                                {
                                    var relatedEvents = eventsInUserCategories.Where(e => e != null && e.Id != event1.Id).Take(3);
                                    foreach (var event2 in relatedEvents)
                                    {
                                        if (event2 == null) continue;
                                        
                                        var eventId1 = (uint)Math.Abs(event1.Id.GetHashCode());
                                        var eventId2 = (uint)Math.Abs(event2.Id.GetHashCode());
                                        
                                        if (eventId1 == 0) eventId1 = 1;
                                        if (eventId2 == 0) eventId2 = 1;
                                        if (eventId1 == eventId2) continue;
                                        
                                        data.Add(new EventEntry
                                        {
                                            EventID = eventId1,
                                            CoEventID = eventId2,
                                            Label = 0.8f
                                        });
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error processing user interests: {ex.Message}");
                    }

                    var validData = data.Where(d => d.EventID > 0 && d.CoEventID > 0 && d.EventID != d.CoEventID).ToList();

                    if (validData.Count == 0)
                    {
                        Console.WriteLine("No valid training data available. Model training skipped.");
                        return;
                    }

                    if (validData.Count < 2)
                    {
                        Console.WriteLine($"Insufficient valid training data ({validData.Count} entries). Need at least 2 entries. Model training skipped.");
                        return;
                    }

                    var uniqueData = validData
                        .GroupBy(d => new { d.EventID, d.CoEventID })
                        .Select(g => g.First())
                        .ToList();

                    if (uniqueData.Count < 2)
                    {
                        Console.WriteLine($"Insufficient unique training data ({uniqueData.Count} entries). Need at least 2 unique pairs. Model training skipped.");
                        return;
                    }

                    var allEventIds = uniqueData
                        .Select(d => d.EventID)
                        .Concat(uniqueData.Select(d => d.CoEventID))
                        .Distinct()
                        .OrderBy(id => id)
                        .ToList();

                    var eventIdToIndex = new Dictionary<uint, uint>();
                    uint index = 1;
                    foreach (var eventId in allEventIds)
                    {
                        eventIdToIndex[eventId] = index++;
                    }

                    if (eventIdToIndex.Count > 10000)
                    {
                        Console.WriteLine($"Too many unique events ({eventIdToIndex.Count}). Maximum is 10000. Model training skipped.");
                        return;
                    }

                    var mappedData = uniqueData.Select(d => new EventEntry
                    {
                        EventID = eventIdToIndex[d.EventID],
                        CoEventID = eventIdToIndex[d.CoEventID],
                        Label = d.Label
                    }).ToList();

                    Console.WriteLine($"Training model with {mappedData.Count} valid training entries (from {data.Count} total entries).");
                    Console.WriteLine($"Using {eventIdToIndex.Count} unique events mapped to indices 1-{eventIdToIndex.Count}.");

                    _eventIdToIndexMap = eventIdToIndex;
                    _indexToEventIdMap = eventIdToIndex.ToDictionary(kvp => kvp.Value, kvp => kvp.Key);

                    var trainData = _mlContext.Data.LoadFromEnumerable(mappedData);
                    MatrixFactorizationTrainer.Options options = new MatrixFactorizationTrainer.Options
                    {
                        MatrixColumnIndexColumnName = nameof(EventEntry.EventID),
                        MatrixRowIndexColumnName = nameof(EventEntry.CoEventID),
                        LabelColumnName = nameof(EventEntry.Label),
                        LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                        Alpha = 0.01,
                        Lambda = 0.025,
                        NumberOfIterations = 100,
                        C = 0.00001
                    };

                    var est = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                    modeltr = est.Fit(trainData);
                    
                    Console.WriteLine($"Model trained successfully with {mappedData.Count} training entries.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error training recommendation model: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                throw;
            }
        }
    }

    public void RetrainModel()
    {
        lock (isLocked)
        {
            modeltr = null;
            _mlContext = null;
            _eventIdToIndexMap = null;
            _indexToEventIdMap = null;
            TrainModel();
        }
    }

    public async Task<List<EventResponseDto>> GetRecommendedEventsForUser(Guid userId)
    {
        try
        {
            Console.WriteLine($"Getting recommendations for user {userId}");
            var user = await _context.Users
            .Include(u => u.Categories)
            .Include(u => u.FavoriteEvents)
                .ThenInclude(e => e.Category)
            .Include(u => u.TicketPurchases)
                .ThenInclude(tp => tp.Event)
                    .ThenInclude(e => e.Category)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
            return new List<EventResponseDto>();

        var cachedRecommendations = await _context.RecommendedEvents
            .Where(re => re.UserId == userId)
            .Include(re => re.Event)
            .ThenInclude(e => e.Category)
            .Include(re => re.Event)
            .ThenInclude(e => e.CoverImage)
            .Include(re => re.Event)
            .ThenInclude(e => e.EventGalleryImages)
            .Include(re => re.Event)
            .ThenInclude(e => e.Tickets)
            .ToListAsync();

        if (cachedRecommendations.Any())
        {
            var cachedEvents = cachedRecommendations
                .Where(re => re.Event != null && re.Event.IsPublished)
                .Select(re => re.Event!)
                .ToList();
            
            if (cachedEvents.Any())
            {
                return _mapper.Map<List<EventResponseDto>>(cachedEvents);
            }
        }

        var recommendedEvents = new List<Event>();

        var favoriteEventIds = user.FavoriteEvents?.Select(fe => fe.Id).ToList() ?? new List<Guid>();
        var purchasedEventIds = user.TicketPurchases?.Select(tp => tp.EventId).ToList() ?? new List<Guid>();
        var excludedEventIds = favoriteEventIds.Concat(purchasedEventIds).Distinct().ToList();

        var userInterestCategoryIds = user.Categories?.Select(c => c.Id).ToList() ?? new List<Guid>();
        Console.WriteLine($"User {userId} has {userInterestCategoryIds.Count} interest categories: {string.Join(", ", userInterestCategoryIds)}");

        var favoriteEventCategories = user.FavoriteEvents?
            .Where(e => e != null && e.Category != null)
            .Select(e => e.CategoryId)
            .Distinct()
            .ToList() ?? new List<Guid>();
        Console.WriteLine($"User {userId} has favorited events in {favoriteEventCategories.Count} categories: {string.Join(", ", favoriteEventCategories)}");

        var attendedEventCategories = user.TicketPurchases?
            .Where(tp => tp != null && tp.Event != null && tp.Event.Category != null)
            .Select(tp => tp.Event!.CategoryId)
            .Distinct()
            .ToList() ?? new List<Guid>();
        Console.WriteLine($"User {userId} has attended events in {attendedEventCategories.Count} categories: {string.Join(", ", attendedEventCategories)}");

        var allRelevantCategoryIds = favoriteEventCategories
            .Concat(attendedEventCategories)
            .Concat(userInterestCategoryIds)
            .Distinct()
            .ToList();

        if (!allRelevantCategoryIds.Any())
        {
            Console.WriteLine($"User {userId} has no categories (interests, favorites, or attended) for recommendations");
            return new List<EventResponseDto>();
        }

        Console.WriteLine($"Total relevant categories for user {userId}: {allRelevantCategoryIds.Count}");

        var categoryBasedEvents = await _context.Events
            .Include(e => e.Category)
            .Include(e => e.CoverImage)
            .Include(e => e.EventGalleryImages)
            .Include(e => e.Tickets)
            .Where(e => e.IsPublished &&
                       e.OrganizerId != userId &&
                       allRelevantCategoryIds.Contains(e.CategoryId) &&
                       !excludedEventIds.Contains(e.Id))
            .ToListAsync();

        Console.WriteLine($"Found {categoryBasedEvents.Count} events in relevant categories for user {userId}");

        var userInteractedEvents = user.FavoriteEvents
            .Concat(user.TicketPurchases.Where(tp => tp.Event != null).Select(tp => tp.Event!))
            .Where(e => e != null)
            .DistinctBy(e => e.Id)
            .ToList();

        if (modeltr != null && _mlContext != null && _eventIdToIndexMap != null && categoryBasedEvents.Any())
        {
            Console.WriteLine($"Using ML to rank {categoryBasedEvents.Count} events for user {userId}");
            
            try
            {
                var predictionResults = new List<Tuple<Event, float>>();
                var seedEvents = new List<Event>();

                if (userInteractedEvents.Any())
                {
                    seedEvents = userInteractedEvents.Take(5).ToList();
                    Console.WriteLine($"Using {seedEvents.Count} user-interacted events as ML seeds");
                }
                else
                {
                    foreach (var categoryId in userInterestCategoryIds)
                    {
                        var popularEventsInCategory = await _context.Events
                            .Include(e => e.EventStatistics)
                            .Where(e => e.IsPublished && 
                                       e.CategoryId == categoryId && 
                                       e.OrganizerId != userId &&
                                       !excludedEventIds.Contains(e.Id))
                            .OrderByDescending(e => e.EventStatistics != null && e.EventStatistics.Any()
                                ? e.EventStatistics.Sum(es => es.TotalFavorites)
                                : 0)
                            .Take(2)
                            .ToListAsync();

                        seedEvents.AddRange(popularEventsInCategory);
                    }

                    seedEvents = seedEvents.DistinctBy(e => e.Id).Take(5).ToList();
                    Console.WriteLine($"New user - using {seedEvents.Count} popular events in interest categories as ML seeds");
                }

                if (!seedEvents.Any())
                {
                    Console.WriteLine($"No seed events available for ML - falling back to category-based");
                    recommendedEvents = categoryBasedEvents.Take(10).ToList();
                }
                else
                {
                    foreach (var candidateEvent in categoryBasedEvents)
                    {
                        float totalScore = 0f;
                        int predictionCount = 0;

                        foreach (var seedEvent in seedEvents)
                        {
                            try
                            {
                                var seedEventHash = (uint)Math.Abs(seedEvent.Id.GetHashCode());
                                var candidateEventHash = (uint)Math.Abs(candidateEvent.Id.GetHashCode());
                                
                                if (seedEventHash == 0) seedEventHash = 1;
                                if (candidateEventHash == 0) candidateEventHash = 1;
                                
                                if (!_eventIdToIndexMap.ContainsKey(seedEventHash) ||
                                    !_eventIdToIndexMap.ContainsKey(candidateEventHash))
                                {
                                    continue;
                                }
                                
                                var predictionEngine = _mlContext.Model.CreatePredictionEngine<EventEntry, CoEventPrediction>(modeltr);
                                var prediction = predictionEngine.Predict(new EventEntry
                                {
                                    EventID = _eventIdToIndexMap[seedEventHash],
                                    CoEventID = _eventIdToIndexMap[candidateEventHash]
                                });

                                totalScore += prediction.Score;
                                predictionCount++;
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine($"Error predicting for seed event {seedEvent.Id}: {ex.Message}");
                                continue;
                            }
                        }

                        if (predictionCount > 0)
                        {
                            var averageScore = totalScore / predictionCount;
                            
                            var isInFavoritesOrAttended = favoriteEventCategories.Contains(candidateEvent.CategoryId) || 
                                                          attendedEventCategories.Contains(candidateEvent.CategoryId);
                            var isInUserInterests = userInterestCategoryIds.Contains(candidateEvent.CategoryId);
                            
                            float finalScore;
                            if (isInFavoritesOrAttended)
                            {
                                finalScore = averageScore * 1.5f;
                            }
                            else if (isInUserInterests)
                            {
                                finalScore = averageScore * 1.2f;
                            }
                            else
                            {
                                finalScore = averageScore;
                            }
                            
                            predictionResults.Add(new Tuple<Event, float>(candidateEvent, finalScore));
                        }
                        else
                        {
                            var isInFavoritesOrAttended = favoriteEventCategories.Contains(candidateEvent.CategoryId) || 
                                                          attendedEventCategories.Contains(candidateEvent.CategoryId);
                            var isInUserInterests = userInterestCategoryIds.Contains(candidateEvent.CategoryId);
                            
                            float baseScore;
                            if (isInFavoritesOrAttended)
                            {
                                baseScore = 1.5f;
                            }
                            else if (isInUserInterests)
                            {
                                baseScore = 1.0f;
                            }
                            else
                            {
                                baseScore = 0.5f;
                            }
                            
                            predictionResults.Add(new Tuple<Event, float>(candidateEvent, baseScore));
                        }
                    }

                    recommendedEvents = predictionResults
                        .OrderByDescending(x => x.Item2)
                        .Take(10)
                        .Select(x => x.Item1)
                        .Where(e => e != null)
                        .ToList();

                    Console.WriteLine($"ML-ranked recommendations: {recommendedEvents.Count} events for user {userId}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in ML ranking for user {userId}: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                recommendedEvents = categoryBasedEvents.Take(10).ToList();
            }
        }
        else
        {
            Console.WriteLine($"ML not available - using pure category-based recommendations for user {userId}");
            recommendedEvents = categoryBasedEvents.Take(10).ToList();
        }

        var finalRecommendations = recommendedEvents
            .Where(e => e != null)
            .DistinctBy(e => e.Id)
            .Take(10)
            .ToList();

        Console.WriteLine($"Final recommendations for user {userId}: {finalRecommendations.Count} events");

        if (finalRecommendations.Any())
        {
            foreach (var recommendedEvent in finalRecommendations)
            {
                try
                {
                    var existingRecommendation = await _context.RecommendedEvents
                        .FirstOrDefaultAsync(re => re.UserId == userId && re.EventId == recommendedEvent.Id);

                    if (existingRecommendation == null)
                    {
                        var createdAt = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);
                        
                        _context.RecommendedEvents.Add(new RecommendedEvent
                        {
                            UserId = userId,
                            EventId = recommendedEvent.Id,
                            CreatedAt = createdAt
                        });
                        Console.WriteLine($"Added recommendation: User {userId} -> Event {recommendedEvent.Id} ({recommendedEvent.Title})");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error saving recommendation for event {recommendedEvent.Id}: {ex.Message}");
                    continue;
                }
            }

            try
            {
                var savedCount = await _context.SaveChangesAsync();
                Console.WriteLine($"Saved {savedCount} recommendations to database for user {userId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error saving recommendations to database: {ex.Message}");
            }
        }
        else
        {
            Console.WriteLine($"No recommendations generated for user {userId}");
        }

            return _mapper.Map<List<EventResponseDto>>(finalRecommendations);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error in GetRecommendedEventsForUser for user {userId}: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
            throw;
        }
    }

    public async Task DeleteAllRecommendations()
    {
        await _context.RecommendedEvents.ExecuteDeleteAsync();
    }

    public async Task DeleteRecommendationsForUser(Guid userId)
    {
        var userRecommendations = await _context.RecommendedEvents
            .Where(re => re.UserId == userId)
            .ToListAsync();
        
        if (userRecommendations.Any())
        {
            _context.RecommendedEvents.RemoveRange(userRecommendations);
            await _context.SaveChangesAsync();
            Console.WriteLine($"Deleted {userRecommendations.Count} cached recommendations for user {userId} - will regenerate on next fetch");
        }
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

