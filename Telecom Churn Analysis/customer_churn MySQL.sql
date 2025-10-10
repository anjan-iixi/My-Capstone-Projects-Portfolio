-- Create the database if not exists
CREATE DATABASE IF NOT EXISTS `telecom_churn_db`;
-- DROP DATABASE `telecom_churn_db`;
USE `telecom_churn_db`;
-- DROP TABLE telecom_churn;
-- Create the table with an appropriate schema
CREATE TABLE telecom_churn(
    CustomerID VARCHAR(25) PRIMARY KEY,
    Gender VARCHAR(10),
    SeniorCitizen INT, -- This is 0 or 1 in the data
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    Tenure INT,   -- tenure 0 means that the customer has not stayed with the company for a month
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(25),
    InternetService VARCHAR(25),
    OnlineSecurity VARCHAR(25),
    OnlineBackup VARCHAR(25),
    DeviceProtection VARCHAR(25),
    TechSupport VARCHAR(25),
    StreamingTV VARCHAR(25),
    StreamingMovies VARCHAR(25),
    Contract VARCHAR(25),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(50),
    MonthlyCharges DOUBLE,
    TotalCharges VARCHAR(20), -- Make VARCHAR first to handle empty strings, we will clean this later
    Churn VARCHAR(5)
);
SELECT * FROM telecom_churn;

-- SET SQL_SAFE_UPDATES = 0;
SELECT DISTINCT TotalCharges  -- Check what value it actually has
FROM telecom_churn
WHERE TotalCharges IS NULL OR TotalCharges = '' OR TRIM(TotalCharges) = ''; 

UPDATE telecom_churn SET TotalCharges = '0'
WHERE TRIM(TotalCharges) = '' OR TotalCharges IS NULL;
ALTER TABLE telecom_churn MODIFY COLUMN TotalCharges DECIMAL(10,2);

-- Calculate Age for Each Customer
SELECT 
    CustomerID,
    SyntheticDOB,
    TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) AS Age,
    MonthlyCharges,
    TotalCharges,
    Churn
FROM telecom_churn
LIMIT 20;

-- 1. To calculate the overall churn rate of the entire customer base
SELECT
   COUNT(*) AS Total_Customers,
   SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END) AS Total_Churned,
   100 * SUM(CASE WHEN Churn = "Yes" THEN 1 ELSE 0 END) / COUNT(*) AS ChurnRate_Percent
FROM telecom_churn;

-- 2. Compare churn rates between genders
SELECT 
    Gender,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Total_Churned,
	100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS ChurnRate_Percent
FROM telecom_churn
GROUP BY Gender;

-- 3. Identify the customers who have paid the highest total charges but still churned
SELECT 
   CustomerID, TotalCharges, Churn
FROM 
   telecom_churn
WHERE 
   Churn = "Yes"
ORDER BY 
   TotalCharges DESC
LIMIT 10;

-- 4. Identify which churned customers used fiber optic in Internet Service   
SELECT 
    CustomerID, InternetService, Churn
FROM
    telecom_churn
WHERE
    Churn = "Yes" AND InternetService = "Fiber optic"
LIMIT 10;

-- 5. Count of churned customers by payment method
SELECT PaymentMethod, COUNT(*) AS Churned_Count
FROM telecom_churn
WHERE Churn = 'Yes'
GROUP BY PaymentMethod
ORDER BY Churned_Count DESC;

-- 6. Top 10 customers by revenue per month (Lfe time value)
SELECT CustomerID, Tenure, TotalCharges, Churn,
  CASE WHEN Tenure > 0 THEN TotalCharges / Tenure 
  ELSE TotalCharges END AS Revenue_Per_Month
FROM telecom_churn
ORDER BY Revenue_Per_Month DESC
LIMIT 10;

-- 7. High-value and short-tenure customers who churned
SELECT CustomerID, Tenure, TotalCharges, Churn
FROM telecom_churn
WHERE Tenure < 6 AND TotalCharges > 400 AND Churn = 'Yes'
ORDER BY TotalCharges DESC
LIMIT 20;
   
