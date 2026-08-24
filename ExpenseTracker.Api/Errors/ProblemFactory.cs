using ExpenseTracker.Api.Common;
using Microsoft.AspNetCore.Mvc;

namespace ExpenseTracker.Api.Errors;

/// <summary>
/// Single place for Problem Details shape (status/title/type/instance/traceId).
/// </summary>
public static class ProblemFactory
{
    public static ProblemDetails Create(
        int statusCode,
        string detail,
        HttpContext httpContext,
        IDictionary<string, object?>? extraExtensions = null)
    {
        var problem = new ProblemDetails
        {
            Status = statusCode,
            Title = ProblemTitles.For(statusCode),
            Detail = detail,
            Type = $"https://httpstatuses.com/{statusCode}",
            Instance = httpContext.Request.Path,
            Extensions = { ["traceId"] = httpContext.TraceIdentifier }
        };

        if (extraExtensions is not null)
        {
            foreach (var (key, value) in extraExtensions)
                problem.Extensions[key] = value;
        }

        return problem;
    }
}

public static class ProblemTitles
{
    public static string For(int statusCode) => statusCode switch
    {
        StatusCodes.Status400BadRequest => "Bad Request",
        StatusCodes.Status401Unauthorized => "Unauthorized",
        StatusCodes.Status403Forbidden => "Forbidden",
        StatusCodes.Status404NotFound => "Not Found",
        StatusCodes.Status409Conflict => "Conflict",
        StatusCodes.Status429TooManyRequests => "Too Many Requests",
        StatusCodes.Status500InternalServerError => "Internal Server Error",
        StatusCodes.Status503ServiceUnavailable => "Service Unavailable",
        _ => "Error"
    };
}
