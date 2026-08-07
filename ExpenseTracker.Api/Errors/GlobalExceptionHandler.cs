using System.Net.Sockets;
using ExpenseTracker.Api.Common;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

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
        // Client aborted the request — not a server failure.
        if (exception is OperationCanceledException &&
            httpContext.RequestAborted.IsCancellationRequested)
        {
            logger.LogDebug(
                exception,
                "Request aborted by client. TraceId={TraceId}",
                httpContext.TraceIdentifier);
            return true;
        }

        var unavailable = IsServiceUnavailable(exception);
        var status = unavailable
            ? StatusCodes.Status503ServiceUnavailable
            : StatusCodes.Status500InternalServerError;
        var detail = unavailable
            ? ErrorMessages.ServiceUnavailable
            : ErrorMessages.UnexpectedError;

        logger.LogError(
            exception,
            "Unhandled exception. Status={Status} TraceId={TraceId}",
            status,
            httpContext.TraceIdentifier);

        httpContext.Response.StatusCode = status;

        await problemDetailsService.WriteAsync(new ProblemDetailsContext
        {
            HttpContext = httpContext,
            ProblemDetails = ProblemFactory.Create(status, detail, httpContext)
        });

        return true;
    }

    /// <summary>
    /// True only for likely-transient outages (network/timeout/Npgsql transient).
    /// Data/SQL errors (unique, FK, …) stay 500.
    /// </summary>
    public static bool IsServiceUnavailable(Exception exception)
    {
        for (var ex = exception; ex is not null; ex = ex.InnerException!)
        {
            if (ex is TimeoutException or SocketException)
                return true;

            if (ex is PostgresException postgres)
            {
                // Class 08 = connection exception; 57P01 = admin_shutdown, etc.
                var state = postgres.SqlState ?? string.Empty;
                return state.StartsWith("08", StringComparison.Ordinal) ||
                       state.StartsWith("57P", StringComparison.Ordinal);
            }

            if (ex is NpgsqlException npgsql)
                return npgsql.IsTransient;

            // EF Core retry wrapper messages — require both cues, not bare "transient".
            if (ex is InvalidOperationException &&
                ex.Message.Contains("transient failure", StringComparison.OrdinalIgnoreCase) &&
                ex.Message.Contains("retry", StringComparison.OrdinalIgnoreCase))
                return true;
        }

        return false;
    }
}
