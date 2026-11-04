-- Execute after 08_functions.sql, 09_stored_procedures.sql, 10_triggers.sql.
USE industrial_maintenance;
SHOW FUNCTION STATUS WHERE Db='industrial_maintenance';
SHOW PROCEDURE STATUS WHERE Db='industrial_maintenance';
SHOW TRIGGERS;
CALL sp_machine_report((SELECT id FROM machines WHERE machine_code='MCH-001'));
CALL sp_maintenance_by_type('CORRECTIVE');
SELECT * FROM maintenance_audit ORDER BY audit_id DESC LIMIT 20;