-- 8. churn vs retained revenue & counts inside each age group
SELECT
  CASE
    WHEN TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) BETWEEN 18 AND 30 THEN '18-30'
    WHEN TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) BETWEEN 31 AND 55 THEN '31-55'
    WHEN TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) BETWEEN 56 AND 70 THEN '56-70'
    ELSE '70+'
  END AS Age_Group,
  Churn,
  COUNT(*) AS Customers_count,
  ROUND(SUM(TotalCharges),2) AS Revenue
FROM telecom_churn
GROUP BY Age_Group, Churn
ORDER BY Age_Group, Churn DESC;

-- 9.  Avg Monthly Charges for Churned vs Retained Customers
SELECT 
    Churn,
    ROUND(AVG(MonthlyCharges), 2) AS Avg_Monthly_Charges
FROM telecom_churn
GROUP BY Churn;

-- 10.  Total Churn and churn rate by Tenure category
SELECT 
    CASE 
        WHEN Tenure <= 12 THEN '0-12 Months'
        WHEN Tenure <= 24 THEN '12-24 Months'
        WHEN Tenure <= 36 THEN '24-36 Months'
        WHEN Tenure <= 48 THEN '36-48 Months'
        WHEN Tenure <= 60 THEN '48-60 Months'
        ELSE '60+ Months'
    END AS Tenure_Category,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Total_Churned,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS ChurnRate_Percent
FROM telecom_churn
GROUP BY Tenure_Category
ORDER BY Total_Churned DESC;

-- 11. Customers who bought many services but still churned
SELECT CustomerID, Tenure, MonthlyCharges, TotalCharges, Churn,
  (CASE WHEN PhoneService = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN MultipleLines = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN OnlineSecurity = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN OnlineBackup = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN DeviceProtection = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN TechSupport = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN StreamingTV = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN StreamingMovies = 'Yes' THEN 1 ELSE 0 END) AS Num_of_services
FROM telecom_churn
WHERE Churn = 'Yes'
ORDER BY TotalCharges DESC
LIMIT 10;

-- 12. churn for payment method and paperless billing 
SELECT PaymentMethod, PaperlessBilling,
       COUNT(*) AS Total_Customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Total_Churned,
       100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS ChurnRate_Percent
FROM telecom_churn
GROUP BY PaymentMethod, PaperlessBilling
ORDER BY PaymentMethod;

-- 13. top 10 churned customers month-to-month contract and their high monthly charges 
SELECT CustomerID, Contract, Tenure, MonthlyCharges, TotalCharges, Churn
FROM telecom_churn
WHERE Contract = 'Month-to-month' AND Churn = "Yes"
ORDER BY MonthlyCharges DESC
LIMIT 10;

-- 14. Senior citizen churn comparison
SELECT SeniorCitizen, COUNT(*) 
AS Total_Customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS total_Churned,
       100 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) AS Churn_Rate_Pct
FROM telecom_churn
GROUP BY SeniorCitizen;

-- 15. customers who left within their first 12 months
SELECT CustomerID,
       Tenure,
       MonthlyCharges,
       TotalCharges,
       Churn
FROM telecom_churn
WHERE Churn = 'Yes' AND Tenure <= 12
ORDER BY TotalCharges DESC
LIMIT 20;
-----
SELECT COUNT(*) AS Churned_customers
FROM telecom_churn
WHERE Churn = "Yes" AND Tenure <=12;


-- 00. AgeGroup × InternetService × Contract (counts + churn)
SELECT
  CASE
    WHEN TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) BETWEEN 18 AND 30 THEN '18-30'
    WHEN TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) BETWEEN 31 AND 55 THEN '31-55'
    WHEN TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) BETWEEN 56 AND 70 THEN '56-70'
    ELSE '70+'
  END AS Age_Group,
  InternetService,
  Contract,
  COUNT(*) AS TotalCustomers,
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Count
FROM telecom_churn
GROUP BY 
  CASE
    WHEN TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) BETWEEN 18 AND 30 THEN '18-30'
    WHEN TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) BETWEEN 31 AND 55 THEN '31-55'
    WHEN TIMESTAMPDIFF(YEAR, SyntheticDOB, CURDATE()) BETWEEN 56 AND 70 THEN '56-70'
    ELSE '70+'
 END,
   InternetService,
   Contract
ORDER BY InternetService
LIMIT 100;

