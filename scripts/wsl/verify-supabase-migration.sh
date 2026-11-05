#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd -- "$script_dir/../.." && pwd)"
readonly script_dir project_root
readonly network_name="tgq-supabase-local"
readonly config_file="$project_root/supabase/config.toml"
readonly verification_sql="$project_root/supabase/tests/verify_daily_verse_contents.sql"
readonly user_supabase_bin="$HOME/.supabase/bin"

fail() {
  printf 'ERREUR: %s\n' "$1" >&2
  exit 1
}

command -v docker >/dev/null 2>&1 || fail "Docker CLI est introuvable."

# L'installation épinglée du projet doit passer avant une ancienne CLI globale.
if [[ -x "$user_supabase_bin/supabase" ]]; then
  export PATH="$user_supabase_bin:$PATH"
  hash -r
fi

command -v supabase >/dev/null 2>&1 || fail "Supabase CLI est introuvable. Ouvrez un nouveau terminal WSL."

docker info >/dev/null 2>&1 || fail "Docker n'est pas accessible sans sudo. Ouvrez un nouveau terminal WSL ou exécutez newgrp docker."

supabase_version="$(supabase --version)"
supabase_path="$(command -v supabase)"
[[ "$supabase_version" == 3.* ]] || fail "Supabase CLI v3 est requise; version détectée: $supabase_version ($supabase_path)."

grep -Fq '[local_smtp]' "$config_file" || fail "La section [local_smtp] est absente de config.toml."
if grep -Fq '[inbucket]' "$config_file"; then
  fail "La section obsolète [inbucket] est encore présente dans config.toml."
fi

project_id="$(sed -n 's/^project_id = "\([^"]*\)"/\1/p' "$config_file" | head -n 1)"
[[ "$project_id" =~ ^[A-Za-z0-9_-]+$ ]] || fail "project_id est absent ou invalide dans config.toml."
db_container="supabase_db_${project_id}"

if ! docker network inspect "$network_name" >/dev/null 2>&1; then
  docker network create \
    -o 'com.docker.network.bridge.host_binding_ipv4=127.0.0.1' \
    "$network_name" >/dev/null
fi

printf 'Démarrage de Supabase avec exposition limitée à localhost...\n'
supabase --workdir "$project_root" stop >/dev/null 2>&1 || true
supabase --workdir "$project_root" start --network-id "$network_name"

printf 'Réinitialisation locale et application des migrations...\n'
set +e
supabase --workdir "$project_root" db reset
reset_status=$?
set -e

if (( reset_status != 0 )); then
  printf 'Le reset a appliqué la migration mais le réseau temporaire a interrompu les contrôles de santé; reconstruction sécurisée en cours...\n'
fi

# db reset recrée PostgreSQL sur le réseau Supabase par défaut. Recréer toute
# la pile rattache PostgreSQL et les services au même réseau localhost.
supabase --workdir "$project_root" stop
supabase --workdir "$project_root" start --network-id "$network_name"

docker inspect "$db_container" >/dev/null 2>&1 || fail "Le conteneur PostgreSQL $db_container est introuvable."

printf 'Exécution des assertions SQL M1-06...\n'
docker exec -i "$db_container" \
  psql -v ON_ERROR_STOP=1 -U postgres -d postgres <"$verification_sql"

printf 'Contrôle des migrations et des conseillers Supabase...\n'
supabase --workdir "$project_root" migration list
supabase --workdir "$project_root" db advisors
supabase --workdir "$project_root" status

printf '\nMigration M1-06 appliquée et vérifiée avec succès.\n'
printf 'Pour arrêter les services: supabase --workdir "%s" stop\n' "$project_root"

