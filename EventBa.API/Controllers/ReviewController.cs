using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class ReviewController : BaseController<ReviewResponse, ReviewSearchObject, ReviewRequest, ReviewRequest>
    {
        public ReviewController(
            ILogger<BaseController<ReviewResponse, ReviewSearchObject, ReviewRequest, ReviewRequest>> logger,
            IReviewService service) : base(logger, service)
        {
        }
    }
}