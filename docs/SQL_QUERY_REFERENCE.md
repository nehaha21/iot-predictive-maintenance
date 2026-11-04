# SQL Query Reference

## Industrial IoT Predictive Maintenance & Sensor Alert Engine

This document explains the advanced SQL queries implemented for the DBMS mini project.

Database: industrial_maintenance

DBMS: MySQL

## 1. Nested Subqueries

File: sql/03_subqueries.sql

### Query 1: Machines with Maintenance Records

Concept: IN subquery

Purpose:

Retrieves machines that have at least one maintenance record.

### Query 2: Above-Average Downtime

Concept: Nested aggregate subquery

Purpose:

Finds maintenance records whose downtime exceeds the overall average downtime per maintenance record.

### Query 3: Machines Without Maintenance

Concept: NOT IN subquery

Purpose:

Identifies machines that do not have maintenance records.

The machine_id column is NOT NULL, so the subquery cannot return NULL machine identifiers.

## 2. Correlated Subqueries

### Query 4: Above-Average Machine Downtime

Concept: Correlated aggregate subquery

Purpose:

Identifies maintenance records whose downtime exceeds the average downtime for the same machine.

The inner query references the machine_id from the outer query.

### Query 5: Corrective Maintenance

Concept: Correlated EXISTS subquery

Purpose:

Finds machines with at least one corrective maintenance record.

### Query 6: Latest Maintenance

Concept: Correlated MAX subquery

Purpose:

Finds the latest maintenance activity for each machine.

If multiple records have the same latest timestamp, all matching records are returned.

### Query 7: Global Maintenance Count

Concept: Scalar subquery

Purpose:

Displays the total number of maintenance records alongside each machine.

### Query 8: Maintenance Count per Machine

Concept: Correlated scalar subquery

Purpose:

Counts maintenance records separately for each machine.

## 3. JOIN Queries

File: sql/04_joins_aggregates.sql

### INNER JOIN

Retrieves maintenance records together with their associated machine details.

### LEFT JOIN

Retrieves all machines, including machines without maintenance records.

### Three-Table JOIN

Combines maintenance records, machines, and users.

The user relationship uses LEFT JOIN because created_by is nullable.

### SELF JOIN

Identifies pairs of machines installed in the same location.

The condition m1.id < m2.id prevents duplicate reversed pairs and self-pairing.

## 4. Aggregate Queries

### GROUP BY

Groups maintenance records by machine or maintenance type.

### HAVING

Filters grouped maintenance results based on total downtime.

### COUNT

Counts maintenance records.

### SUM

Calculates total downtime.

### AVG

Calculates average downtime.

### MAX

Identifies maximum downtime.

### MIN

Identifies minimum downtime.

## 5. Conditional Aggregation

Uses CASE expressions inside SUM functions to count:

- Preventive maintenance
- Corrective maintenance
- Inspection activities

This allows multiple maintenance categories to be summarized in one query.

## 6. SQL View

View:

machine_maintenance_summary

The view combines machine information and maintenance statistics.

It demonstrates:

- LEFT JOIN
- GROUP BY
- COUNT
- SUM
- MAX
- COALESCE

## 7. Execution Order

Run the SQL files in this order:

1. sql/01_schema.sql
2. sql/02_seed.sql
3. sql/03_subqueries.sql
4. sql/04_joins_aggregates.sql

The first two files establish the database and initial data.

The remaining files contain read-only SELECT queries.

Important:

sql/01_schema.sql creates a trigger and procedure without checking whether they already exist. It should not be rerun against an initialized database without first handling those existing objects.

sql/02_seed.sql inserts maintenance records each time it runs and may create duplicate demonstration records.

Use a fresh development database or review the scripts before rerunning them.

## 8. Testing Status

The SQL queries are prepared for MySQL execution.

Execution testing and screenshots will be documented separately after the database environment is configured.

Expected test evidence includes:

- Successful query execution
- Returned result sets
- Empty-result cases
- Aggregate calculations
- JOIN correctness
- Correlated subquery correctness
- Database constraint verification

## 9. Viva Preparation

### What is a nested query?

A nested query is a SQL query placed inside another SQL query.

It can return a scalar value, a set of values, or a table-like result.

### What is a correlated subquery?

A correlated subquery references columns from the outer query.

Its result depends on the current outer-query row.

### Difference between INNER JOIN and LEFT JOIN?

INNER JOIN returns only matching records.

LEFT JOIN preserves all records from the left table even when no matching record exists in the right table.

### Difference between WHERE and HAVING?

WHERE filters rows before grouping.

HAVING filters grouped results after aggregation.

### Why use indexes?

Indexes help MySQL locate relevant records efficiently.

They can improve filtering, joining, and sorting operations.

### Why use a database view?

A view provides a reusable query interface.

It can simplify complex queries and standardize access to summarized information.