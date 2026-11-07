import { withSupabase } from "@supabase/server";
import { errorResponse, jsonResponse } from "../_shared/http.ts";
import { resolveSupabaseFunctionEnv } from "../_shared/supabase_function_env.ts";

const ROLES = new Set([
  "admin", "editorial_admin", "editor", "biblical_reviewer",
  "linguistic_reviewer", "approver",
]);
const ACTIONS = new Set([
  "create", "edit", "submit", "biblical_approve", "linguistic_approve",
  "approve", "schedule", "publish", "withdraw", "request_changes",
]);
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const MAX_BODY_BYTES = 32_768;

Deno.serve(withSupabase(
  { auth: "user", env: resolveSupabaseFunctionEnv() },
  async (request, context) => {
    const requestId = crypto.randomUUID();
    const token = request.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
    if (!token) {
      return errorResponse("authentication_required", "Connexion requise.", 401, requestId);
    }
    const { data: { user }, error: authError } = await context.supabase.auth.getUser(token);
    if (authError || !user) {
      return errorResponse("authentication_required", "Session invalide.", 401, requestId);
    }
    const rawRoles = user.app_metadata?.roles;
    const roles = (Array.isArray(rawRoles) ? rawRoles : [rawRoles])
      .filter((role): role is string => typeof role === "string" && ROLES.has(role));
    if (!roles.length) {
      return errorResponse("editorial_role_required", "Un rôle éditorial est requis.", 403, requestId);
    }

    if (request.method === "GET") {
      const url = new URL(request.url);
      const id = url.searchParams.get("id");
      if (id && !UUID.test(id)) {
        return errorResponse("invalid_id", "Identifiant invalide.", 400, requestId);
      }
      if (id) {
        const [content, events] = await Promise.all([
          context.supabaseAdmin.from("daily_verse_contents").select("*").eq("id", id).maybeSingle(),
          context.supabaseAdmin.from("editorial_events").select("*").eq("content_id", id)
            .order("occurred_at", { ascending: false }).limit(100),
        ]);
        if (content.error || events.error) {
          console.error("editorial detail failed", { requestId, content: content.error, events: events.error });
          return errorResponse("database_error", "Lecture impossible.", 503, requestId);
        }
        if (!content.data) {
          return errorResponse("not_found", "Contenu introuvable.", 404, requestId);
        }
        return jsonResponse({ data: { content: content.data, events: events.data }, meta: { request_id: requestId } });
      }
      const status = url.searchParams.get("status");
      const offset = Number(url.searchParams.get("offset") ?? "0");
      if (!Number.isSafeInteger(offset) || offset < 0 || offset > 100_000) {
        return errorResponse("invalid_offset", "Pagination invalide.", 400, requestId);
      }
      let query = context.supabaseAdmin.from("daily_verse_contents")
        .select("id,content_date,slot,language_code,translation_code,translation_name,reference,editorial_status,version,created_by,biblical_reviewed_by,linguistic_reviewed_by,approved_by,updated_at")
        .order("content_date", { ascending: true }).order("slot", { ascending: true })
        .order("id", { ascending: true }).range(offset, offset + 99);
      if (status) query = query.eq("editorial_status", status);
      const { data, error } = await query;
      if (error) {
        console.error("editorial list failed", { requestId, error });
        return errorResponse("database_error", "Liste indisponible.", 503, requestId);
      }
      return jsonResponse({ data, meta: { request_id: requestId } });
    }

    if (request.method !== "POST") {
      return errorResponse("method_not_allowed", "Méthode non autorisée.", 405, requestId, { Allow: "GET, POST, OPTIONS" });
    }
    const contentLength = Number(request.headers.get("content-length") ?? "0");
    if (contentLength > MAX_BODY_BYTES) {
      return errorResponse("request_too_large", "Requête trop volumineuse.", 413, requestId);
    }
    let body: Record<string, unknown>;
    try {
      const text = await request.text();
      if (new TextEncoder().encode(text).length > MAX_BODY_BYTES) throw new Error("too_large");
      const parsed: unknown = JSON.parse(text);
      if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) throw new Error("invalid_body");
      body = parsed as Record<string, unknown>;
    } catch {
      return errorResponse("invalid_body", "Corps JSON invalide ou trop volumineux.", 400, requestId);
    }
    const action = body.action;
    const contentId = body.content_id;
    const payload = body.payload;
    if (typeof action !== "string" || !ACTIONS.has(action) ||
      (contentId !== null && contentId !== undefined &&
        (typeof contentId !== "string" || !UUID.test(contentId))) ||
      !payload || typeof payload !== "object" || Array.isArray(payload)) {
      return errorResponse("invalid_body", "Action, identifiant ou données invalides.", 400, requestId);
    }
    if (action === "publish" && !(
      ["development", "test"].includes(Deno.env.get("APP_ENV") ?? "") &&
      Deno.env.get("EDITORIAL_DEMO_PUBLICATION_ENABLED") === "true"
    )) {
      return errorResponse("publication_disabled", "Publication suspendue en attente des droits.", 403, requestId);
    }

    const { data, error } = await context.supabaseAdmin.rpc("editorial_apply", {
      p_action: action,
      p_content_id: contentId ?? null,
      p_payload: payload,
      p_actor_id: user.id,
      p_actor_roles: roles,
    });
    if (error) {
      const known = [
        "publication_rights_pending", "editorial_role_required", "draft_owner_required",
        "biblical_reviewer_required", "linguistic_reviewer_required",
        "independent_approver_required", "editorial_manager_required",
        "withdrawal_reason_and_manager_required", "reviewer_required",
        "review_reason_required", "content_not_found",
      ];
      const code = known.find((value) => error.message.includes(value));
      if (!code) console.error("editorial mutation failed", { requestId, error });
      return errorResponse(code ?? "editorial_validation_failed", code ?? "Données ou transition invalides.",
        code === "content_not_found" ? 404 : code?.includes("required") || code === "publication_rights_pending" ? 403 : 400, requestId);
    }
    return jsonResponse({ data, meta: { request_id: requestId } }, action === "create" ? 201 : 200);
  },
));
