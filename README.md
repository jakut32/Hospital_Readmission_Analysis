# Hospital_Readmission_Analysis
MySQL project analyzing 100k+ diabetic patient records to identify clinical risk factors for 30-day readmissions.
# Hospital Readmission Clinical Audit

## 📂 Project Overview
This project analyzes a healthcare dataset to identify why diabetic patients are readmitted to the hospital within 30 days. This is a critical metric for hospital efficiency and patient care quality.

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
