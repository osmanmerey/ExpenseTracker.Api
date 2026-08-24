using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.RateLimiting;
using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.Data;
using ExpenseTracker.Api.Errors;
using ExpenseTracker.Api.Repositories;
using ExpenseTracker.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

var jwtKey = builder.Configuration[ConfigurationKeys.JwtKey];
var jwtIssuer = builder.Configuration[ConfigurationKeys.JwtIssuer];
var jwtAudience = builder.Configuration[ConfigurationKeys.JwtAudience];

if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < SecurityConstants.MinimumJwtKeyLengthInChars)
    throw new InvalidOperationException(ErrorMessages.JwtKeyMissing);

if (string.IsNullOrWhiteSpace(jwtIssuer) || string.IsNullOrWhiteSpace(jwtAudience))
    throw new InvalidOperationException(ErrorMessages.JwtIssuerOrAudienceMissing);

var exposeResetToken = builder.Configuration.GetValue(
    ConfigurationKeys.AuthExposeResetTokenInResponse, false);
if (exposeResetToken && builder.Environment.IsProduction())
    throw new InvalidOperationException(ErrorMessages.ExposeResetTokenInProduction);
/*
var databaseProvider = builder.Configuration[ConfigurationKeys.DatabaseProvider] ?? DatabaseProviders.Postgres;

if (string.Equals(databaseProvider, DatabaseProviders.InMemory, StringComparison.OrdinalIgnoreCase))
{
    builder.Services.AddDbContext<AppDbContext>(options =>
        options.UseInMemoryDatabase(DatabaseProviders.InMemoryDatabaseName));
}
else
{
    var connectionString = builder.Configuration.GetConnectionString(ConfigurationKeys.DefaultConnectionName);
    if (string.IsNullOrWhiteSpace(connectionString))
        throw new InvalidOperationException(ErrorMessages.ConnectionStringMissing);

    var commandTimeout = builder.Configuration.GetValue(
        ConfigurationKeys.DatabaseCommandTimeoutSeconds,
        SecurityConstants.DefaultDatabaseCommandTimeoutSeconds);

    builder.Services.AddDbContext<AppDbContext>(options =>
        options.UseNpgsql(connectionString, npgsql => npgsql.CommandTimeout(commandTimeout)));
}
*/
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseInMemoryDatabase("ExpenseTrackerMemoryDb"));
    //InMemory çalıştırmak için kullanılan blok
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IExpenseRepository, ExpenseRepository>();
builder.Services.AddScoped<IBudgetRepository, BudgetRepository>();
builder.Services.AddSingleton<IPasswordResetStore, InMemoryPasswordResetStore>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IExpenseService, ExpenseService>();
builder.Services.AddScoped<IBudgetService, BudgetService>();

builder.Services.AddProblemDetails(options =>
{
    options.CustomizeProblemDetails = context =>
    {
        context.ProblemDetails.Extensions["traceId"] = context.HttpContext.TraceIdentifier;
        context.ProblemDetails.Instance ??= context.HttpContext.Request.Path;
        if (string.IsNullOrWhiteSpace(context.ProblemDetails.Title) && context.ProblemDetails.Status is int status)
            context.ProblemDetails.Title = ProblemTitles.For(status);
        if (string.IsNullOrWhiteSpace(context.ProblemDetails.Type) && context.ProblemDetails.Status is int s)
            context.ProblemDetails.Type = $"https://httpstatuses.com/{s}";
    };
});
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header
    });
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ValidateIssuer = true,
            ValidIssuer = jwtIssuer,
            ValidateAudience = true,
            ValidAudience = jwtAudience,
            ValidateLifetime = true,
            ClockSkew = SecurityConstants.ClockSkew
        };

        options.Events = new JwtBearerEvents
        {
            OnChallenge = async context =>
            {
                context.HandleResponse();
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                context.Response.ContentType = "application/problem+json";

                var problem = ProblemFactory.Create(
                    StatusCodes.Status401Unauthorized,
                    ErrorMessages.Unauthorized,
                    context.HttpContext);

                await context.Response.WriteAsync(JsonSerializer.Serialize(problem, new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                }));
            },
            OnForbidden = async context =>
            {
                context.Response.StatusCode = StatusCodes.Status403Forbidden;
                context.Response.ContentType = "application/problem+json";

                var problem = ProblemFactory.Create(
                    StatusCodes.Status403Forbidden,
                    ErrorMessages.Forbidden,
                    context.HttpContext);

                await context.Response.WriteAsync(JsonSerializer.Serialize(problem, new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                }));
            }
        };
    });
