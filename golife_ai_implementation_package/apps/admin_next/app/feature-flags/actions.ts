"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import { updateFeatureFlag } from "@/lib/api";

export async function toggleFeatureFlag(formData: FormData) {
  const key = formData.get("key");
  const enabled = formData.get("enabled");

  if (typeof key !== "string" || typeof enabled !== "string") {
    redirect("/feature-flags?error=Missing+flag+payload");
  }

  const result = await updateFeatureFlag(key, enabled === "true");
  revalidatePath("/feature-flags");

  if (result.error) {
    redirect(`/feature-flags?error=${encodeURIComponent(result.error)}`);
  }

  redirect(`/feature-flags?updated=${encodeURIComponent(key)}`);
}
