-- =====================================================
-- Industrial IoT Predictive Maintenance
-- JOIN and Aggregate Queries
-- =====================================================

USE industrial_maintenance;

-- =====================================================
-- QUERY 1: INNER JOIN
-- Maintenance history with machine details
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    r.maintenance_type,
    r.description,
    r.downtime_hours,
    r.performed_at
FROM machines m
INNER JOIN maintenance_records r
    ON m.id = r.machine_id
ORDER BY r.performed_at DESC;


-- =====================================================
-- QUERY 2: LEFT JOIN
-- All machines including those without maintenance
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    m.status,
    COUNT(r.id) AS maintenance_count
FROM machines m
LEFT JOIN maintenance_records r
    ON m.id = r.machine_id
GROUP BY
    m.id,
    m.machine_code,
    m.name,
    m.status;


-- =====================================================
-- QUERY 3: JOIN THREE TABLES
-- Maintenance records with machine and user details
-- =====================================================

SELECT
    r.id AS maintenance_id,
    m.machine_code,
    m.name AS machine_name,
    r.maintenance_type,
    r.description,
    r.downtime_hours,
    u.username AS recorded_by
FROM maintenance_records r
INNER JOIN machines m
    ON r.machine_id = m.id
LEFT JOIN users u
    ON r.created_by = u.id;


-- =====================================================
-- QUERY 4: GROUP BY
-- Total downtime for each machine
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    COALESCE(SUM(r.downtime_hours), 0)
        AS total_downtime_hours
FROM machines m
LEFT JOIN maintenance_records r
    ON m.id = r.machine_id
GROUP BY
    m.id,
    m.machine_code,
    m.name
ORDER BY total_downtime_hours DESC;


-- =====================================================
-- QUERY 5: HAVING
-- Machines with total downtime greater than 2 hours
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    SUM(r.downtime_hours) AS total_downtime
FROM machines m
JOIN maintenance_records r
    ON m.id = r.machine_id
GROUP BY
    m.id,
    m.machine_code,
    m.name
HAVING SUM(r.downtime_hours) > 2;


-- =====================================================
-- QUERY 6: AGGREGATE FUNCTIONS
-- Overall maintenance statistics
-- =====================================================

SELECT
    COUNT(*) AS total_maintenance_records,
    COALESCE(SUM(downtime_hours), 0)
        AS total_downtime,
    AVG(downtime_hours) AS average_downtime,
    MAX(downtime_hours) AS maximum_downtime,
    MIN(downtime_hours) AS minimum_downtime
FROM maintenance_records;


-- =====================================================
-- QUERY 7: GROUP BY MAINTENANCE TYPE
-- Maintenance statistics by category
-- =====================================================

SELECT
    maintenance_type,
    COUNT(*) AS total_records,
    SUM(downtime_hours) AS total_downtime,
    AVG(downtime_hours) AS average_downtime
FROM maintenance_records
GROUP BY maintenance_type
ORDER BY total_downtime DESC;


-- =====================================================
-- QUERY 8: SELF JOIN
-- Find machines located in the same area
-- =====================================================

SELECT
    m1.machine_code AS machine_1,
    m2.machine_code AS machine_2,
    m1.location
FROM machines m1
INNER JOIN machines m2
    ON m1.location = m2.location
   AND m1.id < m2.id;


-- =====================================================
-- QUERY 9: VIEW
-- Retrieve summarized maintenance information
-- =====================================================

SELECT *
FROM machine_maintenance_summary
ORDER BY total_downtime_hours DESC;


-- =====================================================
-- QUERY 10: CONDITIONAL AGGREGATION
-- Count maintenance activities by type
-- =====================================================

SELECT
    m.machine_code,
    m.name,
    SUM(
        CASE
            WHEN r.maintenance_type = 'PREVENTIVE'
            THEN 1 ELSE 0
        END
    ) AS preventive_count,
    SUM(
        CASE
            WHEN r.maintenance_type = 'CORRECTIVE'
            THEN 1 ELSE 0
        END
    ) AS corrective_count,
    SUM(
        CASE
            WHEN r.maintenance_type = 'INSPECTION'
            THEN 1 ELSE 0
        END
    ) AS inspection_count
FROM machines m
LEFT JOIN maintenance_records r
    ON m.id = r.machine_id
GROUP BY
    m.id,
    m.machine_code,
    m.name;