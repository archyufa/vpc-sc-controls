# VPC Service Controls Architecture

This document details the proposed architecture for implementing VPC Service Controls.

## 1. Service Perimeter

A single service perimeter will be created to protect the following projects:
- Project A
- Project B
- Project C

The perimeter will restrict the following services:
- Google Cloud Storage (GCS)
- Google BigQuery
- Google Compute Engine (GCE)

## 2. Access Level

An access level named `developers_cloud_shell_access` will be created. This access level will grant access to the service perimeter for members of the `developers@mycompany.com` Google Group.

The access level will be configured to only allow access from the Cloud Shell environment. This will be achieved by conditioning the access level on specific IP ranges and user agents associated with Cloud Shell.

## 3. Ingress and Egress Rules

Initially, no specific ingress or egress rules will be configured. The default behavior of the service perimeter will be to deny all access from outside the perimeter, except for what is explicitly allowed by the access level.

## 4. Dry-Run Mode

The service perimeter will be initially deployed in "dry-run" mode. This will allow us to monitor the effects of the policy without actually blocking any requests. This is a critical step to avoid disrupting developer workflows.

## 5. Diagram

Here is a Mermaid diagram illustrating the proposed architecture:

```mermaid
graph TD
    subgraph "Google Cloud Organization"
        subgraph "VPC Service Controls Perimeter"
            direction LR
            A[Project A]
            B[Project B]
            C[Project C]
        end

        subgraph "Restricted Services"
            GCS[GCS]
            BigQuery[BigQuery]
            GCE[GCE]
        end
    end

    subgraph "Developers"
        User[Developer] -- Member of --> Group
        Group[developers@mycompany.com]
    end

    subgraph "Access Mechanism"
        CloudShell[Cloud Shell]
    end

    AccessLevel[Access Level: developers_cloud_shell_access]

    User -- Uses --> CloudShell
    CloudShell -- Granted Access via --> AccessLevel
    AccessLevel -- Applies to --> "VPC Service Controls Perimeter"

    "VPC Service Controls Perimeter" -- Protects --> A
    "VPC Service Controls Perimeter" -- Protects --> B
    "VPC Service Controls Perimeter" -- Protects --> C

    A -- Uses --> GCS
    B -- Uses --> BigQuery
    C -- Uses --> GCE
```
