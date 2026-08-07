using ExpenseTracker.Api.Common;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ExpenseTracker.Api.Controllers;

/// <summary>
/// Single source for fixed FX rates used by budget spent / client totals.
/// </summary>
[Route("api/[controller]")]
[ApiController]
public class CurrenciesController : ControllerBase
{
    [HttpGet]
    [AllowAnonymous]
    public IActionResult GetRates()
    {
        return Ok(new
        {
            baseCurrency = "TRY",
            ratesToTry = FixedCurrencyRates.AllRates
        });
    }
}
