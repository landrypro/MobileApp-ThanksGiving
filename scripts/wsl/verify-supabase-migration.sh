#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd -- "$script_dir/../.." && pwd)"
readonly script_dir project_root
readonly network_name="tgq-supabase-local"
readonly verification_sql="$project_root/supabase/tests/verify_daily_verse_contents.sql"

fail() {
  printf 'ERREUR: %s\n' "$1" >&2
  exit 1
}

command -v docker >/dev/null 2>&1 || fail "Docker CLI est introuvable."
command -v supabase >/dev/null 2>&1 || fail "Supabase CLI est introuvable. Ouvrez un nouveau terminal WSL."

docker info >/dev/null 2>&1 || fail "Docker n'est pas accessible sans sudo. Ouvrez un nouveau terminal WSL ou exécutez newgrp docker."

supabase_version="$(supabase --version)"
[[ "$supabase_version" == 3.* ]] || fail "Supabase CLI v3 est requise; version détectée: $supabase_version."

grep -Fq '[local_smtp]' "$project_root/supabase/config.toml" || fail "La section [local_smtp] est absente de config.toml."
if grep -Fq '[inbucket]' "$project_root/supabase/config.toml"; then
  fail "La section obsolète [inbucket] est encore présente dans config.toml."
fi

if ! docker network inspect "$network_name" >/dev/null 2>&1; then
  docker network create \
    -o 'com.docker.network.bridge.host_binding_ipv4=127.0.0.1' \
    "$network_name" >/dev/null
fi

printf 'Démarrage de Supabase avec exposition limitée à localhost...\n'
supabase --workdir "$project_root" start --network-id "$network_name"

printf 'Réinitialisation locale et application des migrations...\n'
supabase --workdir "$project_root" db reset

printf 'Exécution des assertions SQL M1-06...\n'
supabase --workdir "$project_root" db query --file "$verification_sql"

printf 'Contrôle des migrations et des conseillers Supabase...\n'
supabase --workdir "$project_root" migration list
supabase --workdir "$project_root" db advisors
supabase --workdir "$project_root" status

printf '\nMigration M1-06 appliquée et vérifiée avec succès.\n'
printf 'Pour arrêter les services: supabase --workdir "%s" stop\n' "$project_root"