builder.Services.AddAuthorization();

var authPermitLimit = builder.Configuration.GetValue(
    ConfigurationKeys.AuthRateLimitPermitLimit, SecurityConstants.DefaultAuthRateLimitPermitLimit);
var authWindowSeconds = builder.Configuration.GetValue(
    ConfigurationKeys.AuthRateLimitWindowSeconds, SecurityConstants.DefaultAuthRateLimitWindowSeconds);

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

    options.OnRejected = async (context, cancellationToken) =>
    {
        var http = context.HttpContext;
        http.Response.StatusCode = StatusCodes.Status429TooManyRequests;
        http.Response.ContentType = "application/problem+json";
        http.Response.Headers.RetryAfter = authWindowSeconds.ToString();

        var problem = ProblemFactory.Create(
            StatusCodes.Status429TooManyRequests,
            ErrorMessages.TooManyRequests,
            http,
            new Dictionary<string, object?> { ["retryAfterSeconds"] = authWindowSeconds });

        await http.Response.WriteAsync(JsonSerializer.Serialize(problem, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        }), cancellationToken);
    };

    options.AddPolicy(RateLimitPolicies.Auth, httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.Connection.RemoteIpAddress?.ToString()
                ?? RateLimitPolicies.UnknownClientPartitionKey,
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = authPermitLimit,
                Window = TimeSpan.FromSeconds(authWindowSeconds),
                QueueLimit = 0
            }));
});

var allowedOrigins = builder.Configuration.GetSection(ConfigurationKeys.CorsAllowedOrigins).Get<string[]>() ?? [];
if (!builder.Environment.IsDevelopment() &&
    !builder.Environment.IsEnvironment(HostingEnvironments.Testing) &&
    allowedOrigins.Length == 0)
{
    throw new InvalidOperationException(
        "Cors:AllowedOrigins must be configured outside Development/Testing.");
}

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        if (builder.Environment.IsDevelopment())
        {
            // Flutter web / Vite often use random or fixed localhost ports (e.g. 5173, 51999).
            // Dev-only: allow any localhost origin; prefer documenting a fixed --web-port in clients.
            policy.SetIsOriginAllowed(origin =>
                    Uri.TryCreate(origin, UriKind.Absolute, out var originUri) &&
                    originUri.Host == "localhost")
                .AllowAnyHeader()
                .AllowAnyMethod();
        }
        else if (allowedOrigins.Length > 0)
        {
            policy.WithOrigins(allowedOrigins)
                .AllowAnyHeader()
                .AllowAnyMethod();
        }
    });
});

builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>("database");

var app = builder.Build();

// Auto-migrate only when explicitly enabled (default: Development). Production uses deploy-time `dotnet ef database update`.
/*
var applyMigrations = builder.Configuration.GetValue(
    ConfigurationKeys.ApplyMigrationsOnStartup,
    defaultValue: app.Environment.IsDevelopment());
if (applyMigrations)
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    if (db.Database.IsRelational())
        db.Database.Migrate();
}
*/
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseExceptionHandler();
app.UseStatusCodePages(async statusCodeContext =>
{
    var http = statusCodeContext.HttpContext;
    if (http.Response.StatusCode is < 400 or >= 600)
        return;
    if (http.Response.ContentLength is > 0)
        return;

    // Fill empty 4xx/5xx bodies (e.g. 403 from authorization) with the shared contract.
    var detail = http.Response.StatusCode switch
    {
        StatusCodes.Status401Unauthorized => ErrorMessages.Unauthorized,
        StatusCodes.Status403Forbidden => ErrorMessages.Forbidden,
        StatusCodes.Status404NotFound => ErrorMessages.NotFound,
        _ => ErrorMessages.UnexpectedError
    };

    http.Response.ContentType = "application/problem+json";
    var problem = ProblemFactory.Create(http.Response.StatusCode, detail, http);
    await http.Response.WriteAsync(JsonSerializer.Serialize(problem, new JsonSerializerOptions
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    }));
});
app.UseMiddleware<ClientErrorLoggingMiddleware>();
app.UseHttpsRedirection();
app.UseCors();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health");

app.Run();

public partial class Program { }
