-- 1. Create a workspace for our project
CREATE DATABASE hospital_audit;
USE hospital_audit;

CREATE TABLE diabetic_data (
    encounter_id TEXT, patient_nbr TEXT, race TEXT, gender TEXT, age TEXT, weight TEXT,
    admission_type_id TEXT, discharge_disposition_id TEXT, admission_source_id TEXT,
    time_in_hospital TEXT, payer_code TEXT, medical_specialty TEXT, num_lab_procedures TEXT,
    num_procedures TEXT, num_medications TEXT, number_outpatient TEXT, number_emergency TEXT,
    number_inpatient TEXT, diag_1 TEXT, diag_2 TEXT, diag_3 TEXT, number_diagnoses TEXT,
    max_glu_serum TEXT, A1Cresult TEXT, metformin TEXT, repaglinide TEXT, nateglinide TEXT,
    chlorpropamide TEXT, glimepiride TEXT, acetohexamide TEXT, glipizide TEXT, glyburide TEXT,
    tolbutamide TEXT, pioglitazone TEXT, rosiglitazone TEXT, acarbose TEXT, miglitol TEXT,
    troglitazone TEXT, tolazamide TEXT, examide TEXT, citoglipton TEXT, insulin TEXT,
    `glyburide-metformin` TEXT, `glipizide-metformin` TEXT, `glimepiride-pioglitazone` TEXT,
    `metformin-rosiglitazone` TEXT, `metformin-pioglitazone` TEXT, `change` TEXT,
    diabetesMed TEXT, readmitted TEXT
);
SET GLOBAL LOCAL_INFILE =1;
SHOW VARIABLES LIKE "secure_file_priv"; -- could not import local file data so i asked sql to brin a secur file loaction since it says i can execute because its runnin on secure file piv
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\diabetic_data.csv' 
INTO TABLE diabetic_data 
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. Check the count (It should be 0)
SELECT COUNT(*) FROM diabetic_data;

/* DATA CLEANING PHASE
Purpose: Transform the raw 'Text' import into a structured, analysis-ready table.
We are creating a VIEW so we don't change the raw data, but we see a 'clean' version of it.
*/

CREATE OR REPLACE VIEW cleaned_diabetic_data AS
SELECT 
    -- 1. Convert IDs to Integers for faster indexing
    CAST(encounter_id AS UNSIGNED) AS encounter_id,
    CAST(patient_nbr AS UNSIGNED) AS patient_id,

    -- 2. Handling Missing Categories
    -- If race is '?', we label it 'Other/Unknown' for professional reporting
    CASE WHEN race = '?' THEN 'Unknown' ELSE race END AS race,
    
    gender,
    age,

    -- 3. Weight is 98% missing, so we convert '?' to NULL
    -- NULL is better than '?' because SQL math functions (like AVG) ignore NULLs
    CASE WHEN weight = '?' THEN NULL ELSE weight END AS weight,

    -- 4. Convert Stay Time to a Number so we can calculate averages
    CAST(time_in_hospital AS UNSIGNED) AS stay_duration,

    -- 5. Clean Medical Specialty
    CASE WHEN medical_specialty = '?' THEN 'Unspecified' ELSE medical_specialty END AS specialty,

    -- 6. Convert Lab Procedures to a Number for correlation analysis
    CAST(num_lab_procedures AS UNSIGNED) AS num_lab_procedures,

    -- 7. Standardize Diagnosis Codes (fixing the '?' placeholders)
    CASE WHEN diag_1 = '?' THEN 'Unknown' ELSE diag_1 END AS primary_diagnosis,
    CASE WHEN diag_2 = '?' THEN 'Unknown' ELSE diag_2 END AS secondary_diagnosis,

    -- 8. Target Variable: Keep the raw text for the report
    readmitted

FROM diabetic_data;


-- Check new clean table
SELECT 
    race, age,
    specialty, 
    stay_duration 
FROM cleaned_diabetic_data 
LIMIT 10;

/* ANALYSIS: READMISSION RISK BY AGE
Purpose: Find the 'vulnerable' age groups to help the hospital prioritize follow-up care.
Logic: We use the cleaned 'readmitted' column to find the percentage of return cases.
*/
SELECT readmitted, COUNT(*) 
FROM cleaned_diabetic_data 
GROUP BY readmitted;
SELECT 
    age,
    COUNT(*) AS total_patients,
    -- Using 1.0 forces SQL to use decimal math so we get 11.34 instead of 0.00(interger division rule)
    ROUND(AVG(CASE WHEN readmitted LIKE '%<30%' THEN 1.0 ELSE 0.0 END) * 100, 2) AS readmit_rate_30_days
FROM cleaned_diabetic_data
GROUP BY age
ORDER BY age;


/* ANALYSIS: SPECIALTY PERFORMANCE AUDIT
Purpose: Identify which departments have the most stable patients (lowest readmission).
Logic: Filter for departments with at least 100 patients to ensure the data is reliable.
*/

SELECT 
    specialty,
    COUNT(*) AS visit_count,
   ROUND(AVG(CASE WHEN readmitted LIKE '%<30%' THEN 1.0 ELSE 0.0 END) * 100, 2) AS readmit_rate
FROM cleaned_diabetic_data
WHERE specialty != 'Unspecified'
GROUP BY specialty
HAVING visit_count > 100
ORDER BY readmit_rate DESC
LIMIT 5;
/* ANALYSIS: LAB PROCEDURES VS. STAY DURATION
Purpose: Evaluate if high lab intensity(ow many lab test) correlates with longer hospital stays.
Logic: We group the number of labs into categories to see a clear trend.
*/

SELECT 
    CASE 
        WHEN num_lab_procedures < 30 THEN 'Low (0-29)'
        WHEN num_lab_procedures BETWEEN 30 AND 60 THEN 'Medium (30-60)'
        ELSE 'High (60+)'
    END AS lab_intensity,
    ROUND(AVG(stay_duration), 2) AS avg_days_in_hospital,
    COUNT(*) AS patient_count
FROM cleaned_diabetic_data
GROUP BY Lab_intensity
ORDER BY avg_days_in_hospital ASC;

/* ANALYSIS: Clinical Intensity by Demographic
   Purpose: To determine if specific age groups receive more diagnostic 
   attention (lab tests) than others.
*/

SELECT 
    age,
    COUNT(*) AS total_patients, -- Total volume of patients in this age bracket
    -- We use AVG to normalize the data so large groups don't skew the results.
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures
    -- We group by age to see the 'Profile' of each bracket rather than individual patient rows.
FROM cleaned_diabetic_data 
GROUP BY age 
ORDER BY avg_lab_procedures DESC;

-- LETS SEE WHAT AGE STAYS MOST AND HENCE COST ThE HOSPITAL MORE
SELECT 
    age,
    ROUND(AVG(stay_duration), 2) AS avg_days_in_hospital,
    COUNT(*) AS patient_count
FROM cleaned_diabetic_data
GROUP BY age
ORDER BY avg_days_in_hospital DESC;

-- prove that cleaning worked
SELECT 
    COUNT(*) AS total,
    SUM(CASE WHEN weight IS NULL THEN 1 ELSE 0 END) AS missing_weights,
    AVG(stay_duration) AS avg_stay
FROM cleaned_diabetic_data;

SELECT * FROM cleaned_diabetic_data;

