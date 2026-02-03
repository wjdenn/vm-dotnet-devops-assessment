using System.Reflection;
using Xunit;

namespace Api.Tests;

public class StatsTests
{
    [Fact]
    public void AverageCalculation_IsCorrect()
    {
        var data = new[] { 10, 20, 30, 40, 50 };
        var average = data.Average();

        Assert.Equal(30, average);
    }
}
