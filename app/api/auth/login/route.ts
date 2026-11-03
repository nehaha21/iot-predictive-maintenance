import {NextRequest,NextResponse} from "next/server";
import {sql} from "@/lib/db";
import {createToken} from "@/lib/auth";
import bcrypt from "bcryptjs";
export async function POST(req:NextRequest){try{
 const {username,password}=await req.json();
 if(typeof username!=="string"||typeof password!=="string"||!username||!password)return NextResponse.json({error:"Username and password are required"},{status:400});
 const [rows]:any=await sql.execute("SELECT id, username, password_hash, role, is_active FROM users WHERE username = ? LIMIT 1",[username]);
 const u=rows[0]; if(!u||!u.is_active||!(await bcrypt.compare(password,u.password_hash)))return NextResponse.json({error:"Invalid username or password"},{status:401});
 const token=await createToken({id:u.id,username:u.username,role:u.role});
 const res=NextResponse.json({ok:true,username:u.username,role:u.role});
 res.cookies.set("ipm_session",token,{httpOnly:true,sameSite:"lax",secure:process.env.NODE_ENV==="production",path:"/",maxAge:28800});return res;
 }catch(e){return NextResponse.json({error:"Login service unavailable. Check database configuration."},{status:500})}}
