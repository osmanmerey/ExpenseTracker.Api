using System.Net.Sockets;
using ExpenseTracker.Api.Common;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExpenseTracker.Api.Errors;

/// <summary>
/// Testing-only endpoints that trigger known failure modes for contract tests.
/// Prefer moving to the test host long-term; gated by <see cref="HostingEnvironments.Testing"/>.
/// </summary>
[ApiController]
[Route("api/diagnostic")]
[ApiExplorerSettings(IgnoreApi = true)]
public sealed class DiagnosticController(IHostEnvironment environment) : ControllerBase
{
    [HttpGet("boom")]
    [AllowAnonymous]
    public IActionResult Boom()
    {
        if (!environment.IsEnvironment(HostingEnvironments.Testing))
            return NotFound();

        throw new InvalidOperationException("Intentional test failure");
    }

    [HttpGet("db-down")]
    [AllowAnonymous]
    public IActionResult DbDown()
    {
        if (!environment.IsEnvironment(HostingEnvironments.Testing))
            return NotFound();

        // SocketException → 503 via GlobalExceptionHandler.IsServiceUnavailable.
        throw new InvalidOperationException(
            "Simulated database connectivity failure.",
            new SocketException(10061));
    }
}
