-- ============================================================
-- Industrial IoT Predictive Maintenance
-- Transaction Management Demonstrations
-- MySQL 8.0+
--
-- Execute in a development database.
-- All demonstration changes are rolled back.
-- ============================================================

USE industrial_maintenance;


-- ============================================================
-- TRANSACTION 1: ROLLBACK DEMONSTRATION
-- ============================================================

START TRANSACTION;

INSERT INTO maintenance_records (
    machine_id,
    maintenance_type,
    description,
    downtime_hours
)
SELECT
    id,
    'INSPECTION',
    'Temporary transaction test',
    0.50
FROM machines
WHERE machine_code = 'MCH-001';

SELECT
    id,
    description,
    downtime_hours
FROM maintenance_records
WHERE description = 'Temporary transaction test';

ROLLBACK;

-- Expected: No matching rows from this transaction.

SELECT
    id,
    description
FROM maintenance_records
WHERE description = 'Temporary transaction test';


-- ============================================================
-- TRANSACTION 2: SAVEPOINT DEMONSTRATION
-- ============================================================

START TRANSACTION;

INSERT INTO maintenance_records (
    machine_id,
    maintenance_type,
    description,
    downtime_hours
)
SELECT
    id,
    'PREVENTIVE',
    'First temporary savepoint record',
    1.00
FROM machines
WHERE machine_code = 'MCH-001';

SAVEPOINT first_insert;

INSERT INTO maintenance_records (
    machine_id,
    maintenance_type,
    description,
    downtime_hours
)
SELECT
    id,
    'INSPECTION',
    'Second temporary savepoint record',
    0.25
FROM machines
WHERE machine_code = 'MCH-002';

ROLLBACK TO SAVEPOINT first_insert;

-- Only the first temporary record should remain
-- visible inside this transaction.

SELECT
    id,
    description,
    downtime_hours
FROM maintenance_records
WHERE description LIKE '%temporary savepoint record%';

ROLLBACK;

-- Both temporary records should now be absent.

SELECT
    id,
    description
FROM maintenance_records
WHERE description LIKE '%temporary savepoint record%';


-- ============================================================
-- TRANSACTION 3: COMMIT DEMONSTRATION
--
-- This example is intentionally commented out because
-- COMMIT permanently saves data.
--
-- Uncomment only in a disposable development database.
-- ============================================================

-- START TRANSACTION;
--
-- INSERT INTO maintenance_records (
--     machine_id,
--     maintenance_type,
--     description,
--     downtime_hours
-- )
-- SELECT
--     id,
--     'INSPECTION',
--     'Committed transaction demonstration',
--     0.75
-- FROM machines
-- WHERE machine_code = 'MCH-003';
--
-- COMMIT;
--
-- SELECT *
-- FROM maintenance_records
-- WHERE description = 'Committed transaction demonstration';