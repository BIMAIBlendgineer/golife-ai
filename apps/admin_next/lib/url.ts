export function withSearchParams(
  entries: Record<string, string | number | null | undefined>,
): string {
  const searchParams = new URLSearchParams();
  Object.entries(entries).forEach(([key, value]) => {
    if (value == null || value === "") {
      return;
    }
    searchParams.set(key, String(value));
  });
  const query = searchParams.toString();
  return query ? `?${query}` : "";
}
