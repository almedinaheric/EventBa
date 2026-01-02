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
    private const int MaxEvents = 10_000;
    private const int MaxRecommendations = 10;
    private const int MaxSeedEvents = 5;
    private const float FavoritePurchaseWeight = 1.5f;
    private const float InterestWeight = 1.2f;
    private const float DefaultScore = 0.5f;

    private readonly EventBaDbContext _context;
    private readonly IMapper _mapper;

    private static readonly object _lock = new();
    private static MLContext? _ml;
    private static ITransformer? _model;
    private static Dictionary<uint, uint>? _eventToIndex;
    private static Dictionary<uint, uint>? _indexToEvent;

    public RecommendedEventService(EventBaDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public void TrainModel()
    {
        lock (_lock)
        {
            if (_ml != null && _model != null)
                return;

            _ml ??= new MLContext();

            var trainingData = CollectTrainingData();
            if (trainingData.Count < 2) return;

            var mappedData = MapEventsToIndices(trainingData);
            if (mappedData.Count < 2)
                return;

            var dataView = _ml.Data.LoadFromEnumerable(mappedData);
            var trainer = _ml.Recommendation().Trainers.MatrixFactorization(CreateTrainerOptions());

            _model = trainer.Fit(dataView);
        }
    }

    public void RetrainModel()
    {
        lock (_lock)
        {
            ResetModel();
            TrainModel();
        }
    }

    public async Task DeleteAllRecommendations()
    {
        await _context.RecommendedEvents.ExecuteDeleteAsync();
    }

    public async Task DeleteRecommendationsForUser(Guid userId)
    {
        var recommendations = await _context.RecommendedEvents
            .Where(r => r.UserId == userId)
            .ToListAsync();

        if (!recommendations.Any())
            return;

        _context.RecommendedEvents.RemoveRange(recommendations);
        await _context.SaveChangesAsync();
    }

    public async Task<List<EventResponseDto>> GetRecommendedEventsForUser(Guid userId)
    {
        try
        {
            var user = await LoadUserWithRelations(userId);
            if (user == null)
                return [];

            var cachedRecommendations = await LoadCachedRecommendations(userId);
            if (cachedRecommendations.Any())
                return _mapper.Map<List<EventResponseDto>>(cachedRecommendations);

            var recommendations = await GenerateRecommendations(user, userId);
            return _mapper.Map<List<EventResponseDto>>(recommendations);
        }
        catch (Exception ex)
        {
            var fallbackCached = await LoadCachedRecommendations(userId);
            if (fallbackCached.Any()) return _mapper.Map<List<EventResponseDto>>(fallbackCached);

            return [];
        }
    }

    private async Task<List<Event>> GenerateRecommendations(User user, Guid userId)
    {
        var excludedEventIds = GetExcludedEventIds(user);
        var relevantCategoryIds = GetRelevantCategoryIds(user);

        if (!relevantCategoryIds.Any())
            return [];

        var candidateEvents = await LoadCandidateEvents(userId, relevantCategoryIds, excludedEventIds);
        if (!candidateEvents.Any())
            return [];

        var recommendedEvents = IsModelAvailable()
            ? await RankEventsWithMl(user, candidateEvents, excludedEventIds)
            : candidateEvents.Take(MaxRecommendations).ToList();

        if (recommendedEvents.Any()) await CacheRecommendationsSafely(userId, recommendedEvents);

        return recommendedEvents;
    }

    private async Task<List<Event>> RankEventsWithMl(
        User user,
        List<Event> candidates,
        List<Guid> excludedIds)
    {
        var seedEvents = GetSeedEvents(user);
        var categoryMultipliers = BuildCategoryMultipliers(user);

        var predictionEngine = _ml!.Model.CreatePredictionEngine<EventEntry, CoEventPrediction>(_model!);
        var scoredEvents = new List<(Event Event, float Score)>();

        foreach (var candidate in candidates)
        {
            var mlScore = CalculateMlScore(seedEvents, candidate, predictionEngine);
            var contentMultiplier = GetContentMultiplier(candidate, categoryMultipliers);
            var finalScore = mlScore * contentMultiplier;

            scoredEvents.Add((candidate, finalScore));
        }

        return scoredEvents
            .OrderByDescending(x => x.Score)
            .Take(MaxRecommendations)
            .Select(x => x.Event)
            .ToList();
    }

    private float CalculateMlScore(
        List<Event> seedEvents,
        Event candidate,
        PredictionEngine<EventEntry, CoEventPrediction> predictionEngine)
    {
        if (!seedEvents.Any())
            return DefaultScore;

        float totalScore = 0;
        var predictionCount = 0;

        foreach (var seed in seedEvents)
        {
            var seedHash = Hash(seed.Id);
            var candidateHash = Hash(candidate.Id);

            if (!_eventToIndex!.ContainsKey(seedHash) || !_eventToIndex.ContainsKey(candidateHash))
                continue;

            var prediction = predictionEngine.Predict(new EventEntry
            {
                EventID = _eventToIndex[seedHash],
                CoEventID = _eventToIndex[candidateHash]
            });

            totalScore += prediction.Score;
            predictionCount++;
        }

        return predictionCount > 0 ? totalScore / predictionCount : DefaultScore;
    }

    private CategoryMultipliers BuildCategoryMultipliers(User user)
    {
        return new CategoryMultipliers
        {
            FavoriteCategoryIds = user.FavoriteEvents?
                .Where(e => e.Category != null)
                .Select(e => e.CategoryId)
                .Distinct()
                .ToHashSet() ?? new HashSet<Guid>(),

            PurchasedCategoryIds = user.TicketPurchases?
                .Where(tp => tp.Event?.Category != null)
                .Select(tp => tp.Event!.CategoryId)
                .Distinct()
                .ToHashSet() ?? new HashSet<Guid>(),

            InterestCategoryIds = user.Categories?
                .Select(c => c.Id)
                .ToHashSet() ?? new HashSet<Guid>()
        };
    }

    private float GetContentMultiplier(Event candidate, CategoryMultipliers multipliers)
    {
        if (multipliers.FavoriteCategoryIds.Contains(candidate.CategoryId) ||
            multipliers.PurchasedCategoryIds.Contains(candidate.CategoryId))
            return FavoritePurchaseWeight;

        if (multipliers.InterestCategoryIds.Contains(candidate.CategoryId)) return InterestWeight;

        return 1.0f;
    }

    private List<Event> GetSeedEvents(User user)
    {
        return user.FavoriteEvents
            .Concat(user.TicketPurchases.Where(tp => tp.Event != null).Select(tp => tp.Event!))
            .DistinctBy(e => e.Id)
            .Take(MaxSeedEvents)
            .ToList();
    }

    private bool IsModelAvailable()
    {
        return _model != null && _ml != null && _eventToIndex != null;
    }

    private async Task<User?> LoadUserWithRelations(Guid userId)
    {
        return await _context.Users
            .Include(u => u.Categories)
            .Include(u => u.FavoriteEvents)
            .ThenInclude(e => e.Category)
            .Include(u => u.TicketPurchases)
            .ThenInclude(tp => tp.Event)
            .ThenInclude(e => e.Category)
            .Include(u => u.Events)
            .FirstOrDefaultAsync(u => u.Id == userId);
    }

    private async Task<List<Event>> LoadCachedRecommendations(Guid userId)
    {
        var cached = await _context.RecommendedEvents
            .Where(r => r.UserId == userId)
            .Include(r => r.Event)
            .ThenInclude(e => e.Category)
            .Include(r => r.Event)
            .ThenInclude(e => e.CoverImage)
            .Include(r => r.Event)
            .ThenInclude(e => e.EventGalleryImages)
            .Include(r => r.Event)
            .ThenInclude(e => e.Tickets)
            .ToListAsync();

        return cached
            .Where(r => r.Event != null && r.Event.IsPublished)
            .Select(r => r.Event!)
            .ToList();
    }

    private async Task<List<Event>> LoadCandidateEvents(
        Guid userId,
        List<Guid> categoryIds,
        List<Guid> excludedIds)
    {
        var today = DateOnly.FromDateTime(DateTime.Now);
        return await _context.Events
            .Include(e => e.Category)
            .Include(e => e.CoverImage)
            .Include(e => e.EventGalleryImages)
            .Include(e => e.Tickets)
            .Where(e =>
                e.IsPublished &&
                e.OrganizerId != userId &&
                categoryIds.Contains(e.CategoryId) &&
                !excludedIds.Contains(e.Id) &&
                e.StartDate >= today)
            .ToListAsync();
    }

    private static List<Guid> GetExcludedEventIds(User user)
    {
        var favoriteIds = user.FavoriteEvents?.Select(e => e.Id) ?? Enumerable.Empty<Guid>();
        var purchasedIds = user.TicketPurchases?.Select(tp => tp.EventId) ?? Enumerable.Empty<Guid>();
        // Exclude events where user is the organizer
        var organizerEventIds = user.Events?.Select(e => e.Id) ?? Enumerable.Empty<Guid>();

        return favoriteIds
            .Concat(purchasedIds)
            .Concat(organizerEventIds)
            .Distinct()
            .ToList();
    }

    private static List<Guid> GetRelevantCategoryIds(User user)
    {
        var favoriteCategories = user.FavoriteEvents?
            .Where(e => e.Category != null)
            .Select(e => e.CategoryId) ?? Enumerable.Empty<Guid>();

        var attendedCategories = user.TicketPurchases?
            .Where(tp => tp.Event?.Category != null)
            .Select(tp => tp.Event!.CategoryId) ?? Enumerable.Empty<Guid>();

        var interestCategories = user.Categories?
            .Select(c => c.Id) ?? Enumerable.Empty<Guid>();

        return favoriteCategories
            .Concat(attendedCategories)
            .Concat(interestCategories)
            .Distinct()
            .ToList();
    }

    private async Task CacheRecommendationsSafely(Guid userId, List<Event> events)
    {
        if (!events.Any())
            return;

        try
        {
            await CacheRecommendations(userId, events);
        }
        catch (Exception ex)
        {
        }
    }

    private async Task CacheRecommendations(Guid userId, List<Event> events)
    {
        if (!events.Any())
            return;

        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            var existingRecommendations = await _context.RecommendedEvents
                .Where(r => r.UserId == userId)
                .ToListAsync();

            var existingEventIds = existingRecommendations.Select(r => r.EventId).ToHashSet();
            var newEventIds = events.Select(e => e.Id).ToHashSet();

            if (existingEventIds.SetEquals(newEventIds))
            {
                await transaction.CommitAsync();
                return;
            }

            if (existingRecommendations.Any())
            {
                _context.RecommendedEvents.RemoveRange(existingRecommendations);
                await _context.SaveChangesAsync();
            }

            var newRecommendations = events.Select(ev => new RecommendedEvent
            {
                UserId = userId,
                EventId = ev.Id,
                CreatedAt = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified)
            }).ToList();

            await _context.RecommendedEvents.AddRangeAsync(newRecommendations);
            await _context.SaveChangesAsync();

            await transaction.CommitAsync();
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    private void ResetModel()
    {
        _ml = null;
        _model = null;
        _eventToIndex = null;
        _indexToEvent = null;
    }

    private List<EventEntry> CollectTrainingData()
    {
        var data = new List<EventEntry>();

        AddUserFavoritesToTrainingData(data);
        AddUserPurchasesToTrainingData(data);
        AddCategoryRelationsToTrainingData(data);
        AddUserInterestRelationsToTrainingData(data);

        return data
            .Where(d => d.EventID > 0 && d.CoEventID > 0 && d.EventID != d.CoEventID)
            .DistinctBy(d => new { d.EventID, d.CoEventID })
            .ToList();
    }

    private void AddUserFavoritesToTrainingData(List<EventEntry> data)
    {
        var users = _context.Users
            .Include(u => u.FavoriteEvents)
            .Where(u => u.FavoriteEvents.Count > 1)
            .ToList();

        foreach (var user in users)
            AddEventPairs(data, user.FavoriteEvents, 1.0f);
    }

    private void AddUserPurchasesToTrainingData(List<EventEntry> data)
    {
        var users = _context.Users
            .Include(u => u.TicketPurchases)
            .ThenInclude(tp => tp.Event)
            .Where(u => u.TicketPurchases.Count > 1)
            .ToList();

        foreach (var user in users)
        {
            var events = user.TicketPurchases
                .Select(tp => tp.Event)
                .Where(e => e != null)
                .DistinctBy(e => e!.Id)
                .ToList()!;

            AddEventPairs(data, events, 1.0f);
        }
    }

    private void AddCategoryRelationsToTrainingData(List<EventEntry> data)
    {
        var categoryGroups = _context.Events
            .Where(e => e.IsPublished && e.CategoryId != null)
            .GroupBy(e => e.CategoryId)
            .ToList();

        foreach (var group in categoryGroups)
            AddEventPairs(data, group.Take(6).ToList(), 0.7f);
    }

    private void AddUserInterestRelationsToTrainingData(List<EventEntry> data)
    {
        var users = _context.Users
            .Include(u => u.Categories)
            .Where(u => u.Categories.Any())
            .ToList();

        foreach (var user in users)
        {
            var categoryIds = user.Categories.Select(c => c.Id).ToList();
            var events = _context.Events
                .Where(e => e.IsPublished && categoryIds.Contains(e.CategoryId))
                .ToList();

            AddEventPairs(data, events.Take(4).ToList(), 0.8f);
        }
    }

    private static void AddEventPairs(
        List<EventEntry> data,
        IEnumerable<Event> events,
        float label)
    {
        var eventList = events.ToList();

        foreach (var event1 in eventList)
        foreach (var event2 in eventList.Where(e => e.Id != event1.Id))
        {
            var id1 = Hash(event1.Id);
            var id2 = Hash(event2.Id);

            if (id1 == id2)
                continue;

            data.Add(new EventEntry
            {
                EventID = id1,
                CoEventID = id2,
                Label = label
            });
        }
    }

    private List<EventEntry> MapEventsToIndices(List<EventEntry> data)
    {
        var uniqueEventIds = data
            .SelectMany(d => new[] { d.EventID, d.CoEventID })
            .Distinct()
            .Take(MaxEvents)
            .ToList();

        _eventToIndex = uniqueEventIds
            .Select((id, index) => new { id, index })
            .ToDictionary(x => x.id, x => (uint)x.index + 1);

        _indexToEvent = _eventToIndex.ToDictionary(k => k.Value, v => v.Key);

        return data.Select(d => new EventEntry
        {
            EventID = _eventToIndex[d.EventID],
            CoEventID = _eventToIndex[d.CoEventID],
            Label = d.Label
        }).ToList();
    }

    private static MatrixFactorizationTrainer.Options CreateTrainerOptions()
    {
        return new MatrixFactorizationTrainer.Options
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
    }

    private static uint Hash(Guid id)
    {
        var hash = (uint)Math.Abs(id.GetHashCode());
        return hash == 0 ? 1u : hash;
    }

    private class CategoryMultipliers
    {
        public HashSet<Guid> FavoriteCategoryIds { get; set; } = new();
        public HashSet<Guid> PurchasedCategoryIds { get; set; } = new();
        public HashSet<Guid> InterestCategoryIds { get; set; } = new();
    }

    public class EventEntry
    {
        [KeyType(MaxEvents)] public uint EventID { get; set; }

        [KeyType(MaxEvents)] public uint CoEventID { get; set; }

        public float Label { get; set; }
    }

    public class CoEventPrediction
    {
        public float Score { get; set; }
    }
}