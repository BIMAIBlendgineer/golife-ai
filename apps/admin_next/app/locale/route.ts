import { NextRequest, NextResponse } from "next/server";

import { adminLocaleCookieName, normalizeAdminLocale } from "@/lib/i18n";

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;
  const locale = normalizeAdminLocale(searchParams.get("locale"));
  const rawRedirectPath = searchParams.get("redirectPath") ?? "/dashboard";
  const redirectPath = rawRedirectPath.startsWith("/") ? rawRedirectPath : "/dashboard";

  const response = NextResponse.redirect(new URL(redirectPath, request.url));
  response.cookies.set(adminLocaleCookieName, locale, {
    httpOnly: false,
    sameSite: "lax",
    path: "/",
    maxAge: 60 * 60 * 24 * 365,
  });
  return response;
}
