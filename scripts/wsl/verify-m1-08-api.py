#!/usr/bin/env python3
"""Test local de l'API éditoriale, sans API.Bible ni texte biblique réel."""

import json
import re
import secrets
import shlex
import subprocess
import urllib.error
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
UUID = re.compile(r"^[0-9a-f-]{36}$")


def local_config():
    output = subprocess.check_output(
        ["supabase", "--workdir", str(ROOT), "status", "-o", "env"], text=True
    )
    values = {}
    for line in output.splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            parsed = shlex.split(value)
            if parsed:
                values[key] = parsed[0]
    return values


def call(url, method="GET", payload=None, key=None, token=None):
    headers = {}
    if key:
        headers["apikey"] = key
    if token:
        headers["Authorization"] = f"Bearer {token}"
    if payload is not None:
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode() if payload is not None else None,
        headers=headers,
        method=method,
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        try:
            return error.code, json.load(error)
        except json.JSONDecodeError:
            return error.code, {}


def create_user(api, service_key, roles):
    email = f"m108-{secrets.token_hex(6)}@example.test"
    password = secrets.token_urlsafe(24)
    status, body = call(
        f"{api}/auth/v1/admin/users", "POST",
        {"email": email, "password": password, "email_confirm": True,
         "app_metadata": {"roles": roles}}, service_key, service_key,
    )
    assert status in (200, 201), f"Création utilisateur : HTTP {status}: {body}"
    return body["id"], email, password


def main():
    config = local_config()
    api = config["API_URL"]
    anon = config["ANON_KEY"]
    service = config["SERVICE_ROLE_KEY"]
    endpoint = f"{api}/functions/v1/editorial-contents"
    users = []
    created_content = None
    try:
        status, _ = call(endpoint)
        assert status == 401, f"Sans session : HTTP {status} attendu 401"

        viewer = create_user(api, service, [])
        users.append(viewer[0])
        status, session = call(
            f"{api}/auth/v1/token?grant_type=password", "POST",
            {"email": viewer[1], "password": viewer[2]}, anon,
        )
        assert status == 200, f"Connexion sans rôle : HTTP {status}"
        status, _ = call(endpoint, key=anon, token=session["access_token"])
        assert status == 403, f"Sans rôle : HTTP {status} attendu 403"

        editor = create_user(api, service, ["editor", "editorial_admin"])
        users.append(editor[0])
        status, session = call(
            f"{api}/auth/v1/token?grant_type=password", "POST",
            {"email": editor[1], "password": editor[2]}, anon,
        )
        assert status == 200, f"Connexion éditeur : HTTP {status}"
        token = session["access_token"]
        status, body = call(endpoint, key=anon, token=token)
        assert status == 200, f"Liste éditoriale : HTTP {status}: {body}"
        assert any(item["content_date"] == "2099-01-01" for item in body["data"]), \
            "Les trois fiches fictives locales sont absentes."
        status, _ = call(f"{endpoint}?offset=-1", key=anon, token=token)
        assert status == 400, f"Pagination invalide : HTTP {status} attendu 400"

        status, body = call(endpoint, "POST", {
            "action": "create", "content_id": None,
            "payload": {
                "content_date": "2099-03-03", "slot": "morning", "language_code": "fr",
                "translation_code": "demo", "translation_name": "Démonstration",
                "reference": "DÉMO 3:1", "verse_text": "Texte fictif, aucun verset.",
                "reflection": "Réflexion fictive.", "action": "Action fictive.",
                "attribution": "Démonstration uniquement.", "source_provider": "demo",
            },
        }, anon, token)
        assert status == 201, f"Création de brouillon : HTTP {status}: {body}"
        created_content = body["data"]["id"]
        assert UUID.fullmatch(created_content)
        status, body = call(endpoint, "POST", {
            "action": "submit", "content_id": created_content, "payload": {},
        }, anon, token)
        assert status == 200 and body["data"]["editorial_status"] == "biblical_review", \
            f"Soumission : HTTP {status}: {body}"
        status, body = call(endpoint, "POST", {
            "action": "biblical_approve", "content_id": created_content, "payload": {},
        }, anon, token)
        assert status == 403, f"Auto-relecture : HTTP {status} attendu 403"
        status, body = call(f"{endpoint}?id={created_content}", key=anon, token=token)
        assert status == 200 and len(body["data"]["events"]) == 2, \
            f"Historique : HTTP {status}: {body}"
        print("M1-08 API : anonyme 401, sans rôle 403, lecture, brouillon, soumission et audit validés.")
    finally:
        if created_content and UUID.fullmatch(created_content):
            sql = (
                f"delete from public.editorial_events where content_id = '{created_content}'; "
                f"delete from public.daily_verse_contents where id = '{created_content}';"
            )
            subprocess.run(
                ["docker", "exec", "supabase_db_MobileApp_ThanksGiving", "psql",
                 "-U", "postgres", "-d", "postgres", "-v", "ON_ERROR_STOP=1", "-c", sql],
                check=True, capture_output=True,
            )
        for user_id in users:
            call(f"{api}/auth/v1/admin/users/{user_id}", "DELETE", key=service, token=service)


if __name__ == "__main__":
    main()
