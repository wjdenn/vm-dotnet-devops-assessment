# VM .NET DevOps Assessment
This Repository contains a minimal .NET service and supporting infrastructure designed to demonstrate CI/CD, containerisation, Kubernetes deployment, IIS automation and operational practices.

The application logic is intentionally simple so that delivery and platform concerns are clearly visible. 

## Repository Structure
```
├── src/api/ # ASP.NET Core service
├── helm/app-chart/ # Helm chart for Kubernetes deployment
├── iis/ # PowerShell automation for IIS deployment
├── .github/workflows/ # CI/CD pipelines
└── README.md
```
## Application Overview

The service is a small ASP.NET Core application exposing the following endpoints:

- `GET /healthz`  
  Health endpoint used for liveness and readiness checks

- `GET /stats`  
  Simple application endpoint returning static metadata

- `GET /metrics`  
  Prometheus-compatible metrics endpoint exposed via `prometheus-net`

The service is designed to run consistently:
- locally
- in Docker
- in Kubernetes
- behind IIS using ASP.NET Core hosting

## Running Locally

### Prerequisites
- .NET 8 SDK

### Run the service
```
cd src/api
dotnet run
```
## Containerisation
The Application is containerised using a multi-stage Docker build.

### Build the Image
```
docker build -t vm-dotnet-api:local .
```
### Run Locally
```
docker run -p 8080:8080 vm-dotnet-api:local
```

## Kubernetes Deployment
Kubernetes deployment is managed using Helm and targets a generic cluster
configuration.

The Helm chart defines:
- Deployment with resource requests and limits
- Liveness and readiness probes
- Service
- Ingress with TLS Configuration
- Prometheus scrape annotation

### Example Deploy
```
helm upgrade --install vm-dotnet-api \
  ./helm/app-chart \
  --namespace dev \
  --create-namespace
```
Local validation was performed using kind.

Ingress controller installation and cluster-level configuration are treated as
external platform concerns.

## ISS Deployment
A legacy IIS deployment path is provided via PowerShell automation.

The IIS deployment script:
- Ensures required IIS features are installed
- Configures an application pool suitable for ASP.NET Core
- Publishes the .NET application using dotnet publish
- Creates or updates an IIS site with HTTP and HTTPS bindings
- Generates and applies a self-signed certificate
- Is fully idempotent and safe to re-run

The script is intended to be executed non-interactively and is validated via a
Windows-based CI job.

### Assumptions
- Script is run with admin privileges
- IIS is available on the target system
- ASP.NET Core Hosting Bundle is installed

## CI/CD
GitHub Actions is used to implement CI/CD workflows with clear separation
between build, test, and deployment stages.

### Pipelines

- **Build and Test**  
  Compiles the application, restores dependencies, and runs tests.  
  This workflow acts as the quality gate for all deployment steps.

- **Deploy to Kubernetes (Dev)**  
  Deploys the application to a development namespace using Helm.  
  This workflow is triggered only after a successful Build and Test run.

- **Deploy to IIS**  
  Executes the IIS PowerShell automation on a Windows runner to validate
  legacy deployment automation.  
  This workflow is also gated on a successful Build and Test run.

Deployment workflows are explicitly guarded to ensure that no deployment
occurs if the build or test stages fail.

## Observability

The service exposes Prometheus-compatible metrics at the `/metrics` endpoint
using `prometheus-net`.

Metrics exposed include:
- HTTP request counts and request duration
- Process-level CPU and memory usage
- Basic application-level counters

Kubernetes pods include standard Prometheus scrape annotations to allow
automatic discovery by an existing Prometheus installation.

Grafana is treated as an external, centrally managed platform service and is
not deployed as part of this repository. In a real environment, metrics would
be visualised via shared Grafana dashboards managed by the platform team.

## Architecture

A more detailed description of the system design, assumptions, and trade-offs
is documented in the Architecture Overview.

This includes:
- High-level application design
- Kubernetes resource layout
- IIS hosting model
- CI/CD flow and quality gates
- Explicit trade-offs and future improvements

## Trade-Offs and Future Improvements

The solution prioritises clarity, portability, and correctness over
completeness.

Notable trade-offs include:
- No ingress controller installation or cluster-level configuration
- No bundled Prometheus or Grafana deployment
- IIS feature installation performed during CI to validate automation on a
  clean environment

Potential future improvements could include:
- Environment promotion strategies beyond development
- Centralised Grafana dashboard provisioning
- Structured logging and log aggregation
- Deployment to additional Kubernetes environments