export type ServerEnvironment = "development" | "test" | "production";

export interface ServerConfig {
  readonly environment: ServerEnvironment;
  readonly apiBibleEndpoint: URL;
  readonly apiBibleApiKey: string;
}

/**
 * Charge uniquement la configuration privée des fonctions serveur.
 *
 * La clé API.Bible n'est ni journalisée ni renvoyée aux clients. Ce module
 * reste sous `supabase/functions` afin qu'aucun import Flutter ne soit possible.
 */
export function loadServerConfig(
  variables: Record<string, string | undefined> = Deno.env.toObject(),
): ServerConfig {
  const environment = readEnvironment(variables.APP_ENV ?? "development");
  const apiBibleEndpoint = readHttpsUrl(
    variables.API_BIBLE_ENDPOINT ?? "https://rest.api.bible",
    "API_BIBLE_ENDPOINT",
  );
  const apiBibleApiKey = requireSecret(
    variables.API_BIBLE_API_KEY,
    "API_BIBLE_API_KEY",
  );

  return Object.freeze({
    environment,
    apiBibleEndpoint,
    apiBibleApiKey,
  });
}

function readEnvironment(value: string): ServerEnvironment {
  if (value === "development" || value === "test" || value === "production") {
    return value;
  }
  throw new Error("APP_ENV doit valoir development, test ou production.");
}

function readHttpsUrl(value: string, name: string): URL {
  let parsed: URL;
  try {
    parsed = new URL(value);
  } catch {
    throw new Error(`${name} doit être une URL absolue.`);
  }
  if (parsed.protocol !== "https:") {
    throw new Error(`${name} doit utiliser HTTPS.`);
  }
  if (parsed.username || parsed.password || parsed.search || parsed.hash) {
    throw new Error(`${name} ne doit contenir ni identifiants ni paramètres.`);
  }
  return parsed;
}

function requireSecret(value: string | undefined, name: string): string {
  if (!value?.trim()) {
    throw new Error(`${name} est absent de l'environnement serveur.`);
  }
  return value.trim();
}

