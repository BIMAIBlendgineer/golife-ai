"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";

const operatorCookieName = "golife_admin_operator";

export async function signInScaffold(formData: FormData) {
  const operator =
    String(formData.get("operator") ?? "")
      .trim()
      .slice(0, 64) || "operator";
  const cookieStore = await cookies();
  cookieStore.set(operatorCookieName, operator, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: 60 * 60 * 8,
  });
  redirect("/dashboard");
}
