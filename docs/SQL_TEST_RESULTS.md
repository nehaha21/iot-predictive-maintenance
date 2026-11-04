# SQL test results — fill after execution

**Status: NOT EXECUTED / NOT VERIFIED** (replace only after running against MySQL).

| ID | Test | Command/file | Expected | Actual result | Pass/Fail | Evidence screenshot |
|---|---|---|---|---|---|---|
| T01 | Schema and keys | `01_schema.sql` | Tables, PKs, FKs and indexes created | Pending | Pending | Pending |
| T02 | Seed | `02_seed.sql` | Three machines and sample records | Pending | Pending | Pending |
| T03 | Joins/subqueries | `03`, `04` | Valid machine relationships | Pending | Pending | Pending |
| T04 | Recursive CTE | `05_cte_recursive.sql` | Finite date sequences | Pending | Pending | Pending |
| T05 | Window functions | `06_window_functions.sql` | Correct rank/sequence | Pending | Pending | Pending |
| T06 | User-defined functions | `08_functions.sql` | Counts and totals agree | Pending | Pending | Pending |
| T07 | Procedures | `09_stored_procedures.sql` | Reports return rows | Pending | Pending | Pending |
| T08 | Triggers | `10_triggers.sql` | Audit records on new test changes | Pending | Pending | Pending |
| T09 | Transactions | `11_transactions.sql` | Test inserts rolled back | Pending | Pending | Pending |
| T10 | Integrity | `16_integrity_checks.sql` | Zero orphans/negative downtime | Pending | Pending | Pending |

Do not mark tests passed based solely on SQL source code. Include error messages and fixes when applicable.
