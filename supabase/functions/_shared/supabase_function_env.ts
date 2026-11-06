export interface SupabaseFunctionEnvOverrides {
  readonly url?: string;
  readonly publishableKeys?: Readonly<Record<string, string>>;
  readonly secretKeys?: Readonly<Record<string, string>>;
}

/**
 * Adapte le runtime local Supabase CLI au contrat récent de @supabase/server.
 *
 * Les projets hébergés fournissent déjà les variables plurielles modernes. Le
 * pont ne les remplace pas. En local, certaines versions du runtime exposent
 * encore les clés sous les noms INTERNAL ou legacy.
 */
export function resolveSupabaseFunctionEnv(
  variables: Record<string, string | undefined> = Deno.env.toObject(),
): SupabaseFunctionEnvOverrides {
  const url = variables.SUPABASE_URL?.trim();
  const publishableKey = firstNonBlank(
    variables.SUPABASE_PUBLISHABLE_KEY,
    variables.SUPABASE_ANON_KEY,
    variables.SUPABASE_INTERNAL_PUBLISHABLE_KEY,
  );
  const secretKey = firstNonBlank(
    variables.SUPABASE_SECRET_KEY,
    variables.SUPABASE_SERVICE_ROLE_KEY,
    variables.SUPABASE_INTERNAL_SECRET_KEY,
  );

  return Object.freeze({
    ...(url ? { url } : {}),
    ...(publishableKey
      ? { publishableKeys: Object.freeze({ default: publishableKey }) }
      : {}),
    ...(secretKey ? { secretKeys: Object.freeze({ default: secretKey }) } : {}),
  });
}

function firstNonBlank(
  ...values: readonly (string | undefined)[]
): string | undefined {
  return values.find((value) => value?.trim())?.trim();
}
