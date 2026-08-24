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
        // title kept for call-site readability; canonical title comes from ProblemFactory.
        _ = title;
        var problem = ProblemFactory.Create(statusCode, detail, controller.HttpContext);
        return controller.StatusCode(statusCode, problem);
    }
}
