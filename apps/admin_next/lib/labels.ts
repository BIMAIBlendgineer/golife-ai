import type { AdminMessages } from "@/lib/i18n";
import { labelizeKey } from "@/lib/format";

export function labelAdminPlan(value: string, messages: AdminMessages): string {
  switch (value.toLowerCase()) {
    case "free":
      return messages.shared.planFree;
    case "plus":
      return messages.shared.planPlus;
    case "internal":
      return messages.shared.planInternal;
    case "family":
      return messages.shared.planFamily;
    case "team":
      return messages.shared.planTeam;
    case "enterprise":
      return messages.shared.planEnterprise;
    default:
      return value;
  }
}

export function labelAdminStatus(value: string, messages: AdminMessages): string {
  switch (value.toLowerCase()) {
    case "active":
      return messages.shared.statusActive;
    case "paused":
      return messages.shared.statusPaused;
    case "trial":
      return messages.shared.statusTrial;
    case "completed":
      return messages.shared.statusCompleted;
    case "open":
      return messages.shared.statusOpen;
    case "resolved":
      return messages.shared.statusResolved;
    case "monitoring":
      return messages.shared.statusMonitoring;
    case "high":
      return messages.shared.statusHigh;
    case "healthy":
      return messages.shared.statusHealthy;
    case "degraded":
      return messages.shared.statusDegraded;
    case "disabled":
      return messages.shared.disabled;
    case "enabled":
      return messages.shared.enabled;
    default:
      return value;
  }
}

export function labelAdminPrivacyRequestStatus(
  value: string,
  messages: AdminMessages,
): string {
  switch (value.toLowerCase()) {
    case "export_open":
      return messages.shared.statusExportOpen;
    case "delete_open":
      return messages.shared.statusDeleteOpen;
    case "mixed_open":
      return messages.shared.statusMixedOpen;
    case "completed":
      return messages.shared.statusCompleted;
    case "none":
      return messages.shared.none;
    default:
      return value;
  }
}

export function labelFeatureFlagKey(value: string, messages: AdminMessages): string {
  const labels = messages.pages.featureFlags.flagTitles as Record<string, string>;
  return labels[value] ?? labelizeKey(value);
}

export function labelFeatureFlagDescription(
  value: string,
  fallback: string,
  messages: AdminMessages,
): string {
  const labels = messages.pages.featureFlags.flagDescriptions as Record<string, string>;
  return labels[value] ?? fallback;
}
