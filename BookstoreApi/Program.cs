using Microsoft.EntityFrameworkCore;
using BookstoreApi.Data;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using BookstoreApi.Services;

var builder = WebApplication.CreateBuilder(args);

// Configure Kestrel for container
if (Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true")
{
    builder.WebHost.UseUrls("http://0.0.0.0:80");
}

// Add services
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    });

// Register JWT Service
builder.Services.AddScoped<IJwtService, JwtService>();

// Add CORS for frontend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("https://app.zhong.nz", "http://localhost:3000", "http://localhost:5173")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Add DbContext
builder.Services.AddDbContext<BookstoreDbContext>(options =>
{
    var connectionString = Environment.GetEnvironmentVariable("CONNECTION_STRING") ??
                         builder.Configuration.GetConnectionString("DefaultConnection");

    if (string.IsNullOrEmpty(connectionString))
    {
        Console.WriteLine("WARNING: No connection string found, using in-memory database");
        options.UseInMemoryDatabase("BookstoreInMemoryDb");
    }
    else
    {
        Console.WriteLine("INFO: Using MySQL database");
        var serverVersion = new MySqlServerVersion(new Version(8, 0, 35));
        options.UseMySql(connectionString, serverVersion);
    }
});

// Add JWT Authentication
var jwtSettings = builder.Configuration.GetSection("Jwt");
var secretKey = Environment.GetEnvironmentVariable("JWT_SECRET") 
               ?? jwtSettings["SecretKey"] 
               ?? "default-secret-key-for-development-only-min-32-chars";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
        ClockSkew = TimeSpan.Zero
    };
});

// Add health checks
builder.Services.AddHealthChecks()
    .AddCheck("self", () => Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy("API is running"))
    .AddDbContextCheck<BookstoreDbContext>("database");

var app = builder.Build();

var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("Bookstore API starting up...");

// Check migration mode
var runMigration = Environment.GetEnvironmentVariable("RUN_MIGRATION") == "1";
if (runMigration)
{
    logger.LogInformation("MIGRATION TASK STARTED");
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<BookstoreDbContext>();
    
    try
    {
        await db.Database.MigrateAsync();
        logger.LogInformation("Database migrations completed successfully");
        Environment.Exit(0);
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "MIGRATION FAILED: {Message}", ex.Message);
        Environment.Exit(1);
    }
}

app.UseCors("AllowFrontend");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

// Health check endpoints
app.MapHealthChecks("/health");
app.MapHealthChecks("/health/live");
app.MapHealthChecks("/health/ready");

// Root endpoint
app.MapGet("/", () => new { message = "Bookstore API is up and running", version = "1.0.0" });

// Initialize database
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<BookstoreDbContext>();
    try
    {
        if (await db.Database.CanConnectAsync())
        {
            logger.LogInformation("Database connection successful");
            if (app.Environment.IsDevelopment())
            {
                db.Database.EnsureCreated();
                logger.LogInformation("Database initialized with seed data");
            }
        }
    } 
    catch (Exception ex)
    {
        logger.LogWarning(ex, "Database initialization warning: {Message}", ex.Message);
    }
}

logger.LogInformation("Application startup complete");
app.Run();

public partial class Program { }
