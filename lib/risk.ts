export type Reading = {temperature:number; vibration:number; pressure:number};
export function assessRisk(r: Reading) {
  // Transparent rule-based screening thresholds for the demonstration dataset.
  // These are not certified limits; tune them to the actual machine/vendor.
  const reasons:string[] = [];
  if (r.temperature >= 85) reasons.push("High temperature (>=85 °C)");
  if (r.vibration >= 7) reasons.push("High vibration (>=7 mm/s)");
  if (r.pressure < 2 || r.pressure > 10) reasons.push("Pressure outside 2–10 bar");
  const score = Math.min(100, reasons.length * 40 + (r.temperature >= 95 ? 20 : 0) + (r.vibration >= 10 ? 20 : 0));
  return {risk: score >= 60 ? "HIGH" : score >= 30 ? "MEDIUM" : "LOW", score, reasons};
}
