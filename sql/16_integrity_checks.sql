-- Read-only integrity and database-object checks (MySQL 8+)
USE industrial_maintenance;
SELECT 'machines' AS table_name, COUNT(*) AS row_count FROM machines
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'maintenance_records', COUNT(*) FROM maintenance_records;
SELECT m.machine_code, COUNT(r.id) AS records, COALESCE(SUM(r.downtime_hours),0) AS downtime_hours
FROM machines m LEFT JOIN maintenance_records r ON r.machine_id=m.id
GROUP BY m.id,m.machine_code ORDER BY m.machine_code;
SELECT COUNT(*) AS orphan_machine_refs FROM maintenance_records r LEFT JOIN machines m ON m.id=r.machine_id WHERE m.id IS NULL;
SELECT COUNT(*) AS orphan_user_refs FROM maintenance_records r LEFT JOIN users u ON u.id=r.created_by WHERE r.created_by IS NOT NULL AND u.id IS NULL;
SELECT COUNT(*) AS negative_downtime FROM maintenance_records WHERE downtime_hours < 0;
SELECT TABLE_NAME, TABLE_TYPE FROM information_schema.TABLES WHERE TABLE_SCHEMA='industrial_maintenance' ORDER BY TABLE_NAME;
SELECT ROUTINE_NAME, ROUTINE_TYPE FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA='industrial_maintenance' ORDER BY ROUTINE_NAME;
SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_TIMING FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA='industrial_maintenance' ORDER BY TRIGGER_NAME;
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='industrial_maintenance' ORDER BY TABLE_NAME,INDEX_NAME,SEQ_IN_INDEX;
