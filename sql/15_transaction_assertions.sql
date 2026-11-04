-- Transaction and audit rollback smoke test; no changes persist.
USE industrial_maintenance;
START TRANSACTION;
INSERT INTO maintenance_records(machine_id,maintenance_type,description,downtime_hours)
SELECT id,'INSPECTION','SQL rollback assertion sample',0.25
FROM machines WHERE machine_code='MCH-001';
SELECT COUNT(*) AS inside_transaction_count FROM maintenance_records
WHERE description='SQL rollback assertion sample';
ROLLBACK;
SELECT COUNT(*) AS after_rollback_count FROM maintenance_records
WHERE description='SQL rollback assertion sample';
-- Expected after_rollback_count = 0 unless the same description pre-existed.
