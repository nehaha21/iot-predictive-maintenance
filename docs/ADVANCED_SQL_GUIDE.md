# Advanced SQL Implementation Guide

## Industrial IoT Predictive Maintenance & Sensor Alert Engine

Database: industrial_maintenance

DBMS: MySQL 8.0+

## 1. Overview

This document explains the advanced SQL techniques implemented in the project.

The SQL implementation supports maintenance analysis, machine monitoring, reporting, and historical data retrieval.

The project uses MySQL for structured relational data and MongoDB for flexible sensor and alert data.

## 2. Common Table Expressions

File: sql/05_cte_recursive.sql

A Common Table Expression (CTE) defines a temporary named result set within a SQL statement.

Syntax:

```sql
WITH cte_name AS (
    SELECT ...
)
SELECT *
FROM cte_name;
```

CTEs improve readability by separating complex queries into logical components.

### Implemented Examples

1. Total machine downtime.
2. Machines exceeding downtime thresholds.
3. Comparison against average machine downtime.
4. Maintenance statistics by category.
5. Maintenance priority classification.

### Multiple CTEs

Multiple CTEs can be declared in one WITH clause.

They allow intermediate calculations to be reused within the same SQL statement.

## 3. Recursive CTEs

A recursive CTE repeatedly executes a recursive query until a termination condition is reached.

It contains two components:

- Anchor query
- Recursive query

Syntax:

```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numbers
    WHERE n < 5
)
SELECT *
FROM numbers;
```

### Implemented Examples

1. Seven-day maintenance schedule.
2. Twelve-month reporting calendar.
3. Five inspection dates for every machine.

These examples demonstrate recursive sequence generation.

The generated inspection dates are illustrative and are not persisted as maintenance appointments.

## 4. Window Functions

File: sql/06_window_functions.sql

Window functions perform calculations across related rows without collapsing them into one grouped result.

### ROW_NUMBER

Assigns a unique sequential number to rows within a partition.

Used to number maintenance records for each machine.

### RANK

Ranks machines by downtime.

Equal values receive equal ranks, and gaps can occur after ties.

### DENSE_RANK

Ranks records without gaps after tied rankings.

### SUM OVER

Calculates cumulative downtime for each machine.

### LAG

Retrieves the previous maintenance record's downtime.

### LEAD

Retrieves the next recorded maintenance date in chronological order.

### AVG OVER

Calculates average downtime while preserving individual maintenance rows.

### NTILE

Divides machines into approximately equal ranking groups.

## 5. PARTITION BY

PARTITION BY divides rows into independent groups for window calculations.

Example:

```sql
SELECT
    machine_id,
    downtime_hours,
    AVG(downtime_hours) OVER (
        PARTITION BY machine_id
    ) AS average_downtime
FROM maintenance_records;
```

This calculates a separate average for each machine.

## 6. Advanced Reporting

File: sql/07_advanced_reporting.sql

The project implements reports for:

- Machine maintenance history
- Maintenance frequency
- Machine status distribution
- Maintenance type distribution
- Monthly maintenance trends
- Maintenance attention levels
- User maintenance activity
- Machines without maintenance records
- Most recent maintenance
- Maintenance summary view

## 7. Maintenance Priority Classification

The demonstration SQL uses downtime-based rules.

LOW:

Total downtime below 5 hours.

MEDIUM:

Total downtime from 5 hours to below 10 hours.

HIGH:

Total downtime of at least 10 hours.

The advanced reporting query also classifies OFFLINE machines as CRITICAL.

These thresholds are illustrative and should not be interpreted as statistically validated failure predictions.

## 8. SQL Concepts Demonstrated

| Concept | Implementation |
|---|---|
| Basic CTE | Machine downtime summary |
| Multiple CTEs | Average downtime comparison |
| Recursive CTE | Date sequence generation |
| ROW_NUMBER | Maintenance record numbering |
| RANK | Machine downtime ranking |
| DENSE_RANK | Maintenance downtime ranking |
| SUM OVER | Cumulative downtime |
| LAG | Previous maintenance downtime |
| LEAD | Next recorded maintenance |
| AVG OVER | Machine average downtime |
| NTILE | Downtime ranking groups |
| CASE | Maintenance priority |
| COALESCE | Handling missing maintenance values |
| GROUP BY | Maintenance aggregation |
| LEFT JOIN | Including machines without maintenance |

## 9. Execution Instructions

The database schema must already exist.

Execute the following files in order:

1. sql/05_cte_recursive.sql
2. sql/06_window_functions.sql
3. sql/07_advanced_reporting.sql

These scripts contain SELECT statements and do not modify database records.

MySQL 8.0 or later is required.

## 10. Testing Status

The queries have been prepared against the project's documented schema.

Database execution testing is pending.

Testing should verify:

- Successful execution of each query.
- Correct machine and maintenance relationships.
- Correct aggregate calculations.
- Correct ranking behavior.
- Correct recursive sequence termination.
- Correct handling of machines without maintenance records.
- Correct handling of NULL values.

Query results and screenshots should be recorded after execution.

## 11. Viva Questions

### What is a CTE?

A CTE is a temporary named result set defined within a SQL statement using WITH.

### What is a recursive CTE?

A recursive CTE references itself and repeatedly executes until a termination condition is satisfied.

### Difference between GROUP BY and PARTITION BY?

GROUP BY combines rows into grouped results.

PARTITION BY divides rows into groups for window calculations without collapsing the individual rows.

### Difference between RANK and DENSE_RANK?

RANK can skip ranking numbers after ties.

DENSE_RANK does not skip ranking numbers.

### What does ROW_NUMBER do?

ROW_NUMBER assigns a unique sequential number to each row within its window partition.

### What is LAG?

LAG retrieves a value from an earlier row within a window.

### What is LEAD?

LEAD retrieves a value from a later row within a window.

### Why use window functions?

They support ranking, trend analysis, comparisons, and cumulative calculations while preserving individual records.

### Why use recursive queries in this project?

Recursive queries demonstrate the generation of repeated maintenance planning intervals and reporting periods.

### Are these SQL queries performing machine-learning predictions?

No.

These SQL queries analyze maintenance history and generate rule-based reports.

Machine-learning predictions are handled separately by the project's predictive analysis components.