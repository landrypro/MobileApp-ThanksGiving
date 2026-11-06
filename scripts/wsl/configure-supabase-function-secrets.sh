#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_directory="$(cd -- "${script_directory}/../.." && pwd)"
secret_file="${project_directory}/supabase/functions/.env"

read -r -s -p "Nouvelle clé API.Bible (entrée masquée) : " api_bible_key
printf '\n'
if [[ ! "${api_bible_key}" =~ ^[A-Za-z0-9_-]+$ ]]; then
  printf 'La clé API.Bible doit contenir uniquement des lettres, chiffres, tirets ou soulignés.\n' >&2
  exit 1
fi

printf 'Recherche des éditions françaises accessibles à cette clé...\n'
if ! candidates="$(TGQ_API_BIBLE_KEY="${api_bible_key}" python3 - <<'PY'
import json
import os
import re
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

request = Request(
    "https://rest.api.bible/v1/bibles",
    headers={"api-key": os.environ["TGQ_API_BIBLE_KEY"], "Accept": "application/json"},
)
try:
    with urlopen(request, timeout=15) as response:
        payload = json.load(response)
except HTTPError as error:
    print(f"API.Bible a refusé la recherche (HTTP {error.code}). Vérifiez la clé et les droits du compte.", file=sys.stderr)
    sys.exit(1)
except (URLError, TimeoutError, ValueError):
    print("Impossible de consulter API.Bible. Vérifiez le réseau et réessayez.", file=sys.stderr)
    sys.exit(1)

data = payload.get("data") if isinstance(payload, dict) else None
if not isinstance(data, list):
    print("API.Bible a renvoyé une liste d'éditions invalide.", file=sys.stderr)
    sys.exit(1)

french_editions = []
selected_bible_id = "a93a92589195411f-01"
selected_label = None
for item in data:
    if not isinstance(item, dict):
        continue
    bible_id = item.get("id")
    if not isinstance(bible_id, str) or not re.fullmatch(r"[A-Za-z0-9]{16}-[0-9]{2}", bible_id):
        continue
    fields = [item.get(key) for key in ("name", "nameLocal", "abbreviation", "abbreviationLocal")]
    label = " — ".join(value.strip() for value in fields if isinstance(value, str) and value.strip())
    label = " ".join(label.split())
    language = item.get("language")
    if isinstance(language, dict):
        language_label = " ".join(str(language.get(key) or "") for key in ("id", "name", "nameLocal"))
    else:
        language_label = ""
    is_french = bool(re.search(r"\bfra\b|\bfrench\b|français", language_label, re.I))
    if is_french:
        french_editions.append((bible_id, label[:150]))
    if bible_id == selected_bible_id and is_french and any(
        isinstance(value, str) and re.search(r"darby|\bjnd\b", value, re.I)
        for value in fields
    ):
        selected_label = label[:150]

if selected_label is None:
    print(f"La clé donne accès à {len(data)} édition(s), dont {len(french_editions)} édition(s) française(s).", file=sys.stderr)
    for bible_id, label in french_editions[:20]:
        print(f"  {bible_id} — {label}", file=sys.stderr)
    print("L'édition française Bible J.N. Darby attendue n'est pas accessible avec cette clé. Aucun secret enregistré.", file=sys.stderr)
    sys.exit(1)

print(f"{selected_bible_id}\t{selected_label}")
PY
)"; then
  unset api_bible_key
  exit 1
fi

bible_id="${candidates%%$'\t'*}"
printf 'Édition du pilote vérifiée : %s\n' "${candidates}"

umask 077
printf '%s\n' \
  'APP_ENV=development' \
  'API_BIBLE_ENDPOINT=https://rest.api.bible' \
  "API_BIBLE_API_KEY=${api_bible_key}" \
  "API_BIBLE_ALLOWED_BIBLE_IDS=${bible_id}" \
  'CONTENT_ALLOWED_TRANSLATIONS=fr:jnd' \
  > "${secret_file}"

unset api_bible_key
printf 'Secrets locaux enregistrés dans %s (fichier ignoré par Git).\n' "${secret_file}"
printf "L'accès API.Bible ne prouve pas à lui seul les droits de cache et de partage : vérifier la fiche de droits avant publication.\n"
printf 'Redémarrez Supabase pour charger les nouvelles valeurs.\n'
