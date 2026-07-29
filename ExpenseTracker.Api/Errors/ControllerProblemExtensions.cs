using Microsoft.AspNetCore.Mvc;

namespace ExpenseTracker.Api.Errors;

/// <summary>
/// Helpers so controllers return the same Problem Details shape as the global handler.
/// </summary>
public static class ControllerProblemExtensions
{
    public static ObjectResult ProblemResult(
        this ControllerBase controller,
        int statusCode,
        string title,
        string detail)
    {
        var traceId = controller.HttpContext.TraceIdentifier;
        var problem = new ProblemDetails
        {
            Status = statusCode,
            Title = title,
            Detail = detail,
            Type = $"https://httpstatuses.com/{statusCode}",
            Instance = controller.HttpContext.Request.Path,
            Extensions = { ["traceId"] = traceId }
        };

        return controller.StatusCode(statusCode, problem);
    }
}
