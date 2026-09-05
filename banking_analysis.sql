# generate a sql view
CREATE VIEW banking_analysis AS
SELECT
    `ï»¿Client ID` AS client_id,
    `Name` AS client_name,
    `Age` AS age,
    `Location ID` AS location_id,
    STR_TO_DATE(`Joined Bank`, '%d-%m-%Y') AS joined_bank,
    `Banking Contact` AS banking_contact,
    `Nationality` AS nationality,
    `Occupation` AS occupation,
    `Fee Structure` AS fee_structure,
    `Loyalty Classification` AS loyalty_classification,
    `Estimated Income` AS estimated_income,
    `Superannuation Savings` AS superannuation_savings,
    `Amount of Credit Cards` AS amount_of_credit_cards,
    `Credit Card Balance` AS credit_card_balance,
    `Bank Loans` AS bank_loans,
    `Bank Deposits` AS bank_deposits,
    `Checking Accounts` AS checking_accounts,
    `Saving Accounts` AS saving_accounts,
    `Foreign Currency Account` AS foreign_currency_account,
    `Business Lending` AS business_lending,
    `Properties Owned` AS properties_owned,
    `Risk Weighting` AS risk_weighting,
    `BRId` AS branch_id,
    `GenderId` AS gender_id,
    `IAId` AS ia_id
FROM banking;

#overall banking kpi analysis
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT client_id) AS unique_customers,

    ROUND(AVG(age), 2) AS avg_customer_age,
    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(SUM(bank_deposits), 2) AS total_bank_deposits,
    ROUND(SUM(bank_loans), 2) AS total_bank_loans,
    ROUND(SUM(business_lending), 2) AS total_business_lending,

    ROUND(SUM(checking_accounts), 2) AS total_checking_balance,
    ROUND(SUM(saving_accounts), 2) AS total_saving_balance,

    ROUND(SUM(credit_card_balance), 2) AS total_credit_card_balance
FROM banking_analysis;

#Total deposit type balance s vs lending
SELECT
    ROUND(
        SUM(
            bank_deposits +
            checking_accounts +
            saving_accounts +
            foreign_currency_account
        ), 2
    ) AS total_deposits,

    ROUND(
        SUM(
            bank_loans +
            business_lending +
            credit_card_balance
        ), 2
    ) AS total_lending,

    ROUND(
        SUM(
            bank_loans +
            business_lending +
            credit_card_balance
        )
        /
        NULLIF(
            SUM(
                bank_deposits +
                checking_accounts +
                saving_accounts +
                foreign_currency_account
            ), 0
        ) * 100,
        2
    ) AS loan_deposit_ratio
FROM banking_analysis;

# customer classification by loyalty classification
SELECT
    loyalty_classification,
    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS customer_percentage

FROM banking_analysis
GROUP BY loyalty_classification
ORDER BY total_customers DESC;

#loyalty segment financial performance
SELECT
    loyalty_classification,

    COUNT(*) AS customers,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(AVG(bank_deposits), 2) AS avg_bank_deposit,

    ROUND(AVG(bank_loans), 2) AS avg_bank_loan,

    ROUND(AVG(business_lending), 2) AS avg_business_lending,

    ROUND(
        AVG(
            bank_deposits +
            checking_accounts +
            saving_accounts +
            foreign_currency_account
        ), 2
    ) AS avg_total_deposit,

    ROUND(
        AVG(
            bank_loans +
            business_lending +
            credit_card_balance
        ), 2
    ) AS avg_total_lending

FROM banking_analysis
GROUP BY loyalty_classification
ORDER BY avg_total_deposit DESC;

#Fee structure analysis
SELECT
    fee_structure,
    COUNT(*) AS customers,

    ROUND(COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER(), 2) AS customer_percentage,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(AVG(bank_deposits), 2) AS avg_deposit,

    ROUND(AVG(bank_loans), 2) AS avg_loan

FROM banking_analysis
GROUP BY fee_structure
ORDER BY customers DESC;

#Nationality Analysis
SELECT
    nationality,
    COUNT(*) AS total_customers,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(SUM(bank_deposits), 2) AS total_deposits,

    ROUND(SUM(bank_loans), 2) AS total_loans,

    ROUND(AVG(risk_weighting), 2) AS avg_risk

FROM banking_analysis
GROUP BY nationality
ORDER BY total_customers DESC;

#age group analysis
SELECT
    CASE
        WHEN age <= 25 THEN '18-25'
        WHEN age <= 35 THEN '26-35'
        WHEN age <= 45 THEN '36-45'
        WHEN age <= 55 THEN '46-55'
        WHEN age <= 65 THEN '56-65'
        ELSE '66+'
    END AS age_group,

    COUNT(*) AS customers,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(AVG(bank_deposits), 2) AS avg_deposits,

    ROUND(AVG(bank_loans), 2) AS avg_loans,

    ROUND(AVG(risk_weighting), 2) AS avg_risk

