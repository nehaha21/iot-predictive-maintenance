// Run with: mongosh mongodb/init.js
const dbx = db.getSiblingDB("industrial_maintenance");
dbx.sensor_readings.createIndex({machineId:1, recordedAt:-1});
dbx.sensor_readings.createIndex({risk:1, recordedAt:-1});
dbx.risk_alerts.createIndex({risk:1, recordedAt:-1});
dbx.risk_alerts.createIndex({machineId:1, recordedAt:-1});
dbx.sensor_readings.createIndex({recordedAt:1},{expireAfterSeconds:0,name:"optional_ttl_not_enabled"});
// NOTE: TTL index is intentionally not applied automatically because this project retains
// historical readings for analysis. Remove the last createIndex line if running this file.
