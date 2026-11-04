-- Additional repeatable demonstration data. Run only on a development database.
USE industrial_maintenance;
INSERT INTO machines(machine_code,name,location,status)
VALUES ('MCH-004','Backup Compressor','Utilities Room','IDLE'),
       ('MCH-005','Packaging Conveyor','Assembly Line 1','RUNNING')
ON DUPLICATE KEY UPDATE machine_code=VALUES(machine_code);

INSERT INTO maintenance_records(machine_id,maintenance_type,description,downtime_hours,performed_at)
SELECT m.id, t.maintenance_type, t.description, t.downtime_hours, t.performed_at
FROM (
 SELECT 'MCH-001' AS machine_code, 'CORRECTIVE' AS maintenance_type,
 'Replaced spindle bearing - SQL demo' AS description, 6.00 AS downtime_hours,
 '2026-01-10 10:00:00' AS performed_at
 UNION ALL SELECT 'MCH-001','INSPECTION','Vibration inspection - SQL demo',0.50,'2026-02-10 10:00:00'
 UNION ALL SELECT 'MCH-002','PREVENTIVE','Hydraulic seal check - SQL demo',2.00,'2026-02-15 10:00:00'
 UNION ALL SELECT 'MCH-004','CORRECTIVE','Air valve replacement - SQL demo',5.50,'2026-03-10 10:00:00'
) t JOIN machines m ON m.machine_code=t.machine_code
WHERE NOT EXISTS (
 SELECT 1 FROM maintenance_records r
 WHERE r.machine_id=m.id AND r.description=t.description
);
