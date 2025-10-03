# Panic Attack Data Analysis (Power BI + Snowflake)

![](.images/panic-attack-png-image.png)

## What are Panic Attacks?

A **Panic Attack** is a sudden, intense episode of **fear or discomfort** that peaks within minutes and includes strong physical and emotional symptoms. Common signs are a **racing heart, sweating, trembling, shortness of breath, chest pain, dizziness, fear of losing control**. Panic attacks can occur unexpectedly or be triggered by **stress, reminders of trauma, stimulants (like caffeine), or lack of sleep**. Repeated panic attacks that lead to persistent worry or behavior change may indicate **panic disorder** and should be evaluated by a **healthcare professional**.

 ---

## Overview

This project demonstrates how to analyze panic attack data for **educational purposes** using:

* Dataset from **Kaggle**
* **Snowflake** as a simple, user‑friendly data warehouse
* **Power BI** for visualization

The project shows patterns of panic attacks by **age group, triggers, symptoms, sleep hours, and lifestyle factors**.
 
 ---

## Workflow

1. **Collect dataset** from Kaggle.
2. **Upload to Snowflake** using web UI (easy drag‑and‑drop, staging, and table creation with wizards).
3. **Validate data** quickly inside Snowflake & create some insights by SQL.
4. **Connect Power BI** to Snowflake using the built‑in connector.
5. **Build dashboard** with visuals and filters in just a few clicks.

 ---

## Screenshots & Insights

* **Age Group Analysis** – Simple Snowflake data upload makes it easy to slice data by age.
  ![Age Group Analysis](.images/Age_Group_Analysis.png)

* **Filters & Lifestyle Factors** – With Snowflake’s clean integration, Power BI filters (e.g., drinks per week) are instantly usable.
  ![Time Series & Filters](.images/Other_Recurement.png)

* **Symptoms Breakdown** – Snowflake tables power clear visualizations of patient symptoms in Power BI.
  ![Patients by Symptoms](.images/Patients_by_symptoms.png)

 ---

## Educational Note

Snowflake is highlighted here for its **ease of use** – from loading data without code to connecting seamlessly with Power BI.
This dataset is intended **only for learning**. If sharing results, cite the original Kaggle dataset.

 ---

**Author:** Anjan Paul
**Academy:** /[Data Space Academy]