"use server";

import { timingSafeEqual } from "node:crypto";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";

const operatorCookieName = "golife_admin_operator";
const configuredOperatorSecret =
  process.env.ADMIN_OPERATOR_SECRET?.trim() ??
  process.env.GOLIFE_ADMIN_OPERATOR_SECRET?.trim() ??
  "";

function operatorSecretMatches(expected: string, provided: string): boolean {
  const expectedBuffer = Buffer.from(expected, "utf8");
  const providedBuffer = Buffer.from(provided, "utf8");
  if (expectedBuffer.length !== providedBuffer.length) {
    return false;
  }
  return timingSafeEqual(expectedBuffer, providedBuffer);
}

export async function signInScaffold(formData: FormData) {
  const providedSecret = String(formData.get("secret") ?? "").trim();
  if (
    configuredOperatorSecret &&
    !operatorSecretMatches(configuredOperatorSecret, providedSecret)
  ) {
    redirect("/login?error=invalid_secret");
  }
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
