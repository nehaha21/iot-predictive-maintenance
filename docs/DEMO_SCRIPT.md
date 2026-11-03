# Demonstration sequence (5–7 minutes)
1. Explain the problem statement and the MySQL + MongoDB choice.
2. Show ER diagram and relational schema in `PROJECT_DOCUMENTATION.md`.
3. Sign in as admin and show machine register. Add a unique machine and toggle its status (INSERT/UPDATE).
4. Open readings and submit a normal reading: e.g. temperature 70, vibration 2.5, pressure 5. Show LOW risk.
5. Submit an abnormal reading: temperature 90, vibration 8, pressure 5. Show HIGH risk and alert.
6. Show MongoDB documents and indexes in `sensor_readings` / `risk_alerts`.
7. Add maintenance and show SQL row and dashboard count.
8. Show SQL view, trigger, stored procedure, indexes and the JOIN/GROUP BY/HAVING/subquery examples.
9. Sign out and sign in as technician; show that machine create/delete is forbidden but reading and maintenance entry is allowed.
10. Run the documented test cases and report actual results.
