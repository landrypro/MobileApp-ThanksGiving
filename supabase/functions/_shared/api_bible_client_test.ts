import {
  ApiBibleClientError,
  fetchApiBiblePassage,
} from "./api_bible_client.ts";
import type { ServerConfig } from "./server_config.ts";

const allowedBibleId = "0123456789abcdef-01";
const config: ServerConfig = {
  environment: "test",
  apiBibleEndpoint: new URL("https://rest.api.bible"),
  apiBibleApiKey: "test-secret-not-a-real-key",
  apiBibleAllowedBibleIds: [allowedBibleId],
};

Deno.test("le connecteur API.Bible garde la clé dans l'en-tête", async () => {
  let capturedUrl = "";
  let capturedKey = "";
  const fakeFetch = (input: string | URL | Request, init?: RequestInit) => {
    capturedUrl = input.toString();
    capturedKey = new Headers(init?.headers).get("api-key") ?? "";
    return Promise.resolve(
      Response.json({
        data: {
          id: "PSA.100.4",
          bibleId: allowedBibleId,
          orgId: "PSA.100.4",
          content: "Texte technique de vérification.",
          reference: "Psaume 100:4",
          verseCount: 1,
          copyright: "Attribution de test",
        },
      }),
    );
  };

  const passage = await fetchApiBiblePassage(
    config,
    { bibleId: allowedBibleId, passageId: "PSA.100.4" },
    fakeFetch as typeof fetch,
    () => new Date("2026-11-05T12:00:00Z"),
  );

  assertEquals(capturedKey, config.apiBibleApiKey);
  assertEquals(capturedUrl.includes(config.apiBibleApiKey), false);
  assertEquals(passage.reference, "Psaume 100:4");
  assertEquals(passage.fetchedAt, "2026-11-05T12:00:00.000Z");
  assertEquals(passage.sha256.length, 64);
});

Deno.test("le connecteur refuse une Bible hors allowlist sans appel réseau", async () => {
  let called = false;
  const fakeFetch = () => {
    called = true;
    return Promise.resolve(new Response(null, { status: 500 }));
  };

  await assertRejectsCode(
    () =>
      fetchApiBiblePassage(
        config,
        {
          bibleId: "fedcba9876543210-01",
          passageId: "PSA.100.4",
        },
        fakeFetch as typeof fetch,
      ),
    "bible_not_allowed",
  );
  assertEquals(called, false);
});

Deno.test("le connecteur traduit la limitation fournisseur en erreur sûre", async () => {
  const fakeFetch = () => Promise.resolve(new Response(null, { status: 429 }));
  await assertRejectsCode(
    () =>
      fetchApiBiblePassage(
        config,
        { bibleId: allowedBibleId, passageId: "PSA.100.4" },
        fakeFetch as typeof fetch,
      ),
    "provider_rate_limited",
  );
});

async function assertRejectsCode(
  action: () => Promise<unknown>,
  expectedCode: string,
): Promise<void> {
  try {
    await action();
  } catch (error) {
    if (error instanceof ApiBibleClientError && error.code === expectedCode) {
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
