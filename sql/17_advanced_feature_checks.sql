-- Read-only smoke tests; requires scripts 01, 02, 08, 09, 10 installed.
USE industrial_maintenance;
SELECT machine_code, fn_total_downtime(id) AS downtime, fn_maintenance_count(id) AS record_count, fn_machine_priority(id) AS priority FROM machines ORDER BY machine_code;
SELECT machine_code, maintenance_count, total_downtime_hours FROM machine_maintenance_summary ORDER BY machine_code;
SELECT machine_code, total_downtime_hours, RANK() OVER (ORDER BY total_downtime_hours DESC) AS downtime_rank FROM machine_maintenance_summary;
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n+1 FROM seq WHERE n<5) SELECT n FROM seq;
SELECT COUNT(*) AS audit_rows FROM maintenance_audit;
-- Procedures: CALL sp_machine_report(<existing machine id>); CALL sp_maintenance_by_type('PREVENTIVE');
