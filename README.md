# Industrial Predictive Maintenance (DBMS Level 3)

A Next.js web application using **MySQL + MongoDB** for machine register, maintenance history, sensor readings, threshold-based risk alerts and dashboard.

## Requirements
- Node.js 20+
- MySQL 8.0+
- MongoDB 6+
- npm

## 1. Create databases and schema
1. Start MySQL and MongoDB locally.
2. Run `mysql -u root -p < sql/01_schema.sql`.
3. Run `mysql -u root -p < sql/02_seed.sql`.
4. Run MongoDB indexes: `mongosh mongodb/init.js`.
5. Create `.env.local` from `.env.example` and set your actual database credentials and a random JWT secret (32+ characters).

## 2. Create a usable admin account
The seed SQL uses a placeholder hash and should not be relied on for login. Generate a real bcrypt hash:
```bash
npm install
node -e "const b=require('bcryptjs'); console.log(b.hashSync('ChangeMe123!',10))"
```
Copy the printed hash and update both seeded user rows as desired:
```sql
USE industrial_maintenance;
UPDATE users SET password_hash='<PASTE_HASH_HERE>' WHERE username='admin';
UPDATE users SET password_hash='<PASTE_HASH_HERE>' WHERE username='technician';
```
Suggested demo login: `admin` / `ChangeMe123!` and `technician` / `ChangeMe123!` after setting those hashes. Change passwords before real use.

## 3. Run
```bash
cp .env.example .env.local
# edit .env.local with your values
npm install
npm run dev
```
Open http://localhost:3000. Sign in using the credentials whose bcrypt hash you configured.

## Roles
- **admin**: view data, register/delete machines, create readings and maintenance.
- **technician**: view data, create readings and maintenance; machine creation/deletion is forbidden.

## Data model
- MySQL: users, machines, maintenance_records and machine_maintenance_summary view.
- MongoDB: sensor_readings and risk_alerts.

## Important limitations
The risk score is a documented threshold-based screening rule, not a trained ML model or a calibrated probability of failure. Thresholds are demo values and require machine-specific validation. MongoDB and MySQL are separate systems; cross-database machine references are checked by the API, not enforced as a single cross-database FK.

## Files
- `sql/01_schema.sql`: DDL, constraints, indexes, view, trigger, stored procedure.
- `sql/02_seed.sql`: demo machines and users (password hashes must be replaced as above).
- `mongodb/init.js`: MongoDB indexes.
- `docs/PROJECT_DOCUMENTATION.md`: documentation, ER diagram, relational schema, queries, architecture and testing checklist.

## Before submission
- Replace demo credentials and document actual team member names/contributions.
- Run every test in the documentation and record actual outcomes.
- Capture real application screenshots.
- Create a GitHub repository and commit work separately for both members.
- Verify the instructor's section-specific title uniqueness requirement.
