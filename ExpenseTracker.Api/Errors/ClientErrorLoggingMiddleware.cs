namespace ExpenseTracker.Api.Errors;

/// <summary>
/// Logs expected client errors (4xx) at Warning — never Error — so real server
/// failures stay visible. Includes TraceId for correlation with the response body.
/// Does not log request bodies (may contain passwords).
/// </summary>
public sealed class ClientErrorLoggingMiddleware(RequestDelegate next, ILogger<ClientErrorLoggingMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        await next(context);

        var status = context.Response.StatusCode;
        if (status is < 400 or >= 500)
            return;

        logger.LogWarning(
            "Client error {StatusCode} TraceId={TraceId} {Method} {Path}",
            status,
            context.TraceIdentifier,
            context.Request.Method,
            context.Request.Path.Value);
    }
}
