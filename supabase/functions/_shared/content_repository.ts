import type { DailyVerseReadQuery } from "./daily_verse_query.ts";

export class ContentRepositoryError extends Error {
  constructor(
    readonly code: string,
    readonly upstreamStatus?: number,
  ) {
    super("Le dépôt de contenu est indisponible.");
    this.name = "ContentRepositoryError";
  }
}

export async function fetchPublishedDailyVerseRows(
  query: DailyVerseReadQuery,
  selectedColumns: string,
  now: Date,
  variables: Record<string, string | undefined> = Deno.env.toObject(),
  fetchImplementation: typeof fetch = fetch,
): Promise<Record<string, unknown>[]> {
  const apiUrl = requireApiUrl(variables.SUPABASE_URL);
  const secretKey = requireSecretKey(variables);
  const url = new URL("rest/v1/daily_verse_contents", apiUrl);
  url.searchParams.set("select", selectedColumns);
  url.searchParams.set("language_code", `eq.${query.languageCode}`);
  url.searchParams.set("translation_code", `eq.${query.translationCode}`);
  url.searchParams.set("editorial_status", "eq.published");
  url.searchParams.set("published_at", `lte.${now.toISOString()}`);
  url.searchParams.append("content_date", `gte.${query.from}`);
  url.searchParams.append("content_date", `lte.${query.to}`);
  url.searchParams.set("order", "content_date.desc,slot.asc");
  url.searchParams.set("limit", "90");

  const headers = new Headers({
    Accept: "application/json",
    apikey: secretKey,
  });
  if (isJwt(secretKey)) {
    headers.set("Authorization", `Bearer ${secretKey}`);
  }

  let response: Response;
  try {
    response = await fetchImplementation(url, { method: "GET", headers });
  } catch {
    throw new ContentRepositoryError("database_unreachable");
  }
  if (!response.ok) {
    throw new ContentRepositoryError(
      "database_rejected_request",
      response.status,
    );
  }

  let payload: unknown;
  try {
    payload = await response.json();
  } catch {
    throw new ContentRepositoryError("invalid_database_response");
  }
  if (!Array.isArray(payload) || payload.some((row) => !isRecord(row))) {
    throw new ContentRepositoryError("invalid_database_response");
  }
  return payload as Record<string, unknown>[];
}

function requireApiUrl(value: string | undefined): URL {
  if (!value?.trim()) {
    throw new ContentRepositoryError("missing_supabase_url");
  }
  try {
    const url = new URL(value);
    if (url.protocol !== "https:" && url.protocol !== "http:") {
      throw new Error("invalid protocol");
    }
    if (!url.pathname.endsWith("/")) {
      url.pathname = `${url.pathname}/`;
    }
    return url;
  } catch {
    throw new ContentRepositoryError("invalid_supabase_url");
  }
}

function requireSecretKey(
  variables: Record<string, string | undefined>,
): string {
  const pluralKey = readDefaultNamedKey(variables.SUPABASE_SECRET_KEYS);
  const secretKey = firstNonBlank(
    pluralKey,
    variables.SUPABASE_SECRET_KEY,
    variables.SUPABASE_SERVICE_ROLE_KEY,
    variables.SUPABASE_INTERNAL_SECRET_KEY,
  );
  if (!secretKey) {
    throw new ContentRepositoryError("missing_supabase_secret_key");
  }
  return secretKey;
}

function readDefaultNamedKey(value: string | undefined): string | undefined {
  if (!value) {
    return undefined;
  }
  try {
    const parsed: unknown = JSON.parse(value);
    if (isRecord(parsed) && typeof parsed.default === "string") {
      return parsed.default;
    }
  } catch {
    return undefined;
  }
  return undefined;
}

function firstNonBlank(
  ...values: readonly (string | undefined)[]
): string | undefined {
  return values.find((value) => value?.trim())?.trim();
}

function isJwt(value: string): boolean {
  return value.split(".").length === 3;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
