-- ============================================================
-- Industrial IoT Predictive Maintenance
-- Common Table Expressions and Recursive SQL Queries
-- MySQL 8.0+
-- ============================================================

USE industrial_maintenance;


-- ============================================================
-- QUERY 1: BASIC CTE
-- Calculate total downtime for each machine
-- ============================================================

WITH machine_downtime AS (
    SELECT
        m.id AS machine_id,
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
    total_downtime
FROM machine_downtime
ORDER BY total_downtime DESC;


-- ============================================================
-- QUERY 2: CTE WITH FILTERING
-- Find machines whose total downtime exceeds 2 hours
-- ============================================================

WITH downtime_summary AS (
    SELECT
        machine_id,
        SUM(downtime_hours) AS total_hours
    FROM maintenance_records
    GROUP BY machine_id
)
SELECT
    m.machine_code,
    m.name,
    d.total_hours
FROM downtime_summary d
JOIN machines m
    ON m.id = d.machine_id
WHERE d.total_hours > 2
ORDER BY d.total_hours DESC;


-- ============================================================
-- QUERY 3: MULTIPLE CTEs
-- Compare machine downtime with overall average
-- machine downtime
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
),
overall_average AS (
    SELECT AVG(total_downtime) AS avg_downtime
    FROM machine_totals
)
SELECT
    mt.machine_code,
    mt.total_downtime,
    oa.avg_downtime
FROM machine_totals mt
CROSS JOIN overall_average oa
WHERE mt.total_downtime > oa.avg_downtime;


-- ============================================================
-- QUERY 4: RECURSIVE CTE
-- Generate maintenance schedule for next 7 days
-- ============================================================

WITH RECURSIVE maintenance_schedule AS (
    SELECT
        1 AS day_number,
        CURRENT_DATE() AS schedule_date

    UNION ALL

    SELECT
        day_number + 1,
        DATE_ADD(schedule_date, INTERVAL 1 DAY)
    FROM maintenance_schedule
    WHERE day_number < 7
)
SELECT
    day_number,
    schedule_date
FROM maintenance_schedule
ORDER BY day_number;


-- ============================================================
-- QUERY 5: RECURSIVE CTE
-- Generate 12 monthly maintenance reporting periods
-- ============================================================

WITH RECURSIVE monthly_periods AS (
    SELECT
        1 AS month_number,
        CAST(
            DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
            AS DATE
        ) AS month_start

    UNION ALL

    SELECT
        month_number + 1,
        DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM monthly_periods
    WHERE month_number < 12
)
SELECT
    month_number,
    month_start,
    LAST_DAY(month_start) AS month_end
FROM monthly_periods;


-- ============================================================
-- QUERY 6: RECURSIVE CTE WITH MACHINE DATA
-- Generate next 5 inspection dates for every machine
-- Demonstration schedule: 30-day intervals
-- ============================================================

WITH RECURSIVE inspection_schedule AS (
    SELECT
        id AS machine_id,
        machine_code,
        name,
        1 AS inspection_number,
        DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)
            AS inspection_date
    FROM machines

    UNION ALL

    SELECT
        machine_id,
        machine_code,
        name,
        inspection_number + 1,
        DATE_ADD(inspection_date, INTERVAL 30 DAY)
    FROM inspection_schedule
    WHERE inspection_number < 5
)
SELECT
    machine_code,
    name,
    inspection_number,
    inspection_date
FROM inspection_schedule
ORDER BY machine_code, inspection_number;


-- ============================================================
-- QUERY 7: CTE WITH CONDITIONAL AGGREGATION
-- Summarize preventive and corrective maintenance
-- ============================================================

WITH maintenance_statistics AS (
    SELECT
        machine_id,
        COUNT(*) AS total_maintenance,
        SUM(
            CASE
                WHEN maintenance_type = 'PREVENTIVE'
                THEN 1 ELSE 0
            END
        ) AS preventive_count,
        SUM(
            CASE
                WHEN maintenance_type = 'CORRECTIVE'
                THEN 1 ELSE 0
            END
        ) AS corrective_count
    FROM maintenance_records
    GROUP BY machine_id
)
SELECT
    m.machine_code,
    m.name,
    COALESCE(s.total_maintenance, 0) AS total_maintenance,
    COALESCE(s.preventive_count, 0) AS preventive_count,
    COALESCE(s.corrective_count, 0) AS corrective_count
FROM machines m
LEFT JOIN maintenance_statistics s
    ON m.id = s.machine_id
ORDER BY m.machine_code;


-- ============================================================
-- QUERY 8: CTE FOR MACHINE MAINTENANCE PRIORITY
-- Demonstration classification based on downtime
-- ============================================================

WITH machine_summary AS (
    SELECT
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
    CASE
        WHEN total_downtime >= 10 THEN 'HIGH'
        WHEN total_downtime >= 5 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS maintenance_priority
FROM machine_summary
ORDER BY total_downtime DESC;