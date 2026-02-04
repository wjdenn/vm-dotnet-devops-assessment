# Architecture Overview

## Context
This repository contains a minimal .NET service designed to demonstrate CI/CD, containerisation, Kubernetes Deployment, IIS Automation and operational practices. 

The Application itself is intentionally simple so that platform and delivery concerns are clearly visible. 

## Assumptions made
Based on clarification from the hiring team:
- Kubernetes cluster is generic
- Ingress controller is assumed to be nginx-compatible
- Self-signed TLS is acceptable
- Application is a .NET service
- IIS deployment is evaluated on automation and CI integration
- Validation refers to CI pipeline steps (build, test, publish results)

These assumptions have been made explicit in order to avoid unnecessary environment specific optimisations.

## High Level Design
The service is implemented as a basic ASP.NET Core application exposing the following endpoints:
- `/healthz` - A simple health check for readiness and liveness probing.
- `/stats` - A basic endpoint returning static metadata and a computed average.
- `/metrics` - A prometheus compatible metrics endpoint.

The application uses a minimal hosting model and is configured in order to run against local environments, containerised environments, Kubernetes and IIS.

The Priorities of this design were:
- Fast startup
- Predictable behaviour
- Ease of automation

## Kubernetes Deployment
This application is deployed to Kubernetes using Helm to ensure portability and repeatability. 

The chart targets a generic Kubernetes cluster and avoids cloud-specific resources or ingress controller installation. Local validation was performed using `kind`.

## IIS Deployment 
A legacy deployment path to IIS is supported using PowerShell automation.

The `deploy.ps1` script is designed to be executed non-interactively and is validated using a windows based CI job in Github Actions.  

## CI/CD Pipelines
Github actions is used to build, test, package and deploy the application with clear separation of concerns:

- Build & Test: Compiles the application, executes unit tests and builds it into a docker image.
- Deploy to K8s: Deploys to a development environment using Helm, gated on a successful CI completion.
- Deploy to IIS: Runs `deploy.ps1` on a Windows runner, also gated on a successful CI completion.

Deployment workflows are explicity guarded to ensure they only run after successful build and test phase. 

## Observability
The Service exposes basic health and metrics endpoints to support monitoring including:
- HTTP Request counts
- Process-level CPU and memory metrics

Kubernetes pods include standard prometheus scrape annotations to allow auto discovery by an existing prometheus installation.

Grafana is treated as an external, centrally managed platform service and is not deployed as part of this repository.

## Trade Offs And Stretch Goals/Future Improvements
The solution prioritises clarity and portability over completeness. 

Notable trade offs:
- No ingress controller installation or cluster-level configuration
- No bundled Prometheus or grafana deployment
- IIS feature installation performed during CI to validate automation on a clean environment

Potential furure improvements:
- Environment specific Helm values and promotion strategies
- Centralised dashboard provisioning for Grafana
- Structured logging and log aggregation
- Deployment to additional Kubernetes environments