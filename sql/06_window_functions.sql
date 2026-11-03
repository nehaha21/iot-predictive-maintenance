-- ============================================================
-- Industrial IoT Predictive Maintenance
-- Window Functions and Analytical SQL
-- MySQL 8.0+
-- ============================================================

USE industrial_maintenance;


-- ============================================================
-- QUERY 1: ROW_NUMBER()
-- Number maintenance records for each machine
-- ============================================================

SELECT
    m.machine_code,
    r.id AS maintenance_id,
    r.maintenance_type,
    r.performed_at,
    ROW_NUMBER() OVER (
        PARTITION BY r.machine_id
        ORDER BY r.performed_at DESC, r.id DESC
    ) AS maintenance_sequence
FROM maintenance_records r
JOIN machines m
    ON m.id = r.machine_id;


-- ============================================================
-- QUERY 2: RANK()
-- Rank machines by total downtime
-- ============================================================

WITH downtime_totals AS (
    SELECT
        m.id,
        m.machine_code,
        m.name,
        COALESCE(SUM(r.downtime_hours), 0) AS total_downtime
    FROM machines m
    LEFT JOIN maintenance_records r
        ON m.id = r.machine_id
    GROUP BY m.id, m.machine_code, m.name
)
SELECT
    machine_code,
    name,
    total_downtime,
    RANK() OVER (
        ORDER BY total_downtime DESC
    ) AS downtime_rank
FROM downtime_totals;


-- ============================================================
-- QUERY 3: DENSE_RANK()
-- Rank maintenance records by downtime
-- ============================================================

SELECT
    id AS maintenance_id,
    machine_id,
    maintenance_type,
    downtime_hours,
    DENSE_RANK() OVER (
        ORDER BY downtime_hours DESC
    ) AS downtime_rank
FROM maintenance_records;


-- ============================================================
-- QUERY 4: RUNNING TOTAL
-- Calculate cumulative downtime for each machine
-- ============================================================

SELECT
    m.machine_code,
    r.id AS maintenance_id,
    r.performed_at,
    r.downtime_hours,
    SUM(r.downtime_hours) OVER (
        PARTITION BY r.machine_id
        ORDER BY r.performed_at, r.id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS cumulative_downtime
FROM maintenance_records r
JOIN machines m
    ON m.id = r.machine_id;


-- ============================================================
-- QUERY 5: LAG()
-- Compare current maintenance downtime with previous
-- maintenance downtime for the same machine
-- ============================================================

SELECT
    m.machine_code,
    r.id AS maintenance_id,
    r.performed_at,
    r.downtime_hours,
    LAG(r.downtime_hours) OVER (
        PARTITION BY r.machine_id
        ORDER BY r.performed_at, r.id
    ) AS previous_downtime
FROM maintenance_records r
JOIN machines m
    ON m.id = r.machine_id;


-- ============================================================
-- QUERY 6: LEAD()
-- Display the next recorded maintenance date
-- ============================================================

SELECT
    m.machine_code,
    r.id AS maintenance_id,
    r.performed_at,
    LEAD(r.performed_at) OVER (
        PARTITION BY r.machine_id
        ORDER BY r.performed_at, r.id
    ) AS next_recorded_maintenance
FROM maintenance_records r
JOIN machines m
    ON m.id = r.machine_id;


-- ============================================================
-- QUERY 7: AVG() OVER()
-- Compare each maintenance record against machine average
-- ============================================================

SELECT
    m.machine_code,
    r.id AS maintenance_id,
    r.downtime_hours,
    AVG(r.downtime_hours) OVER (
        PARTITION BY r.machine_id
    ) AS machine_average_downtime
FROM maintenance_records r
JOIN machines m
    ON m.id = r.machine_id;


-- ============================================================
-- QUERY 8: NTILE()
-- Divide machines into downtime ranking groups
-- ============================================================

WITH machine_totals AS (
    SELECT
        m.id,
        m.machine_code,
        COALESCE(SUM(r.downtime_hours), 0) AS total_downtime
    FROM machines m
    LEFT JOIN maintenance_records r
        ON m.id = r.machine_id
    GROUP BY m.id, m.machine_code
)
SELECT
    machine_code,
    total_downtime,
    NTILE(3) OVER (
        ORDER BY total_downtime DESC, id
    ) AS downtime_group
FROM machine_totals;