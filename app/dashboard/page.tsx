import {redirect} from "next/navigation";
import {getSession} from "@/lib/auth";
import DashboardClient from "./ui";
export default async function Dashboard(){const session=await getSession();if(!session)redirect("/login");return <DashboardClient username={session.username} role={session.role}/>}
