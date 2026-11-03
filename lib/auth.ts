import { SignJWT, jwtVerify } from "jose";
import { cookies } from "next/headers";
import { NextRequest, NextResponse } from "next/server";
const secret = () => {
  const value = process.env.JWT_SECRET;
  if (!value || value.length < 32) throw new Error("JWT_SECRET must contain at least 32 characters");
  return new TextEncoder().encode(value);
};
export type Role = "admin" | "technician";
export async function createToken(user: {id:number;username:string;role:Role}) {
  return new SignJWT(user).setProtectedHeader({alg:"HS256"}).setIssuedAt().setExpirationTime("8h").sign(secret());
}
export async function getSession() {
  const token = (await cookies()).get("ipm_session")?.value;
  if (!token) return null;
  try { return (await jwtVerify(token, secret())).payload as {id:number;username:string;role:Role}; } catch { return null; }
}
export async function requireSession() {
  const session = await getSession();
  if (!session) throw new Error("UNAUTHORIZED");
  return session;
}
export function apiError(error: unknown) {
  const message = error instanceof Error ? error.message : "Unexpected server error";
  const status = message === "UNAUTHORIZED" ? 401 : message === "FORBIDDEN" ? 403 : 400;
  return NextResponse.json({error: status === 400 ? "Request failed" : message}, {status});
}
export function requireRole(role: Role, actual: Role) {
  if (actual !== role) throw new Error("FORBIDDEN");
}
