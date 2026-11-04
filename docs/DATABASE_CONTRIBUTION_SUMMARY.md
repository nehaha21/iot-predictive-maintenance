# Person 1 — SQL and database design contribution

## Scope
ER diagram and relational schema; nested and correlated subqueries; joins, aggregates, CTEs and recursion; analytical window functions; user-defined functions; stored procedures; triggers and transaction demonstrations; SQL verification and documentation.

## File map
- `docs/ER_DIAGRAM.md`, `docs/RELATIONAL_SCHEMA.md`: conceptual and relational design.
- `sql/01_schema.sql`, `sql/02_seed.sql`: base schema and sample data (existing).
- `sql/03_subqueries.sql` to `sql/07_advanced_reporting.sql`: read-only queries and reporting.
- `sql/08_functions.sql` to `sql/11_transactions.sql`: advanced database features.
- `sql/12_test_seed.sql` to `sql/17_advanced_feature_checks.sql`: test data and checks.
- `sql/18_dml_demonstration.sql`, `sql/19_schema_dictionary.sql`: DML and dictionary evidence.

## Integration boundaries
MySQL stores structured users, machines and maintenance records; MongoDB/sensor alerts and authentication integration are covered by Person 2. Confirm API routes actually use the schema before claiming full integration.

## Evidence required
Capture real MySQL outputs, screenshots, API/UI integration and individual commit history. The existence of scripts is not proof they ran successfully.

## Cautions
The existing seed script is not fully idempotent; some routines/triggers may require MySQL privileges; test on disposable data first. The project rubric requires demonstrated operations, not merely files in the repository.
