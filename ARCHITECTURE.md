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

## High Level Design
The service is implemented as a basic ASP.NET Core application exposing 2 HTTP endpoints. 
_TODO: Expand with behaviour and configuration once implemented_

## Kubernetes Deployment
Application will be deployed to Kubernetes using Helm, targetting a generic cluster configuration.
_TODO: Document final Helm resources, probes, limits and ingress configuration_ 

## IIS Deployment 
Legacy deployment path to IIS is supported using PowerShell automation.
_TODO: Document IIS hosting model and deployment flow after PS1 scripts are complete_

## CI/CD Pipelines
Github actions will be used to build, test, package and deploy the application.
_TODO: DOcument final pipeline stages and quality gates once workflows are implemented._

## Observability
The Service will expose basic health and metrics endpoints to support monitoring.
_TODO: Document final metrics, logging and example visualisation once implemented_

## Trade Offs And Stretch Goals/Future Improvements
The solution prioritises clarity and portability over completeness. 
_TODO: Document trade offs made during implementation and outline stretch goals_ 