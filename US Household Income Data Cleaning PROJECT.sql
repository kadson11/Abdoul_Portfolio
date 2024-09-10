## US HOUSEHOLD PROJECT 

   ### PART 1 DATA CLEANING 

SELECT COUNT(id) 
FROM US_Household_Project.us_household_income_statistics
;

SELECT COUNT(id)
FROM US_Household_Project.USHouseholdIncome
;

SELECT *
FROM US_Household_Project.USHouseholdIncome
;
 
# Identifying Duplicates in the US Household Income table

SELECT id, COUNT(id)
FROM US_Household_Project.USHouseholdIncome
GROUP BY id
HAVING COUNT(id) > 1
;
SELECT id, COUNT(id)
FROM US_Household_Project.USHouseholdIncome
GROUP BY id
HAVING COUNT(id) > 1

# Identifying duplicates using window function ROW_NUMBER() 

SELECT *
FROM(
SELECT row_id,
id, 
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
FROM US_Household_Project.USHouseholdIncome) 
AS table_row
WHERE row_num >1 
;

# Deleting the duplicates in the Household Income Table

DELETE FROM USHouseholdIncome
WHERE row_id IN (
	SELECT row_id
	FROM(
		SELECT row_id,
		id, 
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
		FROM US_Household_Project.USHouseholdIncome
        ) AS table_row
	WHERE row_num >1)						
;

# Identifying Duplicates in the US Household Income statistics table

SELECT id, COUNT(id) 
FROM US_Household_Project.us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1
;
## We don't have any duplicates in this table so we are good to go 

## Standardizing the state_Name column to have everything look the same 

SELECT DISTINCT(State_Name)
FROM USHouseholdIncome
ORDER BY 1
;

UPDATE USHouseholdIncome
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE USHouseholdIncome
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

# Dealing with a Null Value in the Place column 

SELECT *
FROM USHouseholdIncome
WHERE County = 'Autauga County'
ORDER BY 1
;

UPDATE USHouseholdIncome
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;

## Standardizing the Type column 

SELECT Type, COUNT(Type)
FROM USHouseholdIncome
GROUP BY Type
##ORDER BY 1
;

UPDATE USHouseholdIncome
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

UPDATE USHouseholdIncome
SET Type = 'CDP'
WHERE Type = 'CPD'
;


## Checking the ALand and Awater columns to find any blank or Null values 

SELECT ALand, AWater
FROM USHouseholdIncome
WHERE AWater IN (0,'', NULL)
;

SELECT ALand, AWater
FROM USHouseholdIncome
WHERE ALand IN (0,'', NULL)
;










 