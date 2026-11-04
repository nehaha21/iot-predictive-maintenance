# README addition — SQL/database setup

Copy this section into the repository's main `README.md` after verifying local instructions. Do not replace the README; it may contain Person 2's setup/security documentation.

## Relational database (MySQL 8+)
The `industrial_maintenance` database stores users, machines and maintenance records. `sql/01_schema.sql` creates the base schema, constraints, indexes, summary view, trigger and procedure; `sql/02_seed.sql` adds demonstration data. Advanced SQL and testing scripts are in `sql/03`–`sql/19`.

Use a local MySQL development database and follow `docs/SQL_EXECUTION_GUIDE.md`. Do not run test scripts on production data. The original seed is not fully idempotent. Capture outputs in `docs/SQL_TEST_RESULTS.md` after executing them.

**Security:** Never commit MySQL passwords or environment files. Follow the existing project configuration instructions for connecting the application.
