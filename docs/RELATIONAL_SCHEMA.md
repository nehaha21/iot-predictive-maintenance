# Relational Schema Documentation

## Industrial IoT Predictive Maintenance & Sensor Alert Engine

Database Name: industrial_maintenance

Database Management System: MySQL 8.0+

## 1. Relational Schema

### USERS

USERS(
    id PK,
    username UNIQUE,
    password_hash,
    role,
    is_active,
    created_at
)

### MACHINES

MACHINES(
    id PK,
    machine_code UNIQUE,
    name,
    location,
    status,
    created_at,
    updated_at
)

### MAINTENANCE_RECORDS

MAINTENANCE_RECORDS(
    id PK,
    machine_id FK,
    maintenance_type,
    description,
    downtime_hours,
    performed_at,
    created_by FK,
    created_at
)

Foreign Key Relationships:

maintenance_records.machine_id REFERENCES machines(id)

maintenance_records.created_by REFERENCES users(id)

## 2. Attribute Definitions

### USERS

| Attribute | Data Type | Constraints |
|---|---|---|
| id | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT |
| username | VARCHAR(50) | NOT NULL, UNIQUE |
| password_hash | VARCHAR(255) | NOT NULL |
| role | ENUM | admin, technician |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

Additional constraint:

chk_username_nonempty

Ensures usernames contain at least three non-whitespace characters after trimming.

### MACHINES

| Attribute | Data Type | Constraints |
|---|---|---|
| id | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT |
| machine_code | VARCHAR(30) | NOT NULL, UNIQUE |
| name | VARCHAR(100) | NOT NULL |
| location | VARCHAR(100) | NOT NULL |
| status | ENUM | RUNNING, IDLE, MAINTENANCE, OFFLINE |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| updated_at | TIMESTAMP | NOT NULL, AUTO UPDATE |

Additional constraint:

chk_machine_name

Ensures machine names contain at least two non-whitespace characters after trimming.

### MAINTENANCE_RECORDS

| Attribute | Data Type | Constraints |
|---|---|---|
| id | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT |
| machine_id | BIGINT UNSIGNED | NOT NULL, FOREIGN KEY |
| maintenance_type | ENUM | PREVENTIVE, CORRECTIVE, INSPECTION |
| description | VARCHAR(1000) | NOT NULL |
| downtime_hours | DECIMAL(10,2) | NOT NULL, DEFAULT 0 |
| performed_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| created_by | BIGINT UNSIGNED | NULL, FOREIGN KEY |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

Additional constraint:

chk_downtime_nonnegative

Ensures downtime_hours is greater than or equal to zero.

## 3. Foreign Key Constraints

### fk_maintenance_machine

Parent Table: machines

Child Table: maintenance_records

Referenced Column: machines.id

Foreign Key Column: maintenance_records.machine_id

Deletion Behavior: RESTRICT

### fk_maintenance_user

Parent Table: users

Child Table: maintenance_records

Referenced Column: users.id

Foreign Key Column: maintenance_records.created_by

Deletion Behavior: SET NULL

## 4. Indexes

### idx_machine_status

Table: machines

Column: status

Purpose:

Improves filtering of machines by operational status.

### idx_maintenance_type

Table: maintenance_records

Column: maintenance_type

Purpose:

Supports queries filtering maintenance records by maintenance type.

### idx_maintenance_machine_date

Table: maintenance_records

Columns:

- machine_id
- performed_at

Purpose:

Improves maintenance history queries filtered by machine and ordered or filtered by maintenance date.

## 5. Database View

View Name:

machine_maintenance_summary

Purpose:

Provides summarized maintenance information for each machine.

Output Columns:

- machine_id
- machine_code
- name
- location
- status
- maintenance_count
- total_downtime_hours
- last_maintenance

The view uses:

- LEFT JOIN
- COUNT
- SUM
- MAX
- GROUP BY

It includes machines even when they have no maintenance records.

## 6. Stored Procedure

Procedure Name:

get_machine_maintenance

Input Parameter:

p_machine_id BIGINT UNSIGNED

Purpose:

Retrieves maintenance history for a specified machine.

Results are ordered by performed_at in descending order.

## 7. Trigger

Trigger Name:

trg_maintenance_validate

Table:

maintenance_records

Trigger Event:

BEFORE INSERT

Purpose:

Validates maintenance data before insertion.

Validation Rules:

1. Downtime cannot be negative.
2. Maintenance descriptions must contain at least three characters after trimming.

Invalid inserts are rejected using SIGNAL SQLSTATE '45000'.

## 8. Normalization

### First Normal Form (1NF)

Each table contains atomic values.

Each record is uniquely identified by a primary key.

There are no repeating groups in the relational schema.

### Second Normal Form (2NF)

All tables use single-column primary keys.

Non-key attributes depend on their respective primary keys.

Therefore, there are no partial dependencies on composite primary keys.

### Third Normal Form (3NF)

User details are stored separately from maintenance records.

Machine details are stored separately from maintenance records.

Maintenance records reference users and machines through foreign keys instead of duplicating their descriptive attributes.

The current schema is designed to satisfy Third Normal Form.

## 9. Data Integrity

The schema maintains integrity through:

- Primary keys
- Foreign keys
- UNIQUE constraints
- NOT NULL constraints
- CHECK constraints
- ENUM restrictions
- Triggers
- Controlled deletion rules

## 10. Database Verification Commands

The following commands can be executed in MySQL:

```sql
USE industrial_maintenance;

SHOW TABLES;

DESCRIBE users;

DESCRIBE machines;

DESCRIBE maintenance_records;

SHOW INDEX FROM machines;

SHOW INDEX FROM maintenance_records;

SHOW CREATE TABLE maintenance_records;

SHOW CREATE VIEW machine_maintenance_summary;

SHOW TRIGGERS;

SHOW PROCEDURE STATUS
WHERE Db = 'industrial_maintenance';
```

These commands help verify the implemented relational schema.