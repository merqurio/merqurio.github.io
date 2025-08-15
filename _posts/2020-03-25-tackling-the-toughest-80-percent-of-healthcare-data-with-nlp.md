---
layout: post
title: "Tackling the Toughest 80% of Healthcare Data with NLP"
date: 2020-03-25 09:00:00 +0100
tags:
  - nlp
  - clinical-data
  - python
  - spacy
  - ai
---

An estimated 80% of all healthcare information is trapped in unstructured text: clinical notes, discharge summaries, radiology reports, and pathology results. This narrative data is a treasure trove of clinical nuance—symptoms, disease severity, social determinants of health, and treatment responses that are rarely captured in structured database fields.

At IOMED, we knew from day one that if we only processed the structured 10-20% of a patient's record, we'd be missing most of the story. To truly build a comprehensive view of the patient journey, we had to build a robust Natural Language Processing (NLP) pipeline capable of turning messy, human-generated text into clean, computable data.

### The Unique Challenge of Clinical Text

Processing clinical text is notoriously difficult. Unlike standard text analysis, healthcare notes are a minefield of unique challenges:

*   **Domain-Specific Language:** Clinicians use a dense shorthand of abbreviations, acronyms, and jargon (e.g., "pt c/o SOB, hx of MI").
*   **Typos and Errors:** Notes are often written quickly under time pressure, leading to frequent spelling mistakes and grammatical errors.
*   **Negation and Context:** Identifying a diagnosis is not enough; you have to know if it's a confirmed diagnosis, a suspected one, something from the patient's family history, or a condition that has been explicitly ruled out (e.g., "no evidence of malignancy").
*   **Compositionality:** Clinical observations are often dense and compositional, packing multiple distinct facts into a single sentence, such as: “lobulation at the apex of the left hemithorax along the mediastinal border is residual of slowly resolving hematoma.”

A simple keyword search is not just ineffective; it's dangerous. A naive model could easily mistake "family history of cancer" for a current diagnosis, leading to catastrophic errors in analysis.

### Our Approach: A Multi-Stage NLP Pipeline

Building a reliable clinical NLP system requires a layered, methodical approach. Here’s a high-level overview of the pipeline we developed:

1.  **De-identification:** The first and most critical step is to scrub all personally identifiable information (PII) from the text to ensure patient privacy.
2.  **Text Pre-processing:** We then clean and normalize the text, correcting typos, expanding abbreviations, and segmenting the document into sentences and tokens.
3.  **Named Entity Recognition (NER):** This is the core of the pipeline. We use a combination of rule-based systems and machine learning models, leveraging libraries like **spaCy**, to identify and classify key clinical entities (diagnoses, medications, procedures, etc.).
4.  **Contextual Analysis:** Once an entity is identified, we analyze its context. We run algorithms to detect negation ("patient denies chest pain"), uncertainty ("suggestive of pneumonia"), and subject (is the condition related to the patient or a family member?).

### From Entities to Verifiable Facts

Identifying entities is only half the battle. To make the information truly reliable, we must convert these extracted entities into discrete, verifiable statements, a process known in the research community as **fact decomposition**.

The goal is to break down complex sentences into "atomic facts"—concise, standalone statements that convey a single piece of information. For example, the sentence "The patient is a 58-year-old female with a history of hypertension" would be decomposed into:
*   The patient is 58 years old.
*   The patient is female.
*   The patient has a history of hypertension.

Our pipeline is designed to perform this decomposition. Once we have these atomic facts, we can perform the final, crucial step: **verification**. Each generated fact is treated as a hypothesis that must be entailed by the original source text. This ensures that every piece of structured data we generate is directly traceable and attributable to a specific statement in the clinical note, preventing hallucinations and ensuring the fidelity of the data.

### Closing the Loop: Normalization to OMOP

The final step is to map these verified, atomic facts to standard concepts in the OMOP vocabulary. "The patient has a history of hypertension" becomes a `condition_occurrence` entry with the appropriate `concept_id`. This allows us to systematically integrate the rich information from unstructured text into the structured OMOP CDM.

By closing this loop, we create a far more complete and accurate picture of the patient's health. It’s a complex engineering challenge, but this rigorous process of decomposition and verification is essential for unlocking the full potential of real-world data in a way that is both powerful and trustworthy.
