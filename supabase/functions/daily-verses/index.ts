import { withSupabase } from "@supabase/server";
import {
  ContentRepositoryError,
  fetchPublishedDailyVerseRows,
} from "../_shared/content_repository.ts";
import {
  parseDailyVerseReadQuery,
  ReadQueryError,
} from "../_shared/daily_verse_query.ts";
import { errorResponse, jsonResponse } from "../_shared/http.ts";
import { resolveSupabaseFunctionEnv } from "../_shared/supabase_function_env.ts";

const SELECTED_COLUMNS = [
  "id",
  "content_date",
  "slot",
  "language_code",
  "translation_code",
  "translation_name",
  "reference",
  "verse_text",
  "reflection",
  "action",
  "prayer",
  "attribution",
  "editorial_status",
  "version",
  "source_bible_id",
  "source_passage_id",
].join(",");

Deno.serve(
  withSupabase(
    { auth: "none", env: resolveSupabaseFunctionEnv() },
    async (request, context) => {
      const requestId = crypto.randomUUID();
      if (request.method !== "GET") {
        return errorResponse(
          "method_not_allowed",
          "Seule la méthode GET est autorisée.",
          405,
          requestId,
          { Allow: "GET, OPTIONS" },
        );
      }

      try {
        const now = new Date();
        const query = parseDailyVerseReadQuery(request.url, now);
        const rows = await fetchPublishedDailyVerseRows(
          query,
          SELECTED_COLUMNS,
          now,
        );
        const verses = rows.map(toPublicDailyVerse).sort(compareDailyVerses);
        const etag = await createEtag(verses);
        const responseHeaders = {
          "Cache-Control": "public, max-age=300, stale-while-revalidate=60",
          ETag: etag,
          Vary: "Accept-Encoding",
        };
        if (request.headers.get("If-None-Match") === etag) {
          return new Response(null, { status: 304, headers: responseHeaders });
        }

        return jsonResponse(
          {
            data: verses,
            meta: {
              request_id: requestId,
              server_time: now.toISOString(),
              from: query.from,
              to: query.to,
              language_code: query.languageCode,
              translation_code: query.translationCode,
              timezone: query.timeZone,
              mode: query.mode,
              count: verses.length,
            },
          },
          200,
          responseHeaders,
        );
      } catch (error) {
        if (error instanceof ReadQueryError) {
          return errorResponse(
            error.code,
            error.message,
            error.status,
            requestId,
          );
        }
        if (error instanceof ContentRepositoryError) {
          console.error("daily-verses database query failed", {
            requestId,
            code: error.code,
            upstreamStatus: error.upstreamStatus,
          });
          return errorResponse(
            "content_service_unavailable",
            "Le service de contenu est temporairement indisponible.",
            503,
            requestId,
          );
        }
        console.error("daily-verses request failed", { requestId });
        return errorResponse(
          "internal_error",
          "Le service de contenu a rencontré une erreur.",
          500,
          requestId,
        );
      }
    },
  ),
);

interface PublicDailyVerse {
  readonly id: string;
  readonly date: string;
  readonly slot: string;
  readonly language_code: string;
  readonly translation_code: string;
  readonly translation_name: string;
  readonly reference: string;
  readonly text: string;
  readonly reflection: string;
  readonly action: string;
  readonly prayer: string | null;
  readonly attribution: string;
  readonly status: "published";
  readonly version: number;
  readonly source_bible_id: string | null;
  readonly source_passage_id: string | null;
}

function toPublicDailyVerse(row: Record<string, unknown>): PublicDailyVerse {
  return {
    id: readString(row, "id"),
    date: readString(row, "content_date"),
    slot: readString(row, "slot"),
    language_code: readString(row, "language_code"),
    translation_code: readString(row, "translation_code"),
    translation_name: readString(row, "translation_name"),
    reference: readString(row, "reference"),
    text: readString(row, "verse_text"),
    reflection: readString(row, "reflection"),
    action: readString(row, "action"),
    prayer: readNullableString(row, "prayer"),
    attribution: readString(row, "attribution"),
    status: "published",
    version: readPositiveInteger(row, "version"),
    source_bible_id: readNullableString(row, "source_bible_id"),
    source_passage_id: readNullableString(row, "source_passage_id"),
  };
}

function readString(row: Record<string, unknown>, key: string): string {
  const value = row[key];
  if (typeof value !== "string") {
    throw new Error(`Invalid database field: ${key}`);
  }
  return value;
}

function readNullableString(
  row: Record<string, unknown>,
  key: string,
): string | null {
  const value = row[key];
  if (value !== null && typeof value !== "string") {
    throw new Error(`Invalid database field: ${key}`);
  }
  return value;
}

function readPositiveInteger(
  row: Record<string, unknown>,
  key: string,
): number {
  const value = row[key];
  if (!Number.isInteger(value) || (value as number) < 1) {
    throw new Error(`Invalid database field: ${key}`);
  }
  return value as number;
}

async function createEtag(
  verses: readonly PublicDailyVerse[],
): Promise<string> {
  const revisionSignature = verses
    .map((verse) => `${verse.id}:${verse.version}`)
    .join("|");
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(revisionSignature),
  );
  const value = [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
  return `\"${value}\"`;
}

function compareDailyVerses(
  left: PublicDailyVerse,
  right: PublicDailyVerse,
): number {
  const dateOrder = right.date.localeCompare(left.date);
  if (dateOrder !== 0) {
    return dateOrder;
  }
  const slotOrder: Record<string, number> = {
    morning: 0,
    midday: 1,
    evening: 2,
  };
  return (slotOrder[left.slot] ?? 99) - (slotOrder[right.slot] ?? 99);
}
