import { loadServerConfig } from "./server_config.ts";

Deno.test("la configuration serveur charge une liste de Bible IDs unique", () => {
  const config = loadServerConfig({
    APP_ENV: "test",
    API_BIBLE_ENDPOINT: "https://rest.api.bible",
    API_BIBLE_API_KEY: "test-secret-not-a-real-key",
    API_BIBLE_ALLOWED_BIBLE_IDS: "0123456789abcdef-01,0123456789abcdef-01",
  });

  assertEquals(config.environment, "test");
  assertEquals(config.apiBibleEndpoint.toString(), "https://rest.api.bible/");
  assertEquals(config.apiBibleAllowedBibleIds.length, 1);
});

Deno.test("la configuration serveur refuse une allowlist vide", () => {
  try {
    loadServerConfig({
      APP_ENV: "test",
      API_BIBLE_ENDPOINT: "https://rest.api.bible",
      API_BIBLE_API_KEY: "test-secret-not-a-real-key",
      API_BIBLE_ALLOWED_BIBLE_IDS: "",
    });
  } catch (error) {
    if (
      error instanceof Error &&
      error.message.includes("API_BIBLE_ALLOWED_BIBLE_IDS")
    ) {
      return;
    }
    throw error;
  }
  throw new Error("Une allowlist vide aurait dû être refusée.");
});

function assertEquals(actual: unknown, expected: unknown): void {
  if (!Object.is(actual, expected)) {
    throw new Error(`Valeur attendue ${expected}, valeur reçue ${actual}.`);
  }
}
