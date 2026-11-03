
import { NextRequest, NextResponse } from "next/server";
import { requireSession, apiError } from "@/lib/auth";
import { mongoDb, sql } from "@/lib/db";
import { readingSchema } from "@/lib/validation";
import { assessRisk } from "@/lib/risk";

// GET: Retrieve recent sensor readings
export async function GET() {
  try {
    await requireSession();

    const db = await mongoDb();

    const rows = await db
      .collection("sensor_readings")
      .find({})
      .sort({ recordedAt: -1 })
      .limit(200)
      .toArray();

    return NextResponse.json(
      rows.map((r) => ({
        ...r,
        _id: String(r._id)
      }))
    );

  } catch (error) {
    return apiError(error);
  }
}

// POST: Create a new sensor reading
export async function POST(req: NextRequest) {
  try {
    await requireSession();

    const parsed = readingSchema.safeParse(await req.json());

    if (!parsed.success) {
      return NextResponse.json(
        {
          error: "Invalid reading",
          details: parsed.error.issues
        },
        { status: 400 }
      );
    }

    const b = parsed.data;

    // Verify that the machine exists in MySQL
    const [machines]: any = await sql.execute(
      "SELECT id FROM machines WHERE id = ?",
      [b.machineId]
    );

    if (!machines.length) {
      return NextResponse.json(
        { error: "Machine does not exist" },
        { status: 400 }
      );
    }

    const recordedAt = b.recordedAt
      ? new Date(b.recordedAt)
      : new Date();

    // Calculate sensor risk
    const assessment = assessRisk(b);

    const doc = {
      machineId: b.machineId,
      temperature: b.temperature,
      vibration: b.vibration,
      pressure: b.pressure,
      recordedAt,
      ...assessment
    };

    const db = await mongoDb();

    // Save reading in MongoDB
    const result = await db
      .collection("sensor_readings")
      .insertOne(doc);

    // Generate alert for non-LOW risk
    if (assessment.risk !== "LOW") {
      await db.collection("risk_alerts").insertOne({
        ...doc,
        readingId: result.insertedId,
        createdAt: new Date()
      });
    }

    return NextResponse.json(
      {
        ...doc,
        _id: String(result.insertedId)
      },
      { status: 201 }
    );

  } catch (error) {
    return apiError(error);
  }
}
