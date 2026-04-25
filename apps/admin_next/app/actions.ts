"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import { adminLocaleCookieName, normalizeAdminLocale } from "@/lib/i18n";

export async function setAdminLocale(formData: FormData) {
  const locale = normalizeAdminLocale(formData.get("locale")?.toString());
  const redirectPath = formData.get("redirectPath")?.toString() || "/dashboard";
  const cookieStore = await cookies();
  cookieStore.set(adminLocaleCookieName, locale, {
    httpOnly: false,
    sameSite: "lax",
    path: "/",
    maxAge: 60 * 60 * 24 * 365,
  });
  redirect(redirectPath.startsWith("/") ? redirectPath : "/dashboard");
}
