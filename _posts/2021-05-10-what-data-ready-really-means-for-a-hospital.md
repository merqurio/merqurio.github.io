---
layout: post
title: "What \"Data Ready\" Really Means for a Hospital"
date: 2021-05-10 09:00:00 +0100
tags:
  - omop
  - data-mapping
  - etl
  - ehden
  - collaboration
---

The vision of a federated data network is powerful, but the reality is built on a foundation of meticulous, often challenging, on-the-ground work. Bringing a new hospital into our network is far more than a technical integration; it's a process of change management, trust-building, and deep collaboration.

Having recently onboarded our first few partner hospitals, I wanted to share some key lessons from the front lines of data mapping and what it truly means to prepare a hospital for the data space.

### The Goal: Achieving Data Space Readiness

Onboarding isn't just about converting data. It's about elevating a hospital's data infrastructure to a state of "readiness" across several key dimensions. We've formalized this into a framework that guides our process:

1.  **Technical Readiness:** This is the foundation. It involves the core ETL (Extract, Transform, Load) work of activating all relevant data sources—from the EHR to LIS and RIS systems—and normalizing them to the OMOP Common Data Model. This ensures all data, regardless of its origin, is structured and standardized.

2.  **AI Readiness:** This layer expands the data space by incorporating the 80% of information locked in unstructured text. It involves deploying our NLP pipelines to extract and normalize entities from clinical notes and integrating automated terminology mapping (ATM) to handle non-standard structured codes.

3.  **Mediation Readiness:** A hospital must be prepared to engage with the research ecosystem. This involves establishing clear internal workflows for approving data requests, managing contracts with industry stakeholders, and participating in the governance of multi-center research projects.

4.  **Compliance Readiness:** Finally, all of this must be built on a rock-solid foundation of legal and ethical compliance. This means having a Master Services Agreement (MSA) in place, robust processes for data pseudonymization for data holders, and ensuring data is safely anonymized for data users.

### Lessons Learned in Collaboration

Achieving this multi-faceted readiness is impossible to do in a vacuum. Close collaboration with the hospital's IT department and clinical staff is not just helpful—it's essential.

*   **Data Dictionaries are a Starting Point, Not the Gospel:** While source data dictionaries are invaluable, they often don't reflect the on-the-ground reality of how data is entered. Only through iterative discussions with the people who use the systems every day can we uncover the nuances needed for an accurate mapping.
*   **Show, Don't Just Tell:** The value of becoming "data-ready" can feel abstract. We found that conducting training sessions and demonstrating the kinds of cross-hospital queries that become possible *after* the process was a powerful way to get buy-in and build excitement among both IT staff and researchers.
*   **Iterative Validation is Key:** We don't just map the data and call it a day. Our process involves continuous data quality checks and validation loops. We generate reports and dashboards that we review with the hospital team to spot anomalies and refine the mapping logic.

### Turbocharging the Process with EHDEN

Our journey has been significantly accelerated by our participation in the **European Health Data & Evidence Network (EHDEN)**. The EHDEN community has created a suite of open-source tools and best practices specifically for OMOP mapping. Leveraging these tools, and the expertise of the wider network, has allowed us to standardize our own processes and onboard new partners far more efficiently.

Onboarding a hospital is a partnership. It requires patience, clear communication, and a shared commitment to the vision of creating high-quality, research-ready data. It's challenging work, but seeing a partner achieve full data space readiness makes it all worthwhile.
