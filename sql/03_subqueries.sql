-- =====================================================
-- Industrial IoT Predictive Maintenance
-- Nested and Correlated SQL Queries
-- =====================================================

USE industrial_maintenance;

-- =====================================================
-- QUERY 1: NESTED SUBQUERY
-- Machines having at least one maintenance record
-- =====================================================

SELECT
    id,
    machine_code,
    name,
    status
FROM machines
WHERE id IN (
    SELECT DISTINCT machine_id
    FROM maintenance_records
);


-- =====================================================
-- QUERY 2: NESTED SUBQUERY
-- Machines with downtime above the overall average
-- maintenance-record downtime
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    r.downtime_hours
FROM machines m
JOIN maintenance_records r
    ON m.id = r.machine_id
WHERE r.downtime_hours > (
    SELECT AVG(downtime_hours)
    FROM maintenance_records
);


-- =====================================================
-- QUERY 3: NESTED SUBQUERY
-- Machines without maintenance records
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    m.status
FROM machines m
WHERE m.id NOT IN (
    SELECT machine_id
    FROM maintenance_records
);


-- =====================================================
-- QUERY 4: CORRELATED SUBQUERY
-- Maintenance records with downtime greater than
-- the average downtime for their own machine
-- =====================================================

SELECT
    m.machine_code,
    r.id AS maintenance_id,
    r.maintenance_type,
    r.downtime_hours
FROM maintenance_records r
JOIN machines m
    ON m.id = r.machine_id
WHERE r.downtime_hours > (
    SELECT AVG(r2.downtime_hours)
    FROM maintenance_records r2
    WHERE r2.machine_id = r.machine_id
);


-- =====================================================
-- QUERY 5: CORRELATED SUBQUERY
-- Machines with at least one corrective maintenance
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    m.status
FROM machines m
WHERE EXISTS (
    SELECT 1
    FROM maintenance_records r
    WHERE r.machine_id = m.id
      AND r.maintenance_type = 'CORRECTIVE'
);


-- =====================================================
-- QUERY 6: CORRELATED SUBQUERY
-- Most recent maintenance record for each machine
-- Includes ties when performed_at is identical
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    r.maintenance_type,
    r.description,
    r.performed_at
FROM maintenance_records r
JOIN machines m
    ON m.id = r.machine_id
WHERE r.performed_at = (
    SELECT MAX(r2.performed_at)
    FROM maintenance_records r2
    WHERE r2.machine_id = r.machine_id
)
ORDER BY m.machine_code;


-- =====================================================
-- QUERY 7: SCALAR SUBQUERY
-- Display each machine with the total number of
-- maintenance records in the database
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    (
        SELECT COUNT(*)
        FROM maintenance_records
    ) AS total_maintenance_records
FROM machines m;


-- =====================================================
-- QUERY 8: CORRELATED SCALAR SUBQUERY
-- Count maintenance records for each machine
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    (
        SELECT COUNT(*)
        FROM maintenance_records r
        WHERE r.machine_id = m.id
    ) AS maintenance_count
FROM machines m
ORDER BY maintenance_count DESC;