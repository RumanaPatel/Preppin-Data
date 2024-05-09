/*
  Logic
- Split the Flight Details field to form structured columns:  
  `Date`, `Flight Number`, `From`, `To`, `Class`, `Price`
- Convert data fields to appropriate types:
  - `Date` to a date format
  - `Price` to a decimal value
- Change the Flow Card field to Yes/No values instead of 1/0
- Create two tables:
  - One for Flow Card holders
  - One for non-Flow Card holders
*/

-- Step 1: Create or Replace the Flights Split Table
CREATE OR REPLACE TABLE `preppin-data-422814.2024_challenges.2024_w1_prep_air_flights_split` AS (
  WITH Flight_Details_Split AS (
    SELECT
      SPLIT(Flight_Details, '//') AS Details,
      Flight_Details,
      Flow_Card_,
      Bags_Checked,
      Meal_Type  
    FROM `preppin-data-422814.2024_challenges.2024_w1_prep_air_flights`
  )
  SELECT
    -- Extract and parse individual fields from the split array
    PARSE_DATE('%Y-%m-%d', Details[0]) AS Date,
    Details[1] AS Flight_Number,
    SPLIT(Details[2], '-')[OFFSET(0)] AS From_City,
    SPLIT(Details[2], '-')[OFFSET(1)] AS To_City,
    Details[3] AS Class,
    CAST(Details[4] AS FLOAT64) AS Price,
    -- Convert Flow Card field to Yes/No
    CASE 
      WHEN Flow_Card_ = 1 THEN 'Yes'
      WHEN Flow_Card_ = 0 THEN 'No'
      ELSE 'Check'
    END AS Flow_Card_Holder,
    Bags_Checked,
    Meal_Type
  FROM Flight_Details_Split
);

-- Step 2: Create or Replace the Table for Loyalty Card Holders
CREATE OR REPLACE TABLE `preppin-data-422814.2024_challenges.2024_w1_loyalty_card_holders` AS (
  SELECT
    Date,
    Flight_Number,
    From_City,
    To_City,
    Class,
    Price,
    Flow_Card_Holder,
    Bags_Checked,
    Meal_Type
  FROM `preppin-data-422814.2024_challenges.2024_w1_prep_air_flights_split`
  WHERE Flow_Card_Holder = 'Yes'
);

-- Step 3: Create or Replace the Table for Non-Loyalty Card Holders
CREATE OR REPLACE TABLE `preppin-data-422814.2024_challenges.2024_w1_non_loyalty_card_holders` AS (
  SELECT
    Date,
    Flight_Number,
    From_City,
    To_City,
    Class,
    Price,
    Flow_Card_Holder,
    Bags_Checked,
    Meal_Type
  FROM `preppin-data-422814.2024_challenges.2024_w1_prep_air_flights_split`
  WHERE Flow_Card_Holder = 'No'
);

-- Step 4: Verify Outputs
-- Count Flow Card Holders
SELECT
  COUNT(*)
FROM `preppin-data-422814.2024_challenges.2024_w1_loyalty_card_holders`;

-- Count Non-Flow Card Holders
SELECT
  COUNT(*)
FROM `preppin-data-422814.2024_challenges.2024_w1_non_loyalty_card_holders`;
