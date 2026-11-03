
import { NextRequest, NextResponse } from "next/server";
import { ObjectId } from "mongodb";
import {
  requireSession,
  requireRole,
  apiError
} from "@/lib/auth";
import { mongoDb, sql } from "@/lib/db";
import { readingSchema } from "@/lib/validation";
import { assessRisk } from "@/lib/risk";

type Context = {
  params: { id: string };
};

// PATCH: Update an existing sensor reading
export async function PATCH(
  req: NextRequest,
  { params }: Context
) {
  try {
    await requireSession();

    if (!ObjectId.isValid(params.id)) {
      return NextResponse.json(
        { error: "Invalid reading ID" },
        { status: 400 }
      );
    }

    const parsed = readingSchema.partial().safeParse(
      await req.json()
    );

    if (!parsed.success) {
      return NextResponse.json(
        {
          error: "Invalid reading data",
          details: parsed.error.issues
        },
        { status: 400 }
      );
    }

    const updates = parsed.data;

    if (Object.keys(updates).length === 0) {
      return NextResponse.json(
        { error: "Provide at least one field to update" },
        { status: 400 }
      );
    }

    const db = await mongoDb();
    const readings = db.collection("sensor_readings");
    const alerts = db.collection("risk_alerts");

    const _id = new ObjectId(params.id);

    const existing = await readings.findOne({ _id });

    if (!existing) {
      return NextResponse.json(
        { error: "Sensor reading not found" },
        { status: 404 }
      );
    }

    const machineId = updates.machineId ?? existing.machineId;

    // Verify machine reference in MySQL
    const [machines]: any = await sql.execute(
      "SELECT id FROM machines WHERE id = ?",
      [machineId]
    );

    if (!machines.length) {
      return NextResponse.json(
        { error: "Machine does not exist" },
        { status: 400 }
      );
    }

    const updatedReading = {
      machineId,
      temperature: updates.temperature ?? existing.temperature,
      vibration: updates.vibration ?? existing.vibration,
      pressure: updates.pressure ?? existing.pressure
    };

    // Recalculate risk after updating sensor values
    const assessment = assessRisk(updatedReading);

    const updateDocument = {
      ...updatedReading,
      ...(updates.recordedAt
        ? { recordedAt: new Date(updates.recordedAt) }
        : {}),
      ...assessment
    };

    await readings.updateOne(
      { _id },
      { $set: updateDocument }
    );

    const updated = await readings.findOne({ _id });

    // Synchronize the associated risk alert
    if (assessment.risk !== "LOW") {
      await alerts.updateOne(
        { readingId: _id },
        {
          $set: {
            ...updateDocument,
            readingId: _id,
            createdAt: new Date()
          }
        },
        { upsert: true }
      );
    } else {
      await alerts.deleteOne({ readingId: _id });
    }

    return NextResponse.json({
      message: "Sensor reading updated successfully",
      reading: {
        ...updated,
        _id: String(_id)
      }
    });

  } catch (error) {
    return apiError(error);
  }
}

// DELETE: Delete a sensor reading
export async function DELETE(
  req: NextRequest,
  { params }: Context
) {
  try {
    const session = await requireSession();

    // Only administrators can delete readings
    requireRole("admin", session.role);

    if (!ObjectId.isValid(params.id)) {
      return NextResponse.json(
        { error: "Invalid reading ID" },
        { status: 400 }
      );
    }

    const db = await mongoDb();

    const readings = db.collection("sensor_readings");
    const alerts = db.collection("risk_alerts");

    const _id = new ObjectId(params.id);

    const result = await readings.deleteOne({ _id });

    if (result.deletedCount === 0) {
      return NextResponse.json(
        { error: "Sensor reading not found" },
        { status: 404 }
      );
    }

    // Delete associated risk alerts
    await alerts.deleteMany({
      readingId: _id
    });

    return NextResponse.json({
      message: "Sensor reading and associated alerts deleted successfully"
    });

  } catch (error) {
    return apiError(error);
  }
}
