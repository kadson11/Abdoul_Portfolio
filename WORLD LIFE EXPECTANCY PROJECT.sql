## WORLD LIFE EXPECTANCY PROJECT 


# PART 1: DATA CLEANING 

SELECT *
FROM worldlife_expectancy
;	

## Identifying duplicates in our data 

SELECT Country, Year, CONCAT(Country, Year), COUNT( CONCAT(Country, Year))
FROM worldlife_expectancy
GROUP BY  Country, Year, CONCAT(Country, Year)
HAVING COUNT( CONCAT(Country, Year)) > 1
;	


## Before removing the duplicates we need to identify the ROW_IDs for those duplicates
## Therefore we will use a ROW_NUMBER and PARTITION BY to do that.

SELECT *
FROM (
	SELECT ROW_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM worldlife_expectancy
	) AS Table_row
    WHERE Row_Num > 1
    ;

## Removing duplicates 

DELETE FROM worldlife_expectancy
WHERE
	ROW_ID IN (
    SELECT ROW_ID
FROM (
	SELECT ROW_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM worldlife_expectancy
	) AS Table_row
    WHERE Row_Num > 1
    );

## DEALING WITH MISSING VALUES IN THE STATUS COLUMN

SELECT * 
FROM worldlife_expectancy
WHERE Status = ''
;	

SELECT * 
FROM worldlife_expectancy
WHERE Status IS NULL
;	

## Finding the the type of Status in the data 

SELECT DISTINCT(Status)
FROM worldlife_expectancy
WHERE Status != ''
;	

## Finding countries with a status = 'Developing'

SELECT DISTINCT(Country)
FROM worldlife_expectancy
WHERE Status = 'Developing'
;

UPDATE worldlife_expectancy
SET Status = 'Developing'
WHERE Country IN ( SELECT DISTINCT(Country)
				FROM worldlife_expectancy
				WHERE Status = 'Developing'); ## THIS update statement didn't work 
                
## Updating  the Status column for the developing countries

UPDATE  worldlife_expectancy t1
JOIN worldlife_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
; 


## Updating  the Status column for the developed countries

SELECT * 
FROM worldlife_expectancy
WHERE Country = 'United States of America'
;	

UPDATE  worldlife_expectancy t1
JOIN worldlife_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
; 
 
##  DEALING WITH MISSING VALUES IN THE LIFEEXPECTANCY COLUMN

SELECT * 
FROM worldlife_expectancy
WHERE Lifeexpectancy =''
;	

SELECT Country, Year, Lifeexpectancy
FROM worldlife_expectancy
#WHERE Lifeexpectancy =''
;	

## To populate the missing values in Lifeexpectancy we are going to do an average

SELECT t1.Country, t1.Year, t1.Lifeexpectancy,
		t2.Country, t2.Year, t2.Lifeexpectancy,
        t3.Country, t3.Year, t3.Lifeexpectancy,
        ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy)/2,1)
FROM worldlife_expectancy t1
JOIN worldlife_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN worldlife_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.Lifeexpectancy = ''
;	
 
 ### Updating the missing values in Lifeexpectancy column by calculating an average 
 
UPDATE worldlife_expectancy t1
JOIN worldlife_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN worldlife_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.Lifeexpectancy = ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy)/2,1)
WHERE t1.Lifeexpectancy = ''
;

    
    
    # PART 2 : EXPLORATORY DATA ANALYSIS 


SELECT * 
FROM worldlife_expectancy
;		    
    
## Let's check the Life expectancy for all countries by looking at the MIN & MAX  
## We also found some countries that zero life expectancies. 
# This must be a data quality issue that we will need to look further into.

SELECT Country, 
	MIN(Lifeexpectancy),
	MAX(Lifeexpectancy)
FROM worldlife_expectancy
GROUP BY Country
HAVING MIN(Lifeexpectancy) != 0
AND MAX(Lifeexpectancy) != 0
ORDER BY Country DESC
;		    
    
## Now let's check to see which countries had the best strides in terms of 
# life expectancy when looking at their lowest and highest point.

SELECT Country, 
	MIN(Lifeexpectancy),
	MAX(Lifeexpectancy),
    ROUND(MAX(Lifeexpectancy) - MIN(Lifeexpectancy),1) AS Life_Increase_Over_15_Years
FROM worldlife_expectancy
GROUP BY Country
HAVING MIN(Lifeexpectancy) != 0
AND MAX(Lifeexpectancy) != 0
ORDER BY Life_Increase_Over_15_Years 
; # Haiti & Zimbabwe really did well with a respective increase of 28 and 22 years 
   # over a period of 15 years. 

 ## Average Global Life expectancy per year 
SELECT Year, ROUND(AVG(Lifeexpectancy),2) AS Average_Life_Expectancy
FROM worldlife_expectancy
WHERE Lifeexpectancy <> 0
GROUP BY Year
ORDER BY Year
; 
    
## Checking the correlation between Life expectancy and countries GDPs
SELECT Country, ROUND(AVG(Lifeexpectancy),1) AS Life_Exp, ROUND(AVG(GDP)) AS GDP
FROM Worldlife_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC
;


SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END)AS High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN Lifeexpectancy ELSE NULL END)AS High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END)AS Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN Lifeexpectancy ELSE NULL END)AS Low_GDP_Life_Expectancy
FROM worldlife_expectancy
; ## There's a high correlation between GDP and Life expectancy. 
	 
    
SELECT * 
FROM worldlife_expectancy
;		 
    
## Looking at the status column to find the average life expectancy between developed and developing countries
SELECT status,COUNT(DISTINCT Country),ROUND(AVG(Lifeexpectancy),1) AS Average_Life_Expexctancy
FROM worldlife_expectancy
GROUP BY Status
; 


SELECT status, COUNT(DISTINCT Country)
FROM worldlife_expectancy
GROUP BY Status
;	
  
## Checking at the correlation between Life Expectancy and BMI 
SELECT Country, ROUND(AVG(Lifeexpectancy),1) AS Life_Exp, ROUND(AVG(BMI)) AS BMI
FROM Worldlife_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI ASC
;    
    

## CHECKING the total of adult mortality by country and year using a Rolling Total
SELECT Country,
		Year,
        Lifeexpectancy,
        AdultMortality,
        SUM(AdultMortality) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM worldlife_expectancy
WHERE Country LIKE '%United%'
;	
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     









