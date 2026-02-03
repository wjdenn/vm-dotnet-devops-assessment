using System.Reflection;
using System.Security.Cryptography.X509Certificates;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var version = Assembly.GetExecutingAssembly()
    .GetName()
    .Version?
    .ToString() ?? "unknown";

var gitSha = Environment.GetEnvironmentVariable("GIT_SHA") ?? "unknown";

var data = new[] { 10, 20, 30, 40, 50 };

app.MapGet("/healthz", () =>
{
    return Results.Ok(new { status = "ok" });
});

app.MapGet("/stats", () =>
{
    var average = data.Average();

    return Results.Ok(new
    {
        version,
        gitSha,
        averageValue = average
    });
});

app.Run();