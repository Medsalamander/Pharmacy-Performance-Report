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
1. Dynamic date table created via `CALENDARAUTO()` with `ADDCOLUMNS` ➡️ 731 rows, 8 columns (Date, Year, Month_Num, Year_Month, Quarter, Day_of_Week, Is_Weekend, Sort_key)
2. Relationship established: `Date_Table[Date] ➡️ `Claims[FILL_DATE]` (one-to-many)
3. Payer_Negotiation table loaded via SQL Server advanced query
4. Date_Table marhed as official date table for time intelligence
5. _Measures table created to organize all DAX measures centrally.


---

### Exploratory Data Analysis

Questions investigated through SQL, Excel, and Power BI:

- What is the pharmacy's true net profit on 5,000 claims and $1.7M gross reimbursement?
- Which payers are the profitable and which are destroying value - and by how much?
- Are generic drugs or brand drugs driving profitability?
- What is the per-claim financial impact of DIR fees on Medicare Part D?
- Which individual drug should be eliminated immediately?
- How does the pharmacy's profitability trajectory look 2023 vs 2024?
- What specific contract rate increases should be requested from each PBM?
- Are patients using multiple payers concurrently or sequentially?


---


### Data Analysis

**SQL - Payer Contract Negotiation Brief:**

```sql
SELECT 
	PAYER_NAME,
	COUNT(*) AS rx_volume,
	ROUND(AVG(TOTAL_REIMB),2) AS avg_reimbursement,
	ROUND(AVG(AAC),2) AS avg_aac,
	ROUND(AVG(NET_PROFIT),2) AS avg_net_profit,
	ROUND(AVG(TOTAL_REIMB) - AVG(AVG(TOTAL_REIMB)) OVER(),2) AS variance_from_avg,
	CASE
		WHEN ((AVG(AAC) * 1.05 + 1.75) - AVG(TOTAL_REIMB)) / AVG(TOTAL_REIMB) <= 0
		THEN 'No Increase Needed'
		ELSE CAST(ROUND(
			((AVG(AAC) * 1.05 + 1.75) - AVG(TOTAL_REIMB)) / AVG(TOTAL_REIMB)
			,4) AS VARCHAR(20))
		END AS rate_increase_needed_pct
FROM dbo.rx_claims
WHERE CLAIM_STATUS = 'PAID'
GROUP BY PAYER_NAME
ORDER BY avg_net_profit DESC
```

**DAX - Measures Created:**

```dax
Total Rx Volume =
COUNTROWS(FILTER(Claims, Claims[CLAIM_STATUS] = "PAID"))

Gross Reimbursement =
CALCULATE(SUM(Claims[TOTAL_REIMB]), Claims[CLAIM_STATUS] = "PAID")

Total Net Profit =
CALCULATE(SUM(Claims[NET_PROFIT]), Claims[CLAIM_STATUS] = "PAID")

Avg Net Profit per Rx =
DIVIDE([Total Net Profit], [Total Rx Volume], 0)

GDR =
DIVIDE(
    CALCULATE(COUNTROWS(Claims),
        Claims[CLAIM_STATUS] = "PAID",
        Claims[IS_BRAND] = FALSE()),
    CALCULATE(COUNTROWS(Claims),
        Claims[CLAIM_STATUS] = "PAID"),
    0)

Rejection Rate =
DIVIDE(
    COUNTROWS(FILTER(Claims, Claims[CLAIM_STATUS] = "REJECTED")),
    COUNTROWS(Claims),
    0)
Rolling 3M Avg Profit per Rx =
DIVIDE(
    CALCULATE([Total Net Profit],
        DATESINPERIOD(Date_Table[Date],
            LASTDATE(Date_Table[Date]), -3, MONTH)),
    CALCULATE([Total Rx Volume],
        DATESINPERIOD(Date_Table[Date],
            LASTDATE(Date_Table[Date]), -3, MONTH)),
    0)

Net Profit YoY Change =
VAR CurrentYear = [Total Net Profit]
VAR PriorYear =
    CALCULATE([Total Net Profit],
        SAMEPERIODLASTYEAR(Date_Table[Date]))
RETURN DIVIDE(CurrentYear - PriorYear, ABS(PriorYear), 0)

```

**DAX - Dynamic Date Table:**

```dax
Date_Table =
ADDCOLUMNS(
    CALENDARAUTO(),
    "Year",        YEAR([Date]),
    "Month_Num",   MONTH([Date]),
    "Month_Name",  FORMAT([Date], "MMM"),
    "Year_Month",  FORMAT([Date], "MMM-YYYY"),
    "Quarter",     "Q" & QUARTER([Date]),
    "Day_of_Week", FORMAT([Date], "DDD"),
    "Is_Weekend",  IF(WEEKDAY([Date], 2) >= 6, "Weekend", "Weekday"),
    "Sort_Key",    YEAR([Date]) * 100 + MONTH([Date])
)
```

---

### Dashboard

The dashboards consists of 4 interactive pages connected by a page navigayor, with a date range slice (Jan 2023 - Dec 2024) persisting across all pages.

**Page 1 - Executive Summary**

**Page 2 - Monthly Trends**

**Page 3 - Payer Performance**

**Page 4 - Contract Intelligence**

---


### Results & Findings

**1. Near-Zero Net Margin**
- $1,699,890 gross reimbursement across 4,375 paid claims produced a net loss of **-$2,987** - a **-0.18% net margin**
- Average net profit per prescription: **-$0.68**

**2. Universal Generic Drug Losses**
- Generic drugs lose money under **every** commercial PBM
- Total generic losses: **-$88,250** vs total brand profits: **$85,263**
- Net result: **-$2,987** - brand profits are being enitrely consumed by generic losses

**3. Biosimilar Burning Platform**
- Adalimumab-adbm (Humira biosimilar): **-$86,017** total loss at **-$1,162 per claim**
- One drug accounts for **94.8%** of all drug-level losses
- K-means clustering algorithm independently isolated this drug into its own cluster

**4. Medicare Part D DIR Destruction**
- Average net loss of **-$17.54 per claim** under Medicare Part D



---


### Recommendations


---


### Limitations

---


### References


