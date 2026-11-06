#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_directory="$(cd -- "${script_directory}/../.." && pwd)"
project_id="MobileApp_ThanksGiving"
database_container="supabase_db_${project_id}"
fixture_date="2000-01-01"

if [[ -d "${HOME}/.supabase/bin" ]]; then
  export PATH="${HOME}/.supabase/bin:${PATH}"
fi

cleanup() {
  docker exec "${database_container}" psql -v ON_ERROR_STOP=1 -U postgres -d postgres \
    -c "delete from public.daily_verse_contents where id::text like '10000000-0000-4000-8000-00000000000%';" \
    >/dev/null 2>&1 || true
}
trap cleanup EXIT

supabase --workdir "${project_directory}" status >/dev/null
cleanup

docker exec -i "${database_container}" psql -v ON_ERROR_STOP=1 -U postgres -d postgres <<'SQL'
insert into public.daily_verse_contents (
  id, content_date, slot, language_code, translation_code, translation_name,
  reference, verse_text, reflection, action, attribution, editorial_status,
  version, published_at
) values
  ('10000000-0000-4000-8000-000000000001', date '2000-01-01', 'morning', 'fr', 'lsg1910', 'Louis Segond 1910', 'Test 1:1', 'Texte technique matin.', 'Réflexion technique.', 'Action technique.', 'Attribution technique.', 'published', 1, now()),
  ('10000000-0000-4000-8000-000000000002', date '2000-01-01', 'midday', 'fr', 'lsg1910', 'Louis Segond 1910', 'Test 1:2', 'Texte technique midi.', 'Réflexion technique.', 'Action technique.', 'Attribution technique.', 'published', 1, now()),
  ('10000000-0000-4000-8000-000000000003', date '2000-01-01', 'evening', 'fr', 'lsg1910', 'Louis Segond 1910', 'Test 1:3', 'Texte technique soir.', 'Réflexion technique.', 'Action technique.', 'Attribution technique.', 'published', 1, now()),
  ('10000000-0000-4000-8000-000000000004', date '2000-01-01', 'morning', 'fr', 'testdraft', 'Test Draft', 'Test 1:4', 'Brouillon invisible.', 'Réflexion technique.', 'Action technique.', 'Attribution technique.', 'draft', 1, null);
SQL

fixture_count="$(docker exec "${database_container}" psql -At -U postgres -d postgres \
  -c "select count(*) from public.daily_verse_contents where content_date = date '${fixture_date}';")"
if [[ "${fixture_count}" != "4" ]]; then
  printf 'Quatre fixtures M1-07 attendues dans PostgreSQL, nombre reçu : %s.\n' "${fixture_count}" >&2
  exit 1
fi

response_file="$(mktemp)"
trap 'rm -f "${response_file}"; cleanup' EXIT
http_status="$(curl --silent --show-error --output "${response_file}" --write-out '%{http_code}' \
  'http://127.0.0.1:54321/functions/v1/daily-verses?date=2000-01-01&language=fr&translation=lsg1910&timezone=UTC')"
if [[ "${http_status}" != "200" ]]; then
  printf 'daily-verses a répondu HTTP %s.\n' "${http_status}" >&2
  exit 1
fi

python3 - "${response_file}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as response:
    payload = json.load(response)

assert payload["meta"]["count"] == 3, payload
assert [item["slot"] for item in payload["data"]] == ["morning", "midday", "evening"], payload
assert all(item["status"] == "published" for item in payload["data"]), payload
assert all(item["translation_code"] == "lsg1910" for item in payload["data"]), payload
assert not any("Brouillon invisible" in item["text"] for item in payload["data"]), payload
PY

future_status="$(curl --silent --output /dev/null --write-out '%{http_code}' \
  'http://127.0.0.1:54321/functions/v1/daily-verses?date=2999-01-01&timezone=UTC')"
if [[ "${future_status}" != "404" ]]; then
  printf 'Une date future aurait dû répondre 404, reçu %s.\n' "${future_status}" >&2
  exit 1
fi

private_status="$(curl --silent --output /dev/null --write-out '%{http_code}' \
  --request POST --header 'Content-Type: application/json' \
  --data '{"bible_id":"0123456789abcdef-01","passage_id":"PSA.100.4"}' \
  'http://127.0.0.1:54321/functions/v1/api-bible-passage')"
if [[ "${private_status}" != "401" ]]; then
  printf 'Le connecteur privé aurait dû répondre 401 sans identité, reçu %s.\n' "${private_status}" >&2
  exit 1
fi

printf 'M1-07 : lecture publiée, filtre futur et protection API.Bible validés.\n'
