import { NextResponse } from "next/server";

const ADMIN_API_BASE_URL =
  process.env.GOLIFE_ADMIN_API_BASE_URL ?? "http://127.0.0.1:8010";
const ADMIN_API_TOKEN =
  process.env.GOLIFE_ADMIN_API_TOKEN ??
  (process.env.NODE_ENV === "production" ? "" : "golife-admin-dev");

export async function GET(
  _: Request,
  context: { params: Promise<{ requestId: string }> },
) {
  const { requestId } = await context.params;
  const response = await fetch(
    `${ADMIN_API_BASE_URL}/admin/support/export-delete/${requestId}/bundle`,
    {
      cache: "no-store",
      headers: {
        "x-admin-token": ADMIN_API_TOKEN,
      },
      signal: AbortSignal.timeout(5000),
    },
  );

  if (!response.ok) {
    return NextResponse.json(
      {
        error: `Unable to generate export bundle for ${requestId}.`,
      },
      { status: response.status },
    );
  }

  const body = await response.text();
  return new NextResponse(body, {
    status: 200,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "content-disposition": `attachment; filename="golife_operational_export_${requestId}.json"`,
    },
  });
}
