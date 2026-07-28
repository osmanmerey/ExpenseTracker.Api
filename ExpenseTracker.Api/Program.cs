using Microsoft.EntityFrameworkCore;
using ExpenseTracker.Api.Common;
using ExpenseTracker.Api.Data;
using ExpenseTracker.Api.Repositories;
using ExpenseTracker.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

var jwtKey = builder.Configuration[ConfigurationKeys.JwtKey];
var jwtIssuer = builder.Configuration[ConfigurationKeys.JwtIssuer];
var jwtAudience = builder.Configuration[ConfigurationKeys.JwtAudience];

// HmacSha512 (used to sign tokens) requires a key of at least 512 bits (64 bytes).
if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < SecurityConstants.MinimumJwtKeyLengthInChars)
    throw new InvalidOperationException(ErrorMessages.JwtKeyMissing);

if (string.IsNullOrWhiteSpace(jwtIssuer) || string.IsNullOrWhiteSpace(jwtAudience))
    throw new InvalidOperationException(ErrorMessages.JwtIssuerOrAudienceMissing);

// Database provider is selectable via configuration ("Database:Provider").
// Use "InMemory" to run without an external PostgreSQL instance; defaults to "Postgres".
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

    builder.Services.AddDbContext<AppDbContext>(options => options.UseNpgsql(connectionString));
}

// Repository layer: persistence-only, talks directly to AppDbContext.
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IExpenseRepository, ExpenseRepository>();

// Service layer: business rules, talks only to repositories (never to AppDbContext directly).
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IExpenseService, ExpenseService>();

builder.Services.AddControllers();
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
    });
builder.Services.AddAuthorization();

// Brute-force protection for /api/auth/* (register/login): fixed-window limiter,
// scoped per client IP. Limits are configurable so tests can raise them to avoid
// flakiness while production keeps a strict default (see SecurityConstants).
var authPermitLimit = builder.Configuration.GetValue(
    ConfigurationKeys.AuthRateLimitPermitLimit, SecurityConstants.DefaultAuthRateLimitPermitLimit);
var authWindowSeconds = builder.Configuration.GetValue(
    ConfigurationKeys.AuthRateLimitWindowSeconds, SecurityConstants.DefaultAuthRateLimitWindowSeconds);

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

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
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        if (allowedOrigins.Length > 0)
        {
            policy.WithOrigins(allowedOrigins)
                .AllowAnyHeader()
                .AllowAnyMethod();
        }
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();

// Exposed so the integration test project (WebApplicationFactory) can bootstrap the host.
public partial class Program { }