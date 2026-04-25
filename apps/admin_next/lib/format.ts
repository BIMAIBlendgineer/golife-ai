import type { AdminLocale, AdminMessages } from "@/lib/i18n";
import { intlLocaleForAdmin } from "@/lib/i18n";

function asIntlLocale(locale: AdminLocale): string {
  return intlLocaleForAdmin(locale);
}

export function formatPercent(value: number, locale: AdminLocale = "en"): string {
  return new Intl.NumberFormat(asIntlLocale(locale), {
    style: "percent",
    maximumFractionDigits: 1,
  }).format(value);
}

export function formatCurrency(value: number, locale: AdminLocale = "en"): string {
  return new Intl.NumberFormat(asIntlLocale(locale), {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 2,
  }).format(value);
}

export function formatNumber(value: number, locale: AdminLocale = "en"): string {
  return new Intl.NumberFormat(asIntlLocale(locale), {
    maximumFractionDigits: 2,
  }).format(value);
}

export function formatDateTime(
  value: string,
  locale: AdminLocale = "en",
): string {
  return new Intl.DateTimeFormat(asIntlLocale(locale), {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));
}

export function formatLatency(
  value: number,
  locale: AdminLocale = "en",
  unitLabel = "ms",
): string {
  return `${Math.round(value)} ${unitLabel}`;
}

export function formatFeedbackReason(
  value: string | null,
  messages: AdminMessages,
): string {
  if (!value) {
    return messages.shared.noPrivateNoteRecorded;
  }
  if (value === "private_note_redacted") {
    return messages.shared.privateNoteRedacted;
  }
  return messages.shared.legacyPrivateNoteRedacted;
}

export function labelizeKey(value: string): string {
  return value
      .split(/[_-]/g)
      .filter(Boolean)
      .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
      .join(" ");
}
