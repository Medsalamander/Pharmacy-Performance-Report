![Power BI](https://img.shields.io/badge/PowerBI-F2C811?style=flat&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=flat&logo=microsoft&logoColor=white)
![Excel](https://img.shields.io/badge/Excel-217346?style=flat&logo=microsoftexcel&logoColor=white)
![Healthcare](https://img.shields.io/badge/Healthcare-Analytics-00B4D8?style=flat)
![SQL](https://img.shields.io/badge/SQL_Server-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)



# Pharmacy Performance Report

## Table of Contents
- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning & Preparation](#data-cleaning--preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Dashboard](#dashboard)
- [Results & Findings](#results--findings)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [References](#references)

---

### Project Overview
Independent retail pharmacies in the United States are closing at a rate of roughly one per day. The core problem is a structural margin crisis: PBM reimbursement rates on generic drugs have fallen below pharmacy acquisition costs, retroactive DIR fee clawbacks destroy casg flow predictatbility, and rising prescription volume have become loss drivers rather than covering overhead.
This project builds a pharmacy analytics dashboard that answers three questions a pharmacy owner needs answered before walking into a PBM contract negotiation:

1. **Which payers and drugs are profitable - and which are quietly destroying the business?**
2. **What specific data-backed rate increases should be requested from each PBM?**
3. **Is the pharmacy's financial trajectory improving or deteriorating, and at what rate?**
   
 The analysis covers 5,000 NCPDP- style retail claims spanning January 2023 through December 2024, processed acrss 7 payer channels (CVS Caremark, Express Scripts, OptumRx, MedImpact, Medicare Part D, Medicaid, and Cash/Self-pay) at 4 Massachusetts pharmacy locations.


---

### Data Sources
rx_claims.csv - 5000 Retail Rx claims with 38 fields including NDC, AWP, WAC, AAC. MAC pricing, DIR fees, NCPDP reject codes, DAW codes, dospensing fees, per-claim net profit

**Key dimensions in `rx_claims.csv`:**

| Dimension | Count | Examples |
|-----------|-------|---------|
| Payers | 7 | CVS Caremark, Express Scripts, OptumRx, MedImpact, Medicare Part D, Medicaid, Cash/Self-Pay |
| Drugs (NDC) | 20 | Atorvastatin, Metformin, Lisinopril, Eliquis, Ozempic, Adalimumab, Adalimumab-adbm |
| Pharmacies | 4 | Main St Pharmacy, Westside Rx, Community Care Pharmacy, Health Plus Pharmacy |
| Patients | 115 | Chronic medication cohort, ~43.5 Rx per patient |
| Prescribers | 5 | Internal Medicine, Cardiology, Endocrinology, Primary Care, Oncology |
| Date range | 24 months | Jan 2023 – Dec 2024 |
| Claim statuses | 3 | PAID (4,375), REJECTED (389), REVERSED (236) |

**Additional table loaded via SQL Server:**

| Table | Rows | Description |
|-------|------|-------------|
| `Payer_Negotiation` | 7 | Aggregated payer-level metrics: avg reimbursement, avg AAC, avg net profit, variance from benchmark, rate increase needed — loaded via SQL Server advanced query |

| Table | Rows | Description |
|-------|------|-------------|
| `Payer_Negotiation` | 7 | Aggregated payer-level metrics: avg reimbursement, avg AAC, avg net profit, variance from benchmark, rate increase needed — loaded via SQL Server advanced query |
---

### Tools

| Tool | Purpose |
|------|---------|
| **SQL Server** | Claims querying, rejection analysis, payer profitability, concurrent payer detection via self-joins, patient profitability ranking with window functions, contract negotiation brief generation with benchmark variance and rate increase calculations |
| **Microsoft Excel** | Reimbursement model prototyping, payer comparison matrices, KPI dashboard with conditional formatting and benchmarks, pivot tables for drug and payer profitability, monthly trend charts with dual-axis visualization |
| **Power BI Desktop** | Production dashboard: 4 interactive pages, 8 DAX measures, dynamic CALENDARAUTO() date table, conditional formatting, rolling average trend analysis, YoY comparison, bubble chart payer strategy matrix, contract intelligence table |
| **Power Query** | Data ingestion, automatic type detection, column quality profiling, query renaming |
| **DAX** | 8 custom measures including time intelligence (SAMEPERIODLASTYEAR, DATESINPERIOD), safe division (DIVIDE), filtered aggregations (CALCULATE), and context removal (ALL) |
| **Python** | Dataset generation, K-Means clustering for drug portfolio segmentation (scikit-learn), cross-tool validation of calculations |


---

### Data Cleaning & Preparation

**Power Query (data loading):**
1. Loaded `rx_claims.csv` through Get Data - Text/csv - Transform Data
2. Automatic type detection correctly identified all 38 columns FILL_DATE as Date
3. Column quality profiling confirmed: 100% valid, 0% errors, 0% empty across all critical columns

**Excel Validation (pre-Power BI):**
1. Row count: `=COUNTA(A:A)-1` ➡️ 5,00 CONFIRMED
2. Missing values: `=COUNTBLANK()` on CLAIM_ID, FILL_DATE, NDC, PAYER_NAME, NET_PROFIT - all returned 0
3. Duplicate check: COUNTIF-based analysis confirmed 0 duplicate CLAIM_IDs
4. Date format: Text-to-Columns conversion from left-aligned text to right-aligned true date values

**Data model (Power BI):**
1. Dynnamic date table created via `CALENDARAUTO()` with `ADDCOLUMNS` ➡️ 731 rows, 8 columns (Date, Year, Month_Num, Year_Month, Quarter, Day_of_Week, Is_Weekend, Sort_key)
2. Relationship established: `Date_Table[Date] ➡️ `Claims[FILL_DATE` (one-to-many)
3. Payer_Negotiation table loaded via SQL Server advanced query
4. Date_Table marhed as official date table for time intelligence
5. _Measures table created to organize all DAX measures centrally.


---

### Exploratory Data Analysis


---


### Data Analysis


---

### Dashboard

---


### Results & Findings


---


### Recommendations


---


### Limitations

---


### References


