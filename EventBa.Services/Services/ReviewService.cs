using AutoMapper;
using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Database;
using EventBa.Services.Database.Context;
using EventBa.Services.Interfaces;

namespace EventBa.Services.Services
{
    public class ReviewService : BaseService<ReviewResponse, Review, ReviewSearchObject, ReviewRequest, ReviewRequest>, IReviewService
    {
        public ReviewService(EventbaDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}