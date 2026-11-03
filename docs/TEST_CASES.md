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
| TC15 | Retrieve sensor readings using `/api/readings` while authenticated | 200 and readings returned |
| TC16 | Update an existing reading using `/api/readings/[id]` with PATCH | 200 and updated reading returned |
| TC17 | Update a reading with changed sensor values | Risk score and risk category recalculated; associated alert synchronized |
| TC18 | Delete an existing reading as admin | 200 and reading deleted |
| TC19 | Delete a reading as technician | 403 Forbidden |
| TC20 | Update or delete using an invalid MongoDB ObjectId | 400 Invalid ID |
| TC21 | Create a reading with invalid sensor values | 400 validation failure |
| TC22 | Create a LOW-risk reading | Reading saved without a risk alert |
| TC23 | Create a HIGH-risk reading | Reading saved and corresponding risk alert created |
| TC24 | Verify MongoDB indexes in Compass | Required compound indexes visible in both collections |

## Actual RBAC security test results

| Test | Actual result | Status |
|---|---|---|
| Technician attempts to update machine using PATCH | HTTP 403 Forbidden | PASS |
| Technician attempts to delete machine using DELETE | HTTP 403 Forbidden | PASS |

Both tests were executed while logged in with the technician account. The server rejected both administrative operations with `FORBIDDEN`.

## Actual authentication test results

| Test | Actual result | Status |
|---|---|---|
| Logout using POST `/api/auth/logout` | HTTP 200, `{ok: true}` | PASS |
| Retrieve `/api/readings` after logout | HTTP 401, `{error: "UNAUTHORIZED"}` | PASS |

The tests were executed in the browser while logged out. The readings API correctly rejected the unauthenticated request.