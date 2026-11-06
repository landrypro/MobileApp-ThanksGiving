import type { ServerConfig } from "./server_config.ts";

const BIBLE_ID_PATTERN = /^[A-Za-z0-9]{16}-[0-9]{2}$/;
const PASSAGE_ID_PATTERN =
  /^[A-Z0-9]{2,6}\.[0-9]+(?:\.[0-9]+)?(?:-[A-Z0-9]{2,6}\.[0-9]+(?:\.[0-9]+)?)?$/;

export interface ApiBiblePassageRequest {
  readonly bibleId: string;
  readonly passageId: string;
}

export interface ApiBiblePassage {
  readonly provider: "api.bible";
  readonly bibleId: string;
  readonly passageId: string;
  readonly reference: string;
  readonly content: string;
  readonly verseCount: number;
  readonly copyright: string;
  readonly sourceUrl: string;
  readonly fetchedAt: string;
  readonly sha256: string;
}

export class ApiBibleClientError extends Error {
  constructor(
    readonly code: string,
    message: string,
    readonly status: number,
  ) {
    super(message);
    this.name = "ApiBibleClientError";
  }
}

export async function fetchApiBiblePassage(
  config: ServerConfig,
  request: ApiBiblePassageRequest,
  fetchImplementation: typeof fetch = fetch,
  now: () => Date = () => new Date(),
): Promise<ApiBiblePassage> {
  validateRequest(config, request);
  const sourceUrl = buildPassageUrl(config.apiBibleEndpoint, request);
  const abortController = new AbortController();
  const timeout = setTimeout(() => abortController.abort(), 8_000);

  let response: Response;
  try {
    response = await fetchImplementation(sourceUrl, {
      method: "GET",
      headers: {
        Accept: "application/json",
        "api-key": config.apiBibleApiKey,
      },
      signal: abortController.signal,
    });
  } catch {
    throw new ApiBibleClientError(
      "provider_unavailable",
      "Le fournisseur biblique est temporairement indisponible.",
      503,
    );
  } finally {
    clearTimeout(timeout);
  }

  if (!response.ok) {
    throw mapProviderError(response.status);
  }

  let payload: unknown;
  try {
    payload = await response.json();
  } catch {
    throw new ApiBibleClientError(
      "invalid_provider_response",
      "La réponse du fournisseur biblique est invalide.",
      502,
    );
  }
  const data = readPassageData(payload);
  if (data.bibleId !== request.bibleId) {
    throw new ApiBibleClientError(
      "provider_mismatch",
      "Le fournisseur a retourné une édition biblique inattendue.",
      502,
    );
  }

  return Object.freeze({
    provider: "api.bible",
    bibleId: data.bibleId,
    passageId: data.id,
    reference: data.reference,
    content: data.content,
    verseCount: data.verseCount,
    copyright: data.copyright,
    sourceUrl: sourceUrl.toString(),
    fetchedAt: now().toISOString(),
    sha256: await sha256(data.content),
  });
}

function validateRequest(
  config: ServerConfig,
  request: ApiBiblePassageRequest,
): void {
  if (!BIBLE_ID_PATTERN.test(request.bibleId)) {
    throw new ApiBibleClientError(
      "invalid_bible_id",
      "L'identifiant de Bible est invalide.",
      400,
    );
  }
  if (!config.apiBibleAllowedBibleIds.includes(request.bibleId)) {
    throw new ApiBibleClientError(
      "bible_not_allowed",
      "Cette édition biblique n'est pas autorisée.",
      403,
    );
  }
  if (!PASSAGE_ID_PATTERN.test(request.passageId)) {
    throw new ApiBibleClientError(
      "invalid_passage_id",
      "L'identifiant de passage est invalide.",
      400,
    );
  }
}

function buildPassageUrl(
  endpoint: URL,
  request: ApiBiblePassageRequest,
): URL {
  const base = endpoint.toString().replace(/\/+$/, "");
  const url = new URL(
    `${base}/v1/bibles/${encodeURIComponent(request.bibleId)}/passages/${
      encodeURIComponent(request.passageId)
    }`,
  );
  url.searchParams.set("content-type", "text");
  url.searchParams.set("include-notes", "false");
  url.searchParams.set("include-titles", "false");
  url.searchParams.set("include-chapter-numbers", "false");
  url.searchParams.set("include-verse-numbers", "false");
  url.searchParams.set("include-verse-spans", "false");
  return url;
}

function mapProviderError(status: number): ApiBibleClientError {
  if (status === 404) {
    return new ApiBibleClientError(
      "passage_not_found",
      "Le passage demandé est introuvable.",
      404,
    );
  }
  if (status === 429) {
    return new ApiBibleClientError(
      "provider_rate_limited",
      "Le fournisseur biblique limite temporairement les requêtes.",
      503,
    );
  }
  if (status === 400) {
    return new ApiBibleClientError(
      "provider_rejected_request",
      "Le fournisseur biblique a refusé ce passage.",
      422,
    );
  }
  if (status === 401 || status === 403) {
    return new ApiBibleClientError(
      "provider_authorization_failed",
      "La configuration du fournisseur biblique doit être vérifiée.",
      502,
    );
  }
  return new ApiBibleClientError(
    "provider_error",
    "Le fournisseur biblique a retourné une erreur.",
    502,
  );
}

interface PassageData {
  readonly id: string;
  readonly bibleId: string;
  readonly content: string;
  readonly reference: string;
  readonly verseCount: number;
  readonly copyright: string;
}

function readPassageData(payload: unknown): PassageData {
  if (!isRecord(payload) || !isRecord(payload.data)) {
    throw invalidProviderResponse();
  }
  const data = payload.data;
  const id = readString(data, "id");
  const bibleId = readString(data, "bibleId");
  const content = readString(data, "content");
  const reference = readString(data, "reference");
  const copyright = readString(data, "copyright", true);
  const verseCount = data.verseCount;
  if (!Number.isInteger(verseCount) || (verseCount as number) < 1) {
    throw invalidProviderResponse();
  }
  if (!content.trim() || !reference.trim()) {
    throw invalidProviderResponse();
  }
  return {
    id,
    bibleId,
    content,
    reference,
    verseCount: verseCount as number,
    copyright,
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readString(
  record: Record<string, unknown>,
  key: string,
  allowEmpty = false,
): string {
  const value = record[key];
  if (typeof value !== "string" || (!allowEmpty && !value.trim())) {
    throw invalidProviderResponse();
  }
  return value;
}

function invalidProviderResponse(): ApiBibleClientError {
  return new ApiBibleClientError(
    "invalid_provider_response",
    "La réponse du fournisseur biblique est invalide.",
    502,
  );
}

async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}
