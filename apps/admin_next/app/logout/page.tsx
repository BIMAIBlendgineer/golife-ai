import { cookies } from "next/headers";
import { redirect } from "next/navigation";

const adminOperatorCookieName = "golife_admin_operator";

export default async function LogoutPage() {
  const cookieStore = await cookies();
  cookieStore.delete(adminOperatorCookieName);
  redirect("/login");
}
