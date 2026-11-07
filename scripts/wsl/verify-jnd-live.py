#!/usr/bin/env python3
"""Vérifie JND via API.Bible et le connecteur Supabase sans exposer les clés."""

import hashlib
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


PROJECT_DIR = Path(__file__).resolve().parents[2]
ENV_FILE = PROJECT_DIR / "supabase" / "functions" / ".env"
EVIDENCE_FILE = PROJECT_DIR / "supabase" / "JND_RIGHTS_EVIDENCE.json"
BIBLE_ID = "a93a92589195411f-01"
PASSAGE_ID = "PSA.100.4"


def fail(message):
    print(f"ERREUR: {message}", file=sys.stderr)
    raise SystemExit(1)


def load_secrets():
    if not ENV_FILE.is_file():
        fail("exécutez d'abord configure-supabase-function-secrets.sh dans WSL.")
    values = {}
    for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
        if "=" in line and not line.lstrip().startswith("#"):
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip()
    if not values.get("API_BIBLE_API_KEY"):
        fail("la clé API.Bible locale est absente.")
    if values.get("API_BIBLE_ALLOWED_BIBLE_IDS") != BIBLE_ID:
        fail("l'identifiant biblique local ne correspond pas à JND.")
    if values.get("CONTENT_ALLOWED_TRANSLATIONS") != "fr:jnd":
        fail("la traduction locale n'est pas fr:jnd.")
    if values.get("API_BIBLE_ENDPOINT") != "https://rest.api.bible":
        fail("le point d'accès API.Bible attendu n'est pas configuré.")
    return values


def request_json(url, headers, body=None):
    request = Request(
        url,
        data=body,
        headers=headers,
        method="POST" if body is not None else "GET",
    )
    try:
        with urlopen(request, timeout=20) as response:
            return response.status, json.load(response)
    except HTTPError as error:
        try:
            payload = json.load(error)
            code = payload.get("error", {}).get("code", "unknown")
        except (ValueError, AttributeError):
            code = "unknown"
        return error.code, {"error_code": code}
    except (URLError, TimeoutError, ValueError):
        fail("requête réseau impossible ou réponse JSON invalide.")


def load_metadata(api_key):
    status, payload = request_json(
        f"https://rest.api.bible/v1/bibles/{BIBLE_ID}",
        {"api-key": api_key, "Accept": "application/json"},
    )
    if status != 200 or not isinstance(payload.get("data"), dict):
        fail(f"métadonnées API.Bible indisponibles (HTTP {status}).")
    data = payload["data"]
    if data.get("id") != BIBLE_ID:
        fail("API.Bible a renvoyé une autre édition.")
    language = data.get("language") or {}
    if language.get("id") not in ("fra", "fr"):
        fail("la langue de l'édition n'est pas le français attendu.")
    return {
        "id": data.get("id"),
        "name": data.get("name"),
        "name_local": data.get("nameLocal"),
        "abbreviation": data.get("abbreviation"),
        "abbreviation_local": data.get("abbreviationLocal"),
        "language": language,
        "copyright": data.get("copyright"),
        "description": data.get("description"),
        "description_local": data.get("descriptionLocal"),
        "info": data.get("info"),
        "updated_at": data.get("updatedAt"),
        "source_url": f"https://rest.api.bible/v1/bibles/{BIBLE_ID}",
        "retrieved_at": datetime.now(timezone.utc).isoformat(),
    }


def load_local_supabase_status():
    result = subprocess.run(
        ["supabase", "status", "-o", "json", "--workdir", str(PROJECT_DIR)],
        capture_output=True,
        text=True,
        check=False,
        timeout=45,
    )
    if result.returncode != 0:
        fail("Supabase local n'est pas démarré.")
    try:
        return json.loads(result.stdout)
    except ValueError:
        fail("la CLI Supabase n'a pas renvoyé un état JSON valide.")


def verify_private_connector(status):
    functions_url = status.get("FUNCTIONS_URL")
    if not isinstance(functions_url, str) or not functions_url.startswith("http://127.0.0.1:"):
        fail("l'URL locale des Edge Functions est absente ou inattendue.")
    keys = [status.get("SECRET_KEY"), status.get("SERVICE_ROLE_KEY")]
    keys = [key for key in keys if isinstance(key, str) and key]
    if not keys:
        fail("aucune clé serveur locale n'est disponible dans Supabase status.")
    body = json.dumps({"bible_id": BIBLE_ID, "passage_id": PASSAGE_ID}).encode()
    last_status = None
    last_error = None
    for key in keys:
        http_status, payload = request_json(
            f"{functions_url.rstrip('/')}/api-bible-passage",
            {
                "apikey": key,
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
            body,
        )
        if http_status == 200:
            data = payload.get("data")
            if not isinstance(data, dict) or data.get("bibleId") != BIBLE_ID:
                fail("le connecteur privé a renvoyé une édition inattendue.")
            content = data.get("content")
            if not isinstance(content, str) or not content.strip():
                fail("le connecteur privé n'a pas renvoyé de texte biblique.")
            digest = hashlib.sha256(content.encode("utf-8")).hexdigest()
            if data.get("sha256") != digest:
                fail("l'empreinte du passage ne correspond pas au texte reçu.")
            return {
                "http_status": http_status,
                "reference": data.get("reference"),
                "passage_id": data.get("passageId"),
                "verse_count": data.get("verseCount"),
                "sha256": digest,
                "fetched_at": data.get("fetchedAt"),
                "source_url": data.get("sourceUrl"),
                "copyright": data.get("copyright"),
            }
        last_status = http_status
        last_error = payload.get("error_code", "unknown")
        if http_status != 401:
            break
    fail(f"connecteur privé : HTTP {last_status}, code {last_error}.")


def main():
    if sys.argv[1:] not in (
        ["--account-and-license-confirmed"],
        ["--account-and-license-confirmed", "--rights-reviewed"],
    ):
        fail(
            "le titulaire du compte et l'accord du projet doivent être validés avant ce test ; "
            "utilisez --account-and-license-confirmed après validation."
        )
    secrets = load_secrets()
    metadata = load_metadata(secrets["API_BIBLE_API_KEY"])
    evidence = {
        "edition": metadata,
        "private_connector_probe": None,
        "rights_assessment": "à établir selon les métadonnées et l'accord applicable",
    }
    if "--rights-reviewed" in sys.argv:
        status = load_local_supabase_status()
        passage = verify_private_connector(status)
        evidence["private_connector_probe"] = passage
    EVIDENCE_FILE.write_text(
        json.dumps(evidence, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    if "--rights-reviewed" in sys.argv:
        print(f"JND vérifiée via le connecteur privé : {passage['reference']}.")
        print("Aucune clé ni texte de verset n'a été enregistré dans cette preuve.")
    else:
        print("Métadonnées JND relevées ; relisez-les avant le test du passage.")
    print(f"Preuve enregistrée dans {EVIDENCE_FILE}.")


if __name__ == "__main__":
    main()
