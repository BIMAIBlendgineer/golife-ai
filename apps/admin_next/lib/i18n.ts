import { cookies } from "next/headers";

import en from "@/messages/en.json";
import es from "@/messages/es.json";
import ja from "@/messages/ja.json";
import ptBR from "@/messages/pt-BR.json";
import zhHans from "@/messages/zh-Hans.json";

export const adminLocales = ["en", "es", "pt-BR", "ja", "zh-Hans"] as const;
export type AdminLocale = (typeof adminLocales)[number];

export type AdminMessages = typeof en;
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends Array<infer U>
    ? Array<DeepPartial<U>>
    : T[K] extends object
      ? DeepPartial<T[K]>
      : T[K];
};

const localeCookieName = "golife_admin_locale";

const localeMap: Record<AdminLocale, DeepPartial<AdminMessages>> = {
  en,
  es,
  "pt-BR": ptBR,
  ja,
  "zh-Hans": zhHans,
};

function mergeMessages<T>(base: T, overrides: DeepPartial<T>): T {
  if (Array.isArray(base)) {
    return ((overrides as T | undefined) ?? base) as T;
  }
  if (base && typeof base === "object") {
    const result: Record<string, unknown> = { ...(base as Record<string, unknown>) };
    for (const [key, value] of Object.entries(
      (overrides as Record<string, unknown> | undefined) ?? {},
    )) {
      if (value === undefined) {
        continue;
      }
      const baseValue = (base as Record<string, unknown>)[key];
      if (
        value &&
        typeof value === "object" &&
        !Array.isArray(value) &&
        baseValue &&
        typeof baseValue === "object" &&
        !Array.isArray(baseValue)
      ) {
        result[key] = mergeMessages(baseValue, value as DeepPartial<typeof baseValue>);
      } else {
        result[key] = value;
      }
    }
    return result as T;
  }
  return ((overrides as T | undefined) ?? base) as T;
}

export function normalizeAdminLocale(rawValue?: string | null): AdminLocale {
  const normalized = (rawValue ?? "").trim().replaceAll("_", "-").toLowerCase();
  if (normalized === "es" || normalized.startsWith("es-")) {
    return "es";
  }
  if (normalized === "pt" || normalized === "pt-br") {
    return "pt-BR";
  }
  if (normalized === "ja" || normalized.startsWith("ja-")) {
    return "ja";
  }
  if (
    normalized === "zh" ||
    normalized === "zh-cn" ||
    normalized === "zh-hans" ||
    normalized.startsWith("zh-")
  ) {
    return "zh-Hans";
  }
  return "en";
}

export async function getAdminLocale(): Promise<AdminLocale> {
  const cookieStore = await cookies();
  return normalizeAdminLocale(cookieStore.get(localeCookieName)?.value);
}

export async function getAdminMessages(): Promise<{
  locale: AdminLocale;
  messages: AdminMessages;
}> {
  const locale = await getAdminLocale();
  const localized = localeMap[locale];
  const merged = mergeMessages(en, localized);
  const hasFullNavParity =
    merged.nav.sections.length === en.nav.sections.length &&
    merged.nav.sections.every((section, index) => {
      const baseSection = en.nav.sections[index];
      return (
        section.items.length === baseSection.items.length &&
        section.items.every((item, itemIndex) => item.href === baseSection.items[itemIndex]?.href)
      );
    });
  return {
    locale,
    messages: hasFullNavParity
      ? merged
      : {
          ...merged,
          nav: {
            ...merged.nav,
            sections: en.nav.sections,
          },
        },
  };
}

export const adminLocaleCookieName = localeCookieName;

export function intlLocaleForAdmin(locale: AdminLocale): string {
  switch (locale) {
    case "es":
      return "es-ES";
    case "pt-BR":
      return "pt-BR";
    case "ja":
      return "ja-JP";
    case "zh-Hans":
      return "zh-CN";
    case "en":
    default:
      return "en-US";
  }
}
