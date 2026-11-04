-- ============================================================
-- Industrial IoT Predictive Maintenance
-- Advanced Maintenance Reporting Queries
-- MySQL 8.0+
-- ============================================================

USE industrial_maintenance;


-- ============================================================
-- REPORT 1: MACHINE HEALTH SUMMARY
-- Maintenance-based operational overview
-- ============================================================

SELECT
    m.machine_code,
    m.name,
    m.location,
    m.status,
    COUNT(r.id) AS maintenance_count,
    COALESCE(SUM(r.downtime_hours), 0) AS total_downtime,
    MAX(r.performed_at) AS last_maintenance
FROM machines m
LEFT JOIN maintenance_records r
    ON m.id = r.machine_id
GROUP BY
    m.id,
    m.machine_code,
    m.name,
    m.location,
    m.status
ORDER BY total_downtime DESC;


-- ============================================================
-- REPORT 2: MAINTENANCE FREQUENCY
-- Number of maintenance activities per machine
-- ============================================================

SELECT
    m.machine_code,
    m.name,
    COUNT(r.id) AS maintenance_frequency
FROM machines m
LEFT JOIN maintenance_records r
    ON m.id = r.machine_id
GROUP BY m.id, m.machine_code, m.name
ORDER BY maintenance_frequency DESC;


-- ============================================================
-- REPORT 3: MACHINE STATUS DISTRIBUTION
-- ============================================================

SELECT
    status,
    COUNT(*) AS machine_count
FROM machines
GROUP BY status
ORDER BY machine_count DESC;


-- ============================================================
-- REPORT 4: MAINTENANCE TYPE DISTRIBUTION
-- ============================================================

SELECT
    maintenance_type,
    COUNT(*) AS total_activities,
    COALESCE(SUM(downtime_hours), 0) AS total_downtime
FROM maintenance_records
GROUP BY maintenance_type
ORDER BY total_activities DESC;


-- ============================================================
-- REPORT 5: MONTHLY MAINTENANCE TREND
-- ============================================================

SELECT
    DATE_FORMAT(performed_at, '%Y-%m') AS maintenance_month,
    COUNT(*) AS total_activities,
    SUM(downtime_hours) AS total_downtime
FROM maintenance_records
GROUP BY DATE_FORMAT(performed_at, '%Y-%m')
ORDER BY maintenance_month;


-- ============================================================
-- REPORT 6: MACHINES REQUIRING ATTENTION
-- Demonstration rule based on maintenance downtime
-- ============================================================

WITH machine_totals AS (
    SELECT
        m.id,
        m.machine_code,
        m.name,
        m.status,
        COALESCE(SUM(r.downtime_hours), 0) AS total_downtime
    FROM machines m
    LEFT JOIN maintenance_records r
        ON m.id = r.machine_id
    GROUP BY m.id, m.machine_code, m.name, m.status
)
SELECT
    machine_code,
    name,
    status,
    total_downtime,
    CASE
        WHEN status = 'OFFLINE' THEN 'CRITICAL'
        WHEN total_downtime >= 10 THEN 'HIGH'
        WHEN total_downtime >= 5 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS attention_level
FROM machine_totals
ORDER BY
    CASE
        WHEN status = 'OFFLINE' THEN 1
        WHEN total_downtime >= 10 THEN 2
        WHEN total_downtime >= 5 THEN 3
        ELSE 4
    END,
    total_downtime DESC;


-- ============================================================
-- REPORT 7: TECHNICIAN MAINTENANCE ACTIVITY
-- ============================================================

SELECT
    u.username,
    u.role,
    COUNT(r.id) AS records_created,
    COALESCE(SUM(r.downtime_hours), 0) AS total_recorded_downtime
FROM users u
LEFT JOIN maintenance_records r
    ON u.id = r.created_by
GROUP BY u.id, u.username, u.role
ORDER BY records_created DESC;


-- ============================================================
-- REPORT 8: MACHINES WITHOUT MAINTENANCE HISTORY
-- ============================================================

SELECT
    m.machine_code,
    m.name,
    m.status
FROM machines m
LEFT JOIN maintenance_records r
    ON m.id = r.machine_id
WHERE r.id IS NULL;


-- ============================================================
-- REPORT 9: MOST RECENT MAINTENANCE PER MACHINE
-- ============================================================

WITH ranked_maintenance AS (
    SELECT
        r.id,
        r.machine_id,
        r.maintenance_type,
        r.description,
        r.performed_at,
        ROW_NUMBER() OVER (
            PARTITION BY r.machine_id
            ORDER BY r.performed_at DESC, r.id DESC
        ) AS row_num
    FROM maintenance_records r
)
SELECT
    m.machine_code,
    m.name,
    rm.maintenance_type,
    rm.description,
    rm.performed_at
FROM machines m
LEFT JOIN ranked_maintenance rm
    ON m.id = rm.machine_id
   AND rm.row_num = 1
ORDER BY m.machine_code;


-- ============================================================
-- REPORT 10: MAINTENANCE SUMMARY VIEW
-- ============================================================

SELECT
    machine_code,
    name,
    location,
    status,
    maintenance_count,
    total_downtime_hours,
    last_maintenance
FROM machine_maintenance_summary
ORDER BY total_downtime_hours DESC;