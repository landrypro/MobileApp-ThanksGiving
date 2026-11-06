#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_directory="$(cd -- "${script_directory}/../.." && pwd)"
secret_file="${project_directory}/supabase/functions/.env"

read -r -s -p "Nouvelle clé API.Bible (entrée masquée) : " api_bible_key
printf '\n'
read -r -p "Bible ID LSG 1910 autorisé dans votre compte API.Bible : " bible_id

if [[ -z "${api_bible_key}" ]]; then
  printf 'La clé API.Bible ne peut pas être vide.\n' >&2
  exit 1
fi
if [[ ! "${bible_id}" =~ ^[A-Za-z0-9]{16}-[0-9]{2}$ ]]; then
  printf 'Le Bible ID doit suivre le format xxxxxxxxxxxxxxxx-01.\n' >&2
  exit 1
fi

umask 077
printf '%s\n' \
  'APP_ENV=development' \
  'API_BIBLE_ENDPOINT=https://rest.api.bible' \
  "API_BIBLE_API_KEY=${api_bible_key}" \
  "API_BIBLE_ALLOWED_BIBLE_IDS=${bible_id}" \
  'CONTENT_ALLOWED_TRANSLATIONS=fr:lsg1910' \
  > "${secret_file}"

unset api_bible_key
printf 'Secrets locaux enregistrés dans %s (fichier ignoré par Git).\n' "${secret_file}"
printf 'Redémarrez Supabase pour charger les nouvelles valeurs.\n'
