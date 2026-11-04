-- ============================================================
-- Industrial IoT Predictive Maintenance
-- Triggers and Maintenance Audit Logging
-- MySQL 8.0+
-- ============================================================

USE industrial_maintenance;


-- ============================================================
-- AUDIT TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS maintenance_audit (
    audit_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    maintenance_id BIGINT UNSIGNED NOT NULL,
    action_type ENUM('INSERT', 'UPDATE') NOT NULL,
    old_downtime DECIMAL(10,2) NULL,
    new_downtime DECIMAL(10,2) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- DROP EXISTING TRIGGERS FOR REPEATABLE INSTALLATION
-- ============================================================

DROP TRIGGER IF EXISTS trg_maintenance_update_validate;
DROP TRIGGER IF EXISTS trg_maintenance_audit_insert;
DROP TRIGGER IF EXISTS trg_maintenance_audit_update;


DELIMITER $$

-- ============================================================
-- TRIGGER 1: Validate maintenance updates
-- ============================================================

CREATE TRIGGER trg_maintenance_update_validate
BEFORE UPDATE ON maintenance_records
FOR EACH ROW
BEGIN
    IF NEW.downtime_hours IS NULL
       OR NEW.downtime_hours < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Downtime cannot be negative';
    END IF;

    IF NEW.description IS NULL
       OR CHAR_LENGTH(TRIM(NEW.description)) < 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Maintenance description is too short';
    END IF;
END$$


-- ============================================================
-- TRIGGER 2: Audit new maintenance records
-- ============================================================

CREATE TRIGGER trg_maintenance_audit_insert
AFTER INSERT ON maintenance_records
FOR EACH ROW
BEGIN
    INSERT INTO maintenance_audit (
        maintenance_id,
        action_type,
        old_downtime,
        new_downtime
    )
    VALUES (
        NEW.id,
        'INSERT',
        NULL,
        NEW.downtime_hours
    );
END$$


-- ============================================================
-- TRIGGER 3: Audit maintenance updates
-- ============================================================

CREATE TRIGGER trg_maintenance_audit_update
AFTER UPDATE ON maintenance_records
FOR EACH ROW
BEGIN
    INSERT INTO maintenance_audit (
        maintenance_id,
        action_type,
        old_downtime,
        new_downtime
    )
    VALUES (
        NEW.id,
        'UPDATE',
        OLD.downtime_hours,
        NEW.downtime_hours
    );
END$$

DELIMITER ;


-- ============================================================
-- AUDIT LOG VERIFICATION
-- ============================================================

SELECT
    audit_id,
    maintenance_id,
    action_type,
    old_downtime,
    new_downtime,
    changed_at
FROM maintenance_audit
ORDER BY audit_id DESC;