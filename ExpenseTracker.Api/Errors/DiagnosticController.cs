using System.Net.Sockets;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExpenseTracker.Api.Errors;

/// <summary>
/// Testing-only endpoints that trigger known failure modes for contract tests.
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
        if (!environment.IsEnvironment("Testing"))
            return NotFound();

        throw new InvalidOperationException("Intentional test failure");
    }

    [HttpGet("db-down")]
    [AllowAnonymous]
    public IActionResult DbDown()
    {
        if (!environment.IsEnvironment("Testing"))
            return NotFound();

        throw new InvalidOperationException(
            "An exception has been raised that is likely due to a transient failure.",
            new SocketException(10061));
    }
}
