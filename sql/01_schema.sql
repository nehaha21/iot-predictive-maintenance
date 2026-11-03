CREATE DATABASE IF NOT EXISTS industrial_maintenance CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE industrial_maintenance;

CREATE TABLE IF NOT EXISTS users (
 id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
 username VARCHAR(50) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 role ENUM('admin','technician') NOT NULL,
 is_active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT chk_username_nonempty CHECK (CHAR_LENGTH(TRIM(username)) >= 3)
);

CREATE TABLE IF NOT EXISTS machines (
 id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
 machine_code VARCHAR(30) NOT NULL UNIQUE,
 name VARCHAR(100) NOT NULL,
 location VARCHAR(100) NOT NULL,
 status ENUM('RUNNING','IDLE','MAINTENANCE','OFFLINE') NOT NULL DEFAULT 'RUNNING',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT chk_machine_name CHECK (CHAR_LENGTH(TRIM(name)) >= 2)
);

CREATE TABLE IF NOT EXISTS maintenance_records (
 id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
 machine_id BIGINT UNSIGNED NOT NULL,
 maintenance_type ENUM('PREVENTIVE','CORRECTIVE','INSPECTION') NOT NULL,
 description VARCHAR(1000) NOT NULL,
 downtime_hours DECIMAL(10,2) NOT NULL DEFAULT 0,
 performed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 created_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_maintenance_machine FOREIGN KEY(machine_id) REFERENCES machines(id) ON DELETE RESTRICT,
 CONSTRAINT fk_maintenance_user FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL,
 CONSTRAINT chk_downtime_nonnegative CHECK (downtime_hours >= 0),
 INDEX idx_maintenance_machine_date(machine_id, performed_at)
);

CREATE INDEX idx_machine_status ON machines(status);
CREATE INDEX idx_maintenance_type ON maintenance_records(maintenance_type);

CREATE OR REPLACE VIEW machine_maintenance_summary AS
 SELECT m.id AS machine_id, m.machine_code, m.name, m.location, m.status,
        COUNT(r.id) AS maintenance_count, COALESCE(SUM(r.downtime_hours),0) AS total_downtime_hours,
        MAX(r.performed_at) AS last_maintenance
 FROM machines m LEFT JOIN maintenance_records r ON r.machine_id=m.id
 GROUP BY m.id,m.machine_code,m.name,m.location,m.status;

DELIMITER //
CREATE TRIGGER trg_maintenance_validate BEFORE INSERT ON maintenance_records
FOR EACH ROW
BEGIN
 IF NEW.downtime_hours < 0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Downtime hours cannot be negative';
 END IF;
 IF CHAR_LENGTH(TRIM(NEW.description)) < 3 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Maintenance description is too short';
 END IF;
END//
CREATE PROCEDURE get_machine_maintenance(IN p_machine_id BIGINT UNSIGNED)
BEGIN
 SELECT id,machine_id,maintenance_type,description,downtime_hours,performed_at
 FROM maintenance_records WHERE machine_id=p_machine_id ORDER BY performed_at DESC;
END//
DELIMITER ;

-- ALTER demonstration (safe to run once; skip if column already exists):
-- ALTER TABLE machines ADD COLUMN manufacturer VARCHAR(100) NULL;
-- DROP demonstration is deliberately commented to prevent accidental data loss:
-- DROP VIEW machine_maintenance_summary;
