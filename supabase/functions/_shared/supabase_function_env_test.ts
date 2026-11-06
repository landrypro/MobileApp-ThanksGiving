import { resolveSupabaseFunctionEnv } from "./supabase_function_env.ts";

Deno.test("le pont local privilégie les clés legacy reconnues par PostgREST", () => {
  const resolved = resolveSupabaseFunctionEnv({
    SUPABASE_URL: "http://kong:8000",
    SUPABASE_INTERNAL_PUBLISHABLE_KEY: "internal-publishable",
    SUPABASE_INTERNAL_SECRET_KEY: "internal-secret",
    SUPABASE_ANON_KEY: "legacy-anon",
    SUPABASE_SERVICE_ROLE_KEY: "legacy-service-role",
  });

  assertEquals(resolved.url, "http://kong:8000");
  assertEquals(resolved.publishableKeys?.default, "legacy-anon");
  assertEquals(resolved.secretKeys?.default, "legacy-service-role");
});

Deno.test("le pont n'écrase pas les variables plurielles hébergées", () => {
  const resolved = resolveSupabaseFunctionEnv({
    SUPABASE_URL: "https://project.supabase.co",
    SUPABASE_PUBLISHABLE_KEYS: '{"default":"hosted-publishable"}',
    SUPABASE_SECRET_KEYS: '{"default":"hosted-secret"}',
  });

  assertEquals(resolved.url, "https://project.supabase.co");
  assertEquals(resolved.publishableKeys, undefined);
  assertEquals(resolved.secretKeys, undefined);
});

function assertEquals(actual: unknown, expected: unknown): void {
  if (!Object.is(actual, expected)) {
    throw new Error(`Valeur attendue ${expected}, valeur reçue ${actual}.`);
  }
}
