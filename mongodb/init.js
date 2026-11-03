// Run with: mongosh mongodb/init.js

const dbx = db.getSiblingDB("industrial_maintenance");

// Sensor reading indexes
dbx.sensor_readings.createIndex(
  { machineId: 1, recordedAt: -1 },
  { name: "idx_sensor_machine_time" }
);

dbx.sensor_readings.createIndex(
  { risk: 1, recordedAt: -1 },
  { name: "idx_sensor_risk_time" }
);

// Risk alert indexes
dbx.risk_alerts.createIndex(
  { risk: 1, recordedAt: -1 },
  { name: "idx_alert_risk_time" }
);

dbx.risk_alerts.createIndex(
  { machineId: 1, recordedAt: -1 },
  { name: "idx_alert_machine_time" }
);

print("MongoDB indexes initialized successfully.");