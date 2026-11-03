# Test cases

Record the actual result after executing; do not mark tests passed without running them.

| ID | Test | Expected result |
|---|---|---|
| TC01 | Login with configured admin credentials | 200 and session cookie |
| TC02 | Login with wrong password | 401 |
| TC03 | Call `/api/machines` without login | 401 |
| TC04 | Admin adds unique machine | 201 |
| TC05 | Add duplicate `machine_code` | 409 |
| TC06 | Technician posts to `/api/machines` | 403 |
| TC07 | Post reading with valid machine and normal values | 201, LOW, no alert |
| TC08 | Post reading temperature 90 and vibration 8 | 201, HIGH, alert inserted |
| TC09 | Post reading with nonexistent machine ID | 400 |
| TC10 | Post negative downtime | 400 validation failure |
| TC11 | Delete machine with maintenance rows | DB FK rejects deletion |
| TC12 | Load dashboard | Counts and latest records visible |
| TC13 | Query `machine_maintenance_summary` | Aggregated machine data |
| TC14 | Call `get_machine_maintenance(1)` | Maintenance rows for machine 1 |