FROM banking_analysis
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN '18-25' THEN 1
        WHEN '26-35' THEN 2
        WHEN '36-45' THEN 3
        WHEN '46-55' THEN 4
        WHEN '56-65' THEN 5
        ELSE 6
    END;
    
    #gender analysis
    SELECT
    gender_id,
    COUNT(*) AS customers,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(AVG(bank_deposits), 2) AS avg_deposits,

    ROUND(AVG(bank_loans), 2) AS avg_loans,

    ROUND(AVG(risk_weighting), 2) AS avg_risk

FROM banking_analysis
GROUP BY gender_id;

#Risk Analysis
SELECT
    risk_weighting,

    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS percentage,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(AVG(bank_loans), 2) AS avg_bank_loan,

    ROUND(AVG(business_lending), 2) AS avg_business_lending,

    ROUND(AVG(bank_deposits), 2) AS avg_deposits

FROM banking_analysis
GROUP BY risk_weighting
ORDER BY risk_weighting;

#High risk customer
SELECT
    client_id,
    client_name,
    age,
    estimated_income,
    bank_loans,
    business_lending,
    credit_card_balance,
    bank_deposits,
    risk_weighting,
    loyalty_classification

FROM banking_analysis

WHERE risk_weighting >= 4

ORDER BY
    bank_loans + business_lending + credit_card_balance DESC;

#high risk &High lending customer
SELECT
    client_id,
    client_name,
    estimated_income,
    risk_weighting,

    ROUND(
        bank_loans +
        business_lending +
        credit_card_balance,
        2
    ) AS total_lending

FROM banking_analysis

WHERE risk_weighting >= 4

ORDER BY total_lending DESC
LIMIT 20;

#Branch analysis
SELECT
    branch_id,

    COUNT(*) AS total_customers,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(
        SUM(
            bank_deposits +
            checking_accounts +
            saving_accounts +
            foreign_currency_account
        ), 2
    ) AS total_deposits,

    ROUND(
        SUM(
            bank_loans +
            business_lending +
            credit_card_balance
        ), 2
    ) AS total_lending,

    ROUND(AVG(risk_weighting), 2) AS avg_risk

FROM banking_analysis

GROUP BY branch_id

ORDER BY total_deposits DESC;

#Branch lending to deposit ratio
SELECT
    branch_id,

    ROUND(
        SUM(
            bank_deposits +
            checking_accounts +
            saving_accounts +
            foreign_currency_account
        ), 2
    ) AS total_deposit,

    ROUND(
        SUM(
            bank_loans +
            business_lending +
            credit_card_balance
        ), 2
    ) AS total_lending,

    ROUND(
        SUM(
            bank_loans +
            business_lending +
            credit_card_balance
        )
        /
        NULLIF(
            SUM(
                bank_deposits +
                checking_accounts +
                saving_accounts +
                foreign_currency_account
            ),0
        ) * 100,
        2
    ) AS loan_deposit_ratio

FROM banking_analysis

GROUP BY branch_id
ORDER BY loan_deposit_ratio DESC;

#Customer Acqustion trend
SELECT
    YEAR(joined_bank) AS joining_year,
    COUNT(*) AS new_customers

FROM banking_analysis

GROUP BY YEAR(joined_bank)

ORDER BY joining_year;

# Monthly cudtomer acqution
SELECT
    YEAR(joined_bank) AS year,
    MONTH(joined_bank) AS month_number,
    MONTHNAME(joined_bank) AS month_name,
    COUNT(*) AS customers_joined

FROM banking_analysis

GROUP BY
    YEAR(joined_bank),
    MONTH(joined_bank),
    MONTHNAME(joined_bank)

ORDER BY year, month_number;

#credit card analysis
SELECT
    amount_of_credit_cards,

    COUNT(*) AS customers,

    ROUND(AVG(credit_card_balance), 2) AS avg_card_balance,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(AVG(risk_weighting), 2) AS avg_risk

FROM banking_analysis

GROUP BY amount_of_credit_cards

ORDER BY amount_of_credit_cards;

#Identify Potential Credit Card Cross-Sell Customers
SELECT
    client_id,
    client_name,
    age,
    estimated_income,
    amount_of_credit_cards,
    credit_card_balance,
    loyalty_classification,
    risk_weighting

FROM banking_analysis

WHERE amount_of_credit_cards = 1
  AND estimated_income > 200000
  AND risk_weighting <= 2

ORDER BY estimated_income DESC;

#Top deposit customer
SELECT
    client_id,
    client_name,
    loyalty_classification,
    estimated_income,

    ROUND(
        bank_deposits +
        checking_accounts +
        saving_accounts +
        foreign_currency_account,
        2
    ) AS total_deposits,

    risk_weighting

FROM banking_analysis

ORDER BY total_deposits DESC

LIMIT 10;

#Top lending customer
SELECT
    client_id,
    client_name,
    estimated_income,

    ROUND(
        bank_loans +
        business_lending +
        credit_card_balance,
        2
    ) AS total_lending,

    risk_weighting,
    loyalty_classification

FROM banking_analysis

ORDER BY total_lending DESC

LIMIT 10;

