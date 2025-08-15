---
layout: post
title: "Architecting a Federated Data Network with PostgreSQL FDW"
date: 2019-09-20 11:00:00 +0100
tags:
  - postgresql
  - fdw
  - architecture
  - federated-learning
  - privacy
---

One of the foundational principles at IOMED is that sensitive patient data should never leave the hospital's control. This is not just a matter of regulatory compliance (like GDPR); it's a matter of trust. Centralizing patient records into a single, massive data lake creates a high-value target for security breaches and raises valid concerns from hospital IT departments.

But this principle presents a significant technical challenge: how do you enable unified, multi-site analytics if the data itself is physically distributed across different locations?

Our solution was to build a federated data network, and the core technology that powers it is a surprisingly robust and elegant feature of PostgreSQL: the **Foreign Data Wrapper (FDW)**.

### What is a Foreign Data Wrapper?

At its core, a Foreign Data Wrapper is a PostgreSQL extension that allows you to treat a remote data source as if it were a local table. When you query a "foreign table" on your local database, PostgreSQL doesn't actually store that data. Instead, it uses the FDW to connect to the remote database, run the query there, and stream the results back to you.

This capability is incredibly powerful. It allows us to create a central query engine that can "see" tables in multiple, physically separate hospital databases without ever having to copy or move the underlying data.

### Our Federated Architecture in Practice

Here’s a simplified overview of how we architected our network using PostgreSQL FDW:

1.  **On-Premise OMOP Databases:** Each hospital has its own dedicated PostgreSQL server running within its firewall, containing their data in the OMOP CDM format. The hospital remains the sole custodian of this data.

2.  **The Central Query Node:** We maintain a central PostgreSQL instance that acts as the brain of the network. This server does *not* contain any patient-level data. Instead, it contains the metadata and the federated connections, organized by schemas.

3.  **Schema-Based Organization:** For each hospital, we create a dedicated schema on our central node (e.g., `hospital_a`, `hospital_b`). Inside each schema, we create the foreign tables that map to the real tables on that hospital's remote server.
    ```sql
    CREATE SCHEMA hospital_a;
    CREATE FOREIGN TABLE hospital_a.condition_occurrence (
        -- column definitions matching the remote table
    ) SERVER hospital_a_server OPTIONS (schema_name 'ohdsi', table_name 'condition_occurrence');
    ```

4.  **Creating a Unified Interface with Partitioning:** This schema-based separation is clean, but querying across hospitals would still require cumbersome `UNION ALL` statements. To create a truly seamless interface, we use PostgreSQL's declarative partitioning.

    In a dedicated `ohdsi` schema, we create a partitioned "parent" table that looks identical to a standard OMOP table. We use a `hospital_id` column (which we add during the foreign table definition) as the partition key.

    ```sql
    CREATE TABLE ohdsi.condition_occurrence (
        hospital_id TEXT,
        -- all other columns from the OMOP condition_occurrence table
    ) PARTITION BY LIST (hospital_id);
    ```

    Then, we attach each hospital's foreign table as a partition of this main table. This effectively merges the remote tables into a single, logical view.

    ```sql
    ALTER TABLE ohdsi.condition_occurrence ATTACH PARTITION hospital_a.condition_occurrence FOR VALUES IN ('hospital_a');
    ALTER TABLE ohdsi.condition_occurrence ATTACH PARTITION hospital_b.condition_occurrence FOR VALUES IN ('hospital_b');
    ```

5.  **Running Seamless Federated Queries:** With this setup, a researcher can now run queries against `ohdsi.condition_occurrence` as if it were a single, massive local table. PostgreSQL's query planner handles the rest, routing the query to the correct underlying foreign tables at each hospital.

    The query becomes incredibly simple and intuitive:
    ```sql
    SELECT count(distinct person_id)
    FROM ohdsi.condition_occurrence
    WHERE condition_concept_id = 12345;
    ```
    The complexity of the federation is completely abstracted away. When a new hospital joins the network, we simply create their schema, define their foreign tables, and attach them as new partitions. The researcher's view of the data is instantly updated without any changes to their code.

### The Vision: A Decentralized and Intelligent Network

This hub-and-spoke model is just the first step. Our long-term vision is to create a truly decentralized network where IOMED is a facilitator, not a dependency. We envision a future where hospitals can establish FDW connections directly with each other for collaborative research.

Furthermore, the central node itself will evolve into an intelligent query gateway. Before any query is executed, it will be analyzed to ensure it only requests aggregated results, adding a critical layer of automated governance and making the network secure by design.

### The Power of a Privacy-Preserving Approach

This architecture is the cornerstone of our privacy-by-design philosophy. It allows us to deliver powerful, real-time, multi-site insights while respecting data residency and minimizing security risks. It's a technical solution that builds trust, which is the most valuable currency in healthcare.
