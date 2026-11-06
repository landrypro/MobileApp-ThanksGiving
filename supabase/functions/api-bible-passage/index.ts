import { withSupabase } from "@supabase/server";
import {
  ApiBibleClientError,
  fetchApiBiblePassage,
} from "../_shared/api_bible_client.ts";
import { errorResponse, jsonResponse } from "../_shared/http.ts";
import { loadServerConfig } from "../_shared/server_config.ts";
import { resolveSupabaseFunctionEnv } from "../_shared/supabase_function_env.ts";

const EDITORIAL_ROLES = new Set(["admin", "editorial_admin", "editor"]);
const MAX_REQUEST_BODY_BYTES = 2_048;

Deno.serve(
  withSupabase(
    {
      auth: ["user", "secret"],
      env: resolveSupabaseFunctionEnv(),
    },
    async (request, context) => {
      const requestId = crypto.randomUUID();
      if (request.method !== "POST") {
        return errorResponse(
          "method_not_allowed",
          "Seule la méthode POST est autorisée.",
          405,
          requestId,
          { Allow: "POST, OPTIONS" },
        );
      }

      try {
        if (context.authMode === "user") {
          const authorized = await hasEditorialRole(request, context.supabase);
          if (!authorized) {
            return errorResponse(
              "editorial_role_required",
              "Un rôle éditorial est requis.",
              403,
              requestId,
            );
          }
        }

        const contentLength = Number(
          request.headers.get("content-length") ?? 0,
        );
        if (contentLength > MAX_REQUEST_BODY_BYTES) {
          return errorResponse(
            "request_too_large",
            "La requête est trop volumineuse.",
            413,
            requestId,
          );
        }
        const body = await readRequestBody(request);
        const passage = await fetchApiBiblePassage(
          loadServerConfig(),
          body,
        );
        return jsonResponse(
          {
            data: passage,
            meta: { request_id: requestId },
          },
          200,
          { "Cache-Control": "private, no-store" },
        );
      } catch (error) {
        if (error instanceof ApiBibleClientError) {
          return errorResponse(
            error.code,
            error.message,
            error.status,
            requestId,
          );
        }
        if (error instanceof RequestBodyError) {
          return errorResponse(
            error.code,
            error.message,
            error.status,
            requestId,
          );
        }
        console.error("api-bible-passage request failed", { requestId });
        return errorResponse(
          "provider_configuration_error",
          "La configuration du connecteur biblique doit être vérifiée.",
          503,
          requestId,
        );
      }
    },
  ),
);

async function hasEditorialRole(
  request: Request,
  supabase: {
    auth: {
      getUser(token?: string): Promise<{
        data: { user: { app_metadata?: Record<string, unknown> } | null };
        error: unknown;
      }>;
    };
  },
): Promise<boolean> {
  const authorization = request.headers.get("authorization") ?? "";
  const token = authorization.startsWith("Bearer ")
    ? authorization.slice("Bearer ".length)
    : "";
  if (!token) {
    return false;
  }
  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data.user) {
    return false;
  }
  const roles = data.user.app_metadata?.roles;
  if (typeof roles === "string") {
    return EDITORIAL_ROLES.has(roles);
  }
  if (Array.isArray(roles)) {
    return roles.some((role) =>
      typeof role === "string" && EDITORIAL_ROLES.has(role)
    );
  }
  return false;
}

interface PassageRequestBody {
  readonly bibleId: string;
  readonly passageId: string;
}

class RequestBodyError extends Error {
  constructor(
    readonly code: string,
    message: string,
    readonly status: number,
  ) {
    super(message);
    this.name = "RequestBodyError";
  }
}

async function readRequestBody(request: Request): Promise<PassageRequestBody> {
  let body: unknown;
  try {
    body = await request.json();
  } catch {
    throw new RequestBodyError(
      "invalid_json",
      "Le corps JSON est invalide.",
      400,
    );
  }
  if (typeof body !== "object" || body === null || Array.isArray(body)) {
    throw new RequestBodyError(
      "invalid_body",
      "Le corps de la requête est invalide.",
      400,
    );
  }
  const record = body as Record<string, unknown>;
  if (
    typeof record.bible_id !== "string" ||
    typeof record.passage_id !== "string"
  ) {
    throw new RequestBodyError(
      "invalid_body",
      "Les champs bible_id et passage_id sont obligatoires.",
      400,
    );
  }
  return {
    bibleId: record.bible_id,
    passageId: record.passage_id,
  };
}