#Loan to deposit ratio by customer
SELECT
    client_id,
    client_name,

    ROUND(
        bank_deposits +
        checking_accounts +
        saving_accounts +
        foreign_currency_account,
        2
    ) AS total_deposit,

    ROUND(
        bank_loans +
        business_lending +
        credit_card_balance,
        2
    ) AS total_lending,

    ROUND(
        (
            bank_loans +
            business_lending +
            credit_card_balance
        )
        /
        NULLIF(
            bank_deposits +
            checking_accounts +
            saving_accounts +
            foreign_currency_account,
            0
        ),
        2
    ) AS lending_deposit_ratio,

    risk_weighting

FROM banking_analysis

ORDER BY lending_deposit_ratio DESC;

#Customer income segmentation
SELECT
    CASE
        WHEN estimated_income < 50000
            THEN 'Low Income'

        WHEN estimated_income < 100000
            THEN 'Lower Middle Income'

        WHEN estimated_income < 200000
            THEN 'Middle Income'

        WHEN estimated_income < 300000
            THEN 'High Income'

        ELSE 'Very High Income'
    END AS income_segment,

    COUNT(*) AS customers,

    ROUND(AVG(bank_deposits),2) AS avg_deposit,

    ROUND(AVG(bank_loans),2) AS avg_loan,

    ROUND(AVG(risk_weighting),2) AS avg_risk

FROM banking_analysis

GROUP BY income_segment

ORDER BY AVG(estimated_income);

#Occupation Analysis
SELECT
    occupation,
    COUNT(*) AS customers,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(SUM(bank_deposits), 2) AS total_deposits,

    ROUND(SUM(bank_loans), 2) AS total_loans,

    ROUND(AVG(risk_weighting), 2) AS avg_risk

FROM banking_analysis

GROUP BY occupation

HAVING COUNT(*) >= 5

ORDER BY customers DESC;

#Occupation Analysis
SELECT
    occupation,
    COUNT(*) AS customers,

    ROUND(AVG(estimated_income), 2) AS avg_income,

    ROUND(SUM(bank_deposits), 2) AS total_deposits,

    ROUND(SUM(bank_loans), 2) AS total_loans,

    ROUND(AVG(risk_weighting), 2) AS avg_risk

FROM banking_analysis

GROUP BY occupation

HAVING COUNT(*) >= 5

ORDER BY customers DESC;

# bank Relationship manager analysis
SELECT
    banking_contact,

    COUNT(*) AS total_customers,

    ROUND(SUM(
        bank_deposits +
        checking_accounts +
        saving_accounts +
        foreign_currency_account
    ),2) AS customer_deposits,

    ROUND(SUM(
        bank_loans +
        business_lending +
        credit_card_balance
    ),2) AS customer_lending,

    ROUND(AVG(estimated_income),2) AS avg_customer_income,

    ROUND(AVG(risk_weighting),2) AS avg_risk

FROM banking_analysis

GROUP BY banking_contact

ORDER BY customer_deposits + customer_lending DESC;

# Propertyownership Analysis
SELECT
    properties_owned,

    COUNT(*) AS customers,

    ROUND(AVG(estimated_income),2) AS avg_income,

    ROUND(AVG(bank_loans),2) AS avg_bank_loan,

    ROUND(AVG(business_lending),2) AS avg_business_lending,

    ROUND(AVG(bank_deposits),2) AS avg_deposit,

    ROUND(AVG(risk_weighting),2) AS avg_risk

FROM banking_analysis

GROUP BY properties_owned

ORDER BY properties_owned;

# High value Customer
SELECT
    client_id,
    client_name,
    estimated_income,
    loyalty_classification,

    ROUND(
        bank_deposits +
        checking_accounts +
        saving_accounts +
        foreign_currency_account +
        bank_loans +
        business_lending +
        credit_card_balance +
        superannuation_savings,
        2
    ) AS total_relationship_value,

    risk_weighting

FROM banking_analysis

ORDER BY total_relationship_value DESC

LIMIT 20;

#High value but High risk customer
SELECT
    client_id,
    client_name,
    estimated_income,

    ROUND(
        bank_deposits +
        checking_accounts +
        saving_accounts +
        foreign_currency_account +
        bank_loans +
        business_lending +
        credit_card_balance,
        2
    ) AS relationship_value,

    risk_weighting

FROM banking_analysis

WHERE risk_weighting >= 4

ORDER BY relationship_value DESC

LIMIT 20;

# find customer with 0 bank deposit
SELECT
    client_id,
    client_name,
    estimated_income,
    bank_deposits,
    saving_accounts,
    checking_accounts,
    bank_loans

FROM banking_analysis

WHERE bank_deposits = 0;

#find customer without Bank loan
SELECT
    client_id,
    client_name,
    estimated_income,
    bank_deposits,
    risk_weighting,
    bank_loans

FROM banking_analysis

WHERE bank_loans = 0

ORDER BY estimated_income DESC;

# Duplicate client Id
SELECT
    client_id,
    COUNT(*) AS occurrence_count,
    COUNT(DISTINCT client_name) AS different_names

FROM banking_analysis

GROUP BY client_id

HAVING COUNT(*) > 1

ORDER BY occurrence_count DESC;