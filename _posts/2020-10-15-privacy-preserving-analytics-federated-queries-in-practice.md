---
layout: post
title: "Privacy-Preserving Analytics: Federated Queries in Practice"
date: 2020-10-15 12:00:00 +0100
tags:
  - privacy
  - federated-learning
  - architecture
  - security
  - gdpr
---

How can researchers gain insights from the data of multiple hospitals without ever moving or exposing sensitive patient information? This isn't a theoretical question—it's the central challenge we had to solve to make our federated data network a reality. The answer lies in a paradigm shift: instead of bringing the data to the analysis, we bring the analysis to the data.

In a previous post, I discussed the architecture using PostgreSQL's Foreign Data Wrappers (FDW). Now, I want to share how this model works in practice for running privacy-preserving analytics.

### The Principle: Send the Question, Not the Data

The traditional approach to multi-site studies involves a painful and risky process: de-identifying, exporting, and centralizing data from each participating hospital. This creates significant privacy vulnerabilities and logistical headaches.

Our federated model flips this on its head. A researcher, using our platform, formulates a query to, for example, build a patient cohort. Our system then takes this query and distributes it to each hospital in the network. The query runs locally, inside the hospital's own secure environment, against their OMOP database. Only the final, aggregated, non-identifiable result is returned to the central node.

Let's walk through a practical example. A researcher wants to know the total number of male patients over the age of 50 diagnosed with hypertension across three hospitals.

1.  **Query Formulation:** The researcher builds the cohort criteria using our tools. This translates into a standard SQL query.
2.  **Federated Execution:** Our central query engine uses the FDW connections to send the relevant parts of the SQL query to Hospital A, Hospital B, and Hospital C.
3.  **Local Computation:**
    *   Hospital A's database runs the query and finds it has 150 such patients. It returns only the number `150`.
    *   Hospital B's database finds 210 patients and returns the number `210`.
    *   Hospital C's database finds 95 patients and returns the number `95`.
4.  **Central Aggregation:** Our central node receives these three numbers and aggregates them, presenting the final answer to the researcher: `455`.

Crucially, no patient-level data ever left any of the hospitals. The privacy of every individual is preserved, yet the researcher gets the powerful, multi-site insight they need.

### Technical Strategies for Building Trust

Making this work reliably requires more than just FDWs. We've learned that a few key technical strategies are essential for earning the trust of hospital IT and security teams:

*   **Containerized Query Engines:** We package our analysis tools and query runners into secure, isolated containers (e.g., using Docker). This ensures that only pre-approved, audited code can be executed within the hospital's environment, preventing any possibility of unauthorized data access.
*   **On-Site Execution and Auditing:** All SQL execution happens on the hospital's own infrastructure. They have full visibility and can log every single query that is run against their database, providing a complete audit trail.
*   **Role-Based Access and Aggregation Rules:** We enforce strict rules about the granularity of results. Queries that could potentially re-identify individuals (e.g., asking for a count that returns a result of "1") are automatically blocked. All results are aggregated to a safe, anonymous level.

Building a federated network is as much a social and political challenge as it is a technical one. It requires a deep commitment to transparency and a technical architecture that makes privacy the default. By bringing the analytics to the data, we can create a powerful ecosystem for research that doesn't force hospitals—or patients—to compromise on security.
