
--Store Procedure to update a column in the table based on certain conditions and then alter the data type of that column to bit. 
CREATE PROCEDURE ConvertColumnTypes
	@Column VARCHAR(50)
AS
BEGIN
UPDATE [PatientDb].[dbo].patient_table
SET @Column = CASE WHEN @Column = 'Yes' THEN 1
								 WHEN @Column = 'No' THEN 0
								 ELSE @Column END;

DECLARE @AlterQuery NVARCHAR(MAX);
SET @AlterQuery = 'ALTER TABLE dbo.patient_table
					ALTER COLUMN' + QUOTENAME(@Column) + 'bit';
EXEC sp_executesql @AlterQuery
END;

EXEC ConvertColumnTypes @ColumnName = 'Family_History_of_OCD';
EXEC ConvertColumnTypes @ColumnName = 'Depression_Diagnosis';
EXEC ConvertColumnTypes @ColumnName ='Anxiety_Diagnosis';

-- Check Null Values
SELECT * FROM [PatientDb].[dbo].[patient_table]
WHERE Patient_ID IS NULL
	OR Age IS NULL
	OR Gender IS NULL
	OR Ethnicity IS NULL
	OR Marital_Status IS NULL
	OR Education_Level IS NULL
	OR OCD_Diagnosis_Date IS NULL
	OR Duration_of_Symptoms_months IS NULL
	OR Previous_Diagnoses IS NULL
	OR Family_History_of_OCD IS NULL
	OR Obsession_Type IS NULL
	OR Compulsion_Type IS NULL
	OR Y_BOCS_Score_Obsessions IS NULL
	OR Y_BOCS_Score_Compulsions IS NULL
	OR Depression_Diagnosis IS NULL
	OR Anxiety_Diagnosis IS NULL
	OR Medications IS NULL;

-- 1. Count of F vs M that have OCD & -- Average Obsession Score By Gender
WITH CTE AS(
	SELECT 
		Gender,
		COUNT(Patient_ID) AS patient_count,
		ROUND(AVG(Y_BOCS_Score_Obsessions),2) AS obs_score
	FROM [PatientDb].dbo.patient_table
	GROUP BY Gender
)
SELECT 
	SUM(CASE WHEN Gender = 'Male' THEN patient_count END) AS male_count,
	SUM(CASE WHEN Gender = 'Female' THEN patient_count END) AS female_count,
	SUM(CASE WHEN Gender = 'Male' THEN patient_count END) * 100.0 / (SUM(CASE WHEN Gender = 'Male' THEN patient_count END) + SUM(CASE WHEN Gender = 'Female' THEN patient_count END)) AS male_percent,
	SUM(CASE WHEN Gender = 'Female' THEN patient_count END) * 100.0 / (SUM(CASE WHEN Gender = 'Male' THEN patient_count END) + SUM(CASE WHEN Gender = 'Female' THEN patient_count END)) AS female_percent
FROM CTE;


 
-- 2. Count & Average Obsession Score of Ethenicities that have OCD
SELECT 
	Ethnicity,
	COUNT(Patient_ID) AS patient_count,
	AVG(Y_BOCS_Score_Obsessions) AS obs_score
FROM [PatientDb].dbo.patient_table
GROUP BY Ethnicity
ORDER BY patient_count;

-- 3. Number of people diagosed MoM
SELECT 
	FORMAT(OCD_Diagnosis_Date, 'yyyy-MM-01 00:00:00') AS month,
	COUNT(Patient_ID) AS patient_count
FROM [PatientDb].dbo.patient_table
GROUP BY FORMAT(OCD_Diagnosis_Date, 'yyyy-MM-01 00:00:00')
ORDER BY FORMAT(OCD_Diagnosis_Date, 'yyyy-MM-01 00:00:00');


-- 4. What is the most common Obsession Type (Count) & it's respective Average Obsession Score
SELECT 
	Obsession_Type,
	COUNT(Patient_ID) AS patient_count,
	AVG(Y_BOCS_Score_Obsessions) AS obs_score
FROM [PatientDb].dbo.patient_table
GROUP BY Obsession_Type
ORDER BY patient_count;

-- 5. What is the most common Compulsion type (Count) & it's respective Average Compulsion Score
SELECT 
	Compulsion_Type,
	COUNT(Patient_ID) AS patient_count,
	AVG(Y_BOCS_Score_Compulsions) AS com_score
FROM [PatientDb].dbo.patient_table
GROUP BY Compulsion_Type
ORDER BY patient_count;