import { z } from "zod";
export const machineSchema = z.object({
  machine_code:z.string().trim().min(2).max(30), name:z.string().trim().min(2).max(100),
  location:z.string().trim().min(1).max(100), status:z.enum(["RUNNING","IDLE","MAINTENANCE","OFFLINE"]).default("RUNNING")
});
export const readingSchema = z.object({
  machineId:z.coerce.number().int().positive(), temperature:z.coerce.number().min(-50).max(250),
  vibration:z.coerce.number().min(0).max(100), pressure:z.coerce.number().min(0).max(1000),
  recordedAt:z.string().datetime().optional()
});
export const maintenanceSchema = z.object({
  machineId:z.coerce.number().int().positive(), maintenanceType:z.enum(["PREVENTIVE","CORRECTIVE","INSPECTION"]),
  description:z.string().trim().min(3).max(1000), downtimeHours:z.coerce.number().min(0).max(10000),
  performedAt:z.string().datetime().optional()
});
