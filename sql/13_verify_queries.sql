-- Read-only verification. Expected counts are minimums, not fixed totals.
USE industrial_maintenance;
SELECT 'users' AS entity, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'machines', COUNT(*) FROM machines
UNION ALL SELECT 'maintenance_records', COUNT(*) FROM maintenance_records;

SELECT m.machine_code, COUNT(r.id) AS records_count,
 COALESCE(SUM(r.downtime_hours),0) AS downtime_hours
FROM machines m LEFT JOIN maintenance_records r ON r.machine_id=m.id
GROUP BY m.id,m.machine_code ORDER BY m.machine_code;

SELECT m.machine_code, r.id, r.downtime_hours
FROM maintenance_records r JOIN machines m ON m.id=r.machine_id
WHERE r.downtime_hours > (
 SELECT AVG(r2.downtime_hours) FROM maintenance_records r2
 WHERE r2.machine_id=r.machine_id
);

SELECT machine_code, maintenance_count, total_downtime_hours
FROM machine_maintenance_summary ORDER BY machine_code;

SELECT machine_code, fn_total_downtime(id) AS downtime,
 fn_maintenance_count(id) AS record_count,
 fn_machine_priority(id) AS priority
FROM machines ORDER BY machine_code;
