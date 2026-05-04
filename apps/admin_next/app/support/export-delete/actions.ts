"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import {
  executeDeleteSupportRequest,
  resolveSupportRequest,
} from "@/lib/api";

function readRequestId(formData: FormData): string {
  const requestId = formData.get("requestId");
  if (typeof requestId !== "string" || requestId.length === 0) {
    redirect("/support/export-delete?error=Missing+support+request+id");
  }
  return requestId;
}

function refreshSupportSurfaces() {
  revalidatePath("/support/export-delete");
  revalidatePath("/privacy");
  revalidatePath("/users");
  revalidatePath("/dashboard");
  revalidatePath("/incidents");
}

export async function markSupportRequestResolved(formData: FormData) {
  const requestId = readRequestId(formData);
  const result = await resolveSupportRequest(requestId);
  refreshSupportSurfaces();

  if (result.error) {
    redirect(`/support/export-delete?error=${encodeURIComponent(result.error)}`);
  }

  redirect(
    `/support/export-delete?updated=${encodeURIComponent(requestId)}&action=resolved`,
  );
}

export async function executeSupportDelete(formData: FormData) {
  const requestId = readRequestId(formData);
  const result = await executeDeleteSupportRequest(requestId);
  refreshSupportSurfaces();

  if (result.error) {
    redirect(`/support/export-delete?error=${encodeURIComponent(result.error)}`);
  }

  redirect(
    `/support/export-delete?updated=${encodeURIComponent(requestId)}&action=deleted`,
  );
}
