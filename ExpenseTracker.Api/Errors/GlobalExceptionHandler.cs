using System.Net.Sockets;
using ExpenseTracker.Api.Common;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace ExpenseTracker.Api.Errors;

/// <summary>
/// Central handler for unhandled exceptions. Writes Problem Details to the client
/// (no stack/exception text) and logs the full exception with <c>traceId</c>.
/// </summary>
public sealed class GlobalExceptionHandler(
    ILogger<GlobalExceptionHandler> logger,
    IProblemDetailsService problemDetailsService) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        var traceId = httpContext.TraceIdentifier;
        var unavailable = IsServiceUnavailable(exception);
        var status = unavailable
            ? StatusCodes.Status503ServiceUnavailable
            : StatusCodes.Status500InternalServerError;
        var detail = unavailable
            ? ErrorMessages.ServiceUnavailable
            : ErrorMessages.UnexpectedError;
        var title = unavailable ? "Service Unavailable" : "Internal Server Error";

        logger.LogError(
            exception,
            "Unhandled exception. Status={Status} TraceId={TraceId}",
            status,
            traceId);

        httpContext.Response.StatusCode = status;

        // Do not pass Exception into ProblemDetailsContext — avoids leaking details to clients.
        await problemDetailsService.WriteAsync(new ProblemDetailsContext
        {
            HttpContext = httpContext,
            ProblemDetails = new ProblemDetails
            {
                Status = status,
                Title = title,
                Detail = detail,
                Type = $"https://httpstatuses.com/{status}",
                Extensions = { ["traceId"] = traceId }
            }
        });

        return true;
    }

    internal static bool IsServiceUnavailable(Exception exception)
    {
        for (var ex = exception; ex is not null; ex = ex.InnerException!)
        {
            if (ex is TimeoutException or SocketException)
                return true;

            var typeName = ex.GetType().FullName ?? string.Empty;
            if (typeName.Contains("Npgsql", StringComparison.OrdinalIgnoreCase))
                return true;

            if (ex is InvalidOperationException &&
                ex.Message.Contains("transient", StringComparison.OrdinalIgnoreCase))
                return true;
        }

        return false;
    }
}
