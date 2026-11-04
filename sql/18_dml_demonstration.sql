-- DML demonstration: INSERT, SELECT, UPDATE, DELETE in a single rolled-back transaction.
-- Run ONLY in a disposable MySQL development database.
USE industrial_maintenance;
START TRANSACTION;
INSERT INTO machines(machine_code,name,location,status)
VALUES ('DEMO-DML-999','Temporary DML Demo','Test Lab','IDLE');
SET @demo_machine_id = LAST_INSERT_ID();
SELECT id,machine_code,name,status FROM machines WHERE id=@demo_machine_id;
UPDATE machines SET status='MAINTENANCE' WHERE id=@demo_machine_id;
SELECT id,machine_code,status FROM machines WHERE id=@demo_machine_id;
DELETE FROM machines WHERE id=@demo_machine_id;
SELECT COUNT(*) AS remaining_demo_rows FROM machines WHERE id=@demo_machine_id;
ROLLBACK;
-- The transaction leaves no demo machine behind; verify with the next query.
SELECT COUNT(*) AS persisted_demo_rows FROM machines WHERE machine_code='DEMO-DML-999';
