# Hospital_Readmission_Analysis
MySQL project analyzing 100k+ diabetic patient records to identify clinical risk factors for 30-day readmissions.
# Hospital Readmission Clinical Audit

## 📝 Project Overview
This project focuses on identifying the clinical and demographic factors that lead to 30-day hospital readmissions for diabetic patients. Using a dataset of **101,766 records**, I performed a deep-dive SQL analysis to find patterns in patient age, medical specialty, and laboratory intensity.

**The Goal:** To provide data-driven recommendations that help hospitals reduce readmission rates and improve patient discharge protocols.

---

## 📂 Dataset Information
* **Source:** [UCI Machine Learning Repository](https://archive.ics.uci.edu/ml/datasets/Diabetes+130-US+hospitals+for+years+1999-2008)
* **Size:** 101,766 patient encounters across 130 US hospitals.
* **Attributes:** 55 clinical features (Demographics, Medications, Lab Results).

## 🛠️ Project Structure
* `/data`: Contains the raw diabetic patient dataset.
* `/scripts`: Contains SQL scripts for data cleaning, feature engineering, and exploratory analysis.
* `README.md`: Project summary and key findings.

## 📊 Key Insights Found
1. **Age Risk**: The **[20-30)** age group has the highest 30-day readmission rate at **14.24%**.
2. **Lab Intensity**: Patients receiving **60+ lab procedures** stay an average of **6.04 days**, compared to only 3.34 days for those with low lab volume.
3. **Department Efficiency**: Identified high-volume specialties that require optimized discharge protocols.

## 💻 SQL Techniques Used
* **Data Scrubbing**: Filtering noise using `!=` and `LIKE`.
* **Normalization**: Using `1.0` to convert integers to floats for accurate percentage calculations.
* **Feature Engineering**: Creating "Lab Intensity" buckets using `CASE` statements.
* **Statistical Filtering**: Using `HAVING count(*) > 100` to ensure reliable averages.
