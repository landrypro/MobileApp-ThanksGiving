import {
  parseDailyVerseReadQuery,
  readAllowedTranslations,
  ReadQueryError,
} from "./daily_verse_query.ts";

Deno.test("daily-verses utilise la date civile du fuseau demandé", () => {
  const query = parseDailyVerseReadQuery(
    "https://example.test/functions/v1/daily-verses?timezone=Pacific/Kiritimati",
    new Date("2026-11-04T12:30:00Z"),
    new Set(["fr:lsg1910"]),
  );
  assertEquals(query.from, "2026-11-05");
  assertEquals(query.to, "2026-11-05");
  assertEquals(query.translationCode, "lsg1910");
});

Deno.test("daily-verses accepte un historique de trente jours", () => {
  const query = parseDailyVerseReadQuery(
    "https://example.test/functions/v1/daily-verses?from=2026-10-06&to=2026-11-04&language=fr&translation=lsg1910&timezone=UTC",
    new Date("2026-11-05T12:00:00Z"),
    new Set(["fr:lsg1910"]),
  );
  assertEquals(query.mode, "history");
  assertEquals(query.from, "2026-10-06");
  assertEquals(query.to, "2026-11-04");
});

Deno.test("daily-verses refuse une date future", () => {
  assertThrowsCode(
    () =>
      parseDailyVerseReadQuery(
        "https://example.test/functions/v1/daily-verses?date=2026-11-06&timezone=UTC",
        new Date("2026-11-05T12:00:00Z"),
        new Set(["fr:lsg1910"]),
      ),
    "future_content_forbidden",
  );
});

Deno.test("daily-verses refuse une traduction non autorisée", () => {
  assertThrowsCode(
    () =>
      parseDailyVerseReadQuery(
        "https://example.test/functions/v1/daily-verses?translation=bfc&timezone=UTC",
        new Date("2026-11-05T12:00:00Z"),
        new Set(["fr:lsg1910"]),
      ),
    "translation_not_available",
  );
});

Deno.test("la liste des traductions autorisées est validée", () => {
  const allowed = readAllowedTranslations("fr:lsg1910,en:kjv");
  assertEquals(allowed.has("fr:lsg1910"), true);
  assertEquals(allowed.has("en:kjv"), true);
  assertEquals(allowed.size, 2);
});

function assertThrowsCode(action: () => unknown, expectedCode: string): void {
  try {
    action();
  } catch (error) {
    if (error instanceof ReadQueryError && error.code === expectedCode) {
      return;
    }
    throw error;
  }
  throw new Error(`L'erreur ${expectedCode} était attendue.`);
}

function assertEquals(actual: unknown, expected: unknown): void {
  if (!Object.is(actual, expected)) {
    throw new Error(`Valeur attendue ${expected}, valeur reçue ${actual}.`);
  }
}
