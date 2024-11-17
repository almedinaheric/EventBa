using EventBa.Model.Requests;
using EventBa.Model.Responses;
using EventBa.Model.SearchObjects;
using EventBa.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace EventBa.API.Controllers
{
    [ApiController]
    public class SalesReportController : BaseController<SalesReportResponse, SalesReportSearchObject, SalesReportRequest
        , SalesReportRequest>
    {
        public SalesReportController(
            ILogger<
                    BaseController<SalesReportResponse, SalesReportSearchObject, SalesReportRequest,
                        SalesReportRequest>>
                logger,
            ISalesReportService service) : base(logger, service)
        {
        }
    }
}