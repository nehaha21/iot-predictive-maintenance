-- ============================================================
-- Industrial IoT Predictive Maintenance
-- User-Defined SQL Functions
-- MySQL 8.0+
-- ============================================================

USE industrial_maintenance;

DROP FUNCTION IF EXISTS fn_total_downtime;
DROP FUNCTION IF EXISTS fn_maintenance_count;
DROP FUNCTION IF EXISTS fn_machine_priority;

DELIMITER $$

-- FUNCTION 1: Total downtime for a machine

CREATE FUNCTION fn_total_downtime(
    p_machine_id BIGINT UNSIGNED
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT COALESCE(SUM(downtime_hours), 0)
    INTO v_total
    FROM maintenance_records
    WHERE machine_id = p_machine_id;

    RETURN v_total;
END$$


-- FUNCTION 2: Number of maintenance records

CREATE FUNCTION fn_maintenance_count(
    p_machine_id BIGINT UNSIGNED
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*)
    INTO v_count
    FROM maintenance_records
    WHERE machine_id = p_machine_id;

    RETURN v_count;
END$$


-- FUNCTION 3: Maintenance priority classification
-- Demonstration thresholds based on historical downtime

CREATE FUNCTION fn_machine_priority(
    p_machine_id BIGINT UNSIGNED
)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_downtime DECIMAL(12,2);

    SET v_downtime = fn_total_downtime(p_machine_id);

    RETURN CASE
        WHEN v_downtime >= 10 THEN 'HIGH'
        WHEN v_downtime >= 5 THEN 'MEDIUM'
        ELSE 'LOW'
    END;
END$$

DELIMITER ;


-- ============================================================
-- FUNCTION DEMONSTRATIONS
-- ============================================================

SELECT
    machine_code,
    name,
    fn_total_downtime(id) AS total_downtime,
    fn_maintenance_count(id) AS maintenance_count,
    fn_machine_priority(id) AS maintenance_priority
FROM machines
ORDER BY machine_code;