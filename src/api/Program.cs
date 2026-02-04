using System.Net.Http.Metrics;
using System.Reflection;
using System.Security.Cryptography.X509Certificates;
using Prometheus;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
app.UseHttpMetrics();

var statsRequests = Metrics.CreateCounter(
    "stats_endpoint_requests_total",
    "Number of requests sent to the /stats endpoint"
);

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
    statsRequests.Inc();
    var average = data.Average();

    return Results.Ok(new
    {
        version,
        gitSha,
        averageValue = average
    });
});

app.MapMetrics();
app.Run();