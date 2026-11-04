# SQL execution guide (MySQL 8.0+)

## Prerequisites
Use a disposable local MySQL database for test scripts. The project already contains `sql/01_schema.sql` and `sql/02_seed.sql`. Do not run schema or seed scripts against production data. The seed script inserts maintenance records each time it runs, so it is **not fully idempotent**.

On Windows, install MySQL Server and client, or use an existing MySQL container. `mysql --version` must work before using the commands below. A missing `mysql` command means the client is unavailable or absent from PATH; it does not prove the server is absent.

## Run order
From the repository root in PowerShell, after confirming a local MySQL client:

```powershell
mysql -u root -p < sql/01_schema.sql
mysql -u root -p < sql/02_seed.sql
mysql -u root -p < sql/08_functions.sql
mysql -u root -p < sql/09_stored_procedures.sql
mysql -u root -p < sql/10_triggers.sql
mysql -u root -p < sql/16_integrity_checks.sql
mysql -u root -p < sql/17_advanced_feature_checks.sql
```

`sql/03` through `sql/07` are read-only query examples; execute them separately after seeding. `sql/11` and `sql/12` through `sql/15` are demonstrations/tests: inspect them before running because some modify test data. `DELIMITER` commands require a MySQL-compatible client (not a generic SQL execution API).

## Capture evidence
Record MySQL version, command, execution date, pass/fail, and screenshots for: schema/keys, join and correlated query, recursive CTE, window function, function call, procedure call, trigger audit (using test data), transaction rollback, and integrity checks. Never commit passwords or `.env` files.

## Known limitations
The original schema uses `CREATE TRIGGER` without `DROP TRIGGER IF EXISTS`, so rerunning `01_schema.sql` on an existing schema may fail. Use a fresh disposable database for reproducibility. `sql/08` functions may require appropriate MySQL routine privileges or binary-logging settings. No results are asserted until scripts are actually executed.
