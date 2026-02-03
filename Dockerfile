# Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY src/api/Api.csproj ./Api/
RUN dotnet restore ./Api/Api.csproj

COPY src/api ./Api
WORKDIR /app/Api

RUN dotnet publish -c Release -o /out /p:UseAppHost=false

# Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

RUN addgroup --system appgroup && adduser --system appuser --ingroup appgroup
USER appuser

COPY --from=build /out ./

EXPOSE 8080

ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "Api.dll"]