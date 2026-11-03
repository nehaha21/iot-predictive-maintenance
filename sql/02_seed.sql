USE industrial_maintenance;
-- Demo password hashes are generated using bcryptjs; default password is ChangeMe123!
-- Replace these credentials immediately. Generate fresh hashes with the instructions in README.
INSERT INTO users(username,password_hash,role) VALUES
('admin','$2a$10$wH5rYV3nQ6tOQmKx8e1Z9e5zXx7jvZ8Vf4w3xWv6vQf8vX2fH3W9K','admin'),
('technician','$2a$10$wH5rYV3nQ6tOQmKx8e1Z9e5zXx7jvZ8Vf4w3xWv6vQf8vX2fH3W9K','technician')
ON DUPLICATE KEY UPDATE username=VALUES(username);

INSERT INTO machines(machine_code,name,location,status) VALUES
('MCH-001','CNC Milling Machine','Workshop A','RUNNING'),
('MCH-002','Hydraulic Press','Assembly Line 1','RUNNING'),
('MCH-003','Air Compressor','Utilities Room','MAINTENANCE')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO maintenance_records(machine_id,maintenance_type,description,downtime_hours)
SELECT id,'PREVENTIVE','Scheduled lubrication and inspection',1.5 FROM machines WHERE machine_code='MCH-001';
INSERT INTO maintenance_records(machine_id,maintenance_type,description,downtime_hours)
SELECT id,'CORRECTIVE','Replaced worn coupling',3.0 FROM machines WHERE machine_code='MCH-002';
