import mysql from "mysql2/promise";
import { MongoClient, Db } from "mongodb";

declare global {
  // eslint-disable-next-line no-var
  var mysqlPool: mysql.Pool | undefined;
  // eslint-disable-next-line no-var
  var mongoClientPromise: Promise<MongoClient> | undefined;
}
export const sql = global.mysqlPool ?? mysql.createPool({
  host: process.env.MYSQL_HOST, port: Number(process.env.MYSQL_PORT || 3306),
  user: process.env.MYSQL_USER, password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE, waitForConnections: true, connectionLimit: 10,
  decimalNumbers: true, timezone: "Z"
});
if (process.env.NODE_ENV !== "production") global.mysqlPool = sql;

const uri = process.env.MONGODB_URI;
if (!uri) throw new Error("MONGODB_URI is required");
const client = new MongoClient(uri);
const clientPromise = global.mongoClientPromise ?? client.connect();
if (process.env.NODE_ENV !== "production") global.mongoClientPromise = clientPromise;
export async function mongoDb(): Promise<Db> {
  return (await clientPromise).db(process.env.MONGODB_DATABASE || "industrial_maintenance");
}
