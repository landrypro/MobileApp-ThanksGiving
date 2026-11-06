import { fetchPublishedDailyVerseRows } from "./content_repository.ts";
import type { DailyVerseReadQuery } from "./daily_verse_query.ts";

const query: DailyVerseReadQuery = {
  from: "2026-11-05",
  to: "2026-11-05",
  languageCode: "fr",
  translationCode: "jnd",
  timeZone: "UTC",
  mode: "day",
};

Deno.test("le dépôt utilise le JWT service_role comme apikey et Bearer", async () => {
  const jwt = "header.payload.signature";
  let capturedHeaders = new Headers();
  let capturedUrl = "";
  const fakeFetch = (input: string | URL | Request, init?: RequestInit) => {
    capturedUrl = input.toString();
    capturedHeaders = new Headers(init?.headers);
    return Promise.resolve(Response.json([]));
  };

  await fetchPublishedDailyVerseRows(
    query,
    "id,content_date",
    new Date("2026-11-05T12:00:00Z"),
    {
      SUPABASE_URL: "http://kong:8000",
      SUPABASE_SERVICE_ROLE_KEY: jwt,
    },
    fakeFetch as typeof fetch,
  );

  assertEquals(capturedHeaders.get("apikey"), jwt);
  assertEquals(capturedHeaders.get("authorization"), `Bearer ${jwt}`);
  assertEquals(capturedUrl.includes("editorial_status=eq.published"), true);
});

Deno.test("le dépôt n'envoie pas une clé opaque comme Bearer", async () => {
  let capturedHeaders = new Headers();
  const fakeFetch = (_input: string | URL | Request, init?: RequestInit) => {
    capturedHeaders = new Headers(init?.headers);
    return Promise.resolve(Response.json([]));
  };

  await fetchPublishedDailyVerseRows(
    query,
    "id",
    new Date("2026-11-05T12:00:00Z"),
    {
      SUPABASE_URL: "https://example.supabase.co",
      SUPABASE_SECRET_KEYS: '{"default":"opaque-secret-example"}',
    },
    fakeFetch as typeof fetch,
  );

  assertEquals(capturedHeaders.get("apikey"), "opaque-secret-example");
  assertEquals(capturedHeaders.has("authorization"), false);
});

function assertEquals(actual: unknown, expected: unknown): void {
  if (!Object.is(actual, expected)) {
    throw new Error(`Valeur attendue ${expected}, valeur reçue ${actual}.`);
  }
}
