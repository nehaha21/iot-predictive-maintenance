-- ============================================================
-- Industrial IoT Predictive Maintenance
-- Advanced Stored Procedures
-- MySQL 8.0+
-- ============================================================

USE industrial_maintenance;

DROP PROCEDURE IF EXISTS sp_machine_report;
DROP PROCEDURE IF EXISTS sp_add_maintenance;
DROP PROCEDURE IF EXISTS sp_maintenance_by_type;

DELIMITER $$

-- ============================================================
-- PROCEDURE 1: Machine maintenance report
-- ============================================================

CREATE PROCEDURE sp_machine_report(
    IN p_machine_id BIGINT UNSIGNED
)
BEGIN
    SELECT
        m.machine_code,
        m.name,
        m.location,
        m.status,
        fn_maintenance_count(m.id) AS maintenance_count,
        fn_total_downtime(m.id) AS total_downtime,
        fn_machine_priority(m.id) AS priority
    FROM machines m
    WHERE m.id = p_machine_id;
END$$


-- ============================================================
-- PROCEDURE 2: Add maintenance record
-- ============================================================

CREATE PROCEDURE sp_add_maintenance(
    IN p_machine_id BIGINT UNSIGNED,
    IN p_maintenance_type VARCHAR(20),
    IN p_description VARCHAR(1000),
    IN p_downtime DECIMAL(10,2),
    IN p_created_by BIGINT UNSIGNED
)
BEGIN
    DECLARE v_machine_count INT;
    DECLARE v_user_count INT;

    SELECT COUNT(*)
    INTO v_machine_count
    FROM machines
    WHERE id = p_machine_id;

    IF v_machine_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Machine does not exist';
    END IF;

    IF p_downtime IS NULL OR p_downtime < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid downtime value';
    END IF;

    IF p_description IS NULL
       OR CHAR_LENGTH(TRIM(p_description)) < 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Description must contain at least 3 characters';
    END IF;

    IF p_maintenance_type IS NULL
       OR p_maintenance_type NOT IN
          ('PREVENTIVE', 'CORRECTIVE', 'INSPECTION') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid maintenance type';
    END IF;

    IF p_created_by IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_user_count
        FROM users
        WHERE id = p_created_by;

        IF v_user_count = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User does not exist';
        END IF;
    END IF;

    INSERT INTO maintenance_records (
        machine_id,
        maintenance_type,
        description,
        downtime_hours,
        created_by
    )
    VALUES (
        p_machine_id,
        p_maintenance_type,
        p_description,
        p_downtime,
        p_created_by
    );

    SELECT LAST_INSERT_ID() AS inserted_maintenance_id;
END$$


-- ============================================================
-- PROCEDURE 3: Maintenance report by type
-- ============================================================

CREATE PROCEDURE sp_maintenance_by_type(
    IN p_type VARCHAR(20)
)
BEGIN
    IF p_type IS NULL
       OR p_type NOT IN
          ('PREVENTIVE', 'CORRECTIVE', 'INSPECTION') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid maintenance type';
    END IF;

    SELECT
        m.machine_code,
        m.name,
        r.maintenance_type,
        r.description,
        r.downtime_hours,
        r.performed_at
    FROM maintenance_records r
    JOIN machines m
        ON m.id = r.machine_id
    WHERE r.maintenance_type = p_type
    ORDER BY r.performed_at DESC, r.id DESC;
END$$

DELIMITER ;


-- ============================================================
-- PROCEDURE DEMONSTRATIONS
-- ============================================================

CALL sp_machine_report(
    (SELECT id FROM machines WHERE machine_code = 'MCH-001')
);

CALL sp_maintenance_by_type('PREVENTIVE');

-- Data-changing procedure demonstration:
-- Run only in a development database.
--
-- CALL sp_add_maintenance(
--     1,
--     'INSPECTION',
--     'Routine safety inspection',
--     0.50,
--     NULL
-- );