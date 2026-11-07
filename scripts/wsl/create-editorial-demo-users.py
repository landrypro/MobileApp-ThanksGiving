#!/usr/bin/env python3
"""Crée quatre comptes Supabase Auth locaux pour parcourir M1-08."""

import json
import os
import secrets
import shlex
import subprocess
import urllib.error
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CREDS = ROOT / "admin" / ".demo-login.local.txt"
ROLES = [
    ("Rédacteur", ["editor"]),
    ("Relecteur biblique", ["biblical_reviewer"]),
    ("Relecteur linguistique", ["linguistic_reviewer"]),
    ("Approbateur et responsable éditorial", ["approver", "editorial_admin"]),
]


def request(url, method, key, payload=None):
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode() if payload is not None else None,
        headers={"apikey": key, "Authorization": f"Bearer {key}",
                 "Content-Type": "application/json"},
        method=method,
    )
    with urllib.request.urlopen(req, timeout=30) as response:
        return json.load(response) if method != "DELETE" else None


def main():
    if CREDS.exists():
        raise SystemExit(f"Comptes déjà créés : {CREDS}")
    output = subprocess.check_output(
        ["supabase", "--workdir", str(ROOT), "status", "-o", "env"], text=True
    )
    config = {}
    for line in output.splitlines():
        if "=" in line:
            name, value = line.split("=", 1)
            parsed = shlex.split(value)
            if parsed:
                config[name] = parsed[0]
    api, key = config["API_URL"], config["SERVICE_ROLE_KEY"]
    suffix = secrets.token_hex(4)
    users = []
    lines = ["COMPTES DE DÉMONSTRATION LOCAUX — ne pas utiliser en production", ""]
    try:
        for label, roles in ROLES:
            email = f"m108-{roles[0]}-{suffix}@example.test"
            password = secrets.token_urlsafe(24)
            user = request(f"{api}/auth/v1/admin/users", "POST", key, {
                "email": email, "password": password, "email_confirm": True,
                "app_metadata": {"roles": roles},
            })
            users.append(user["id"])
            lines += [label, f"E-mail : {email}", f"Mot de passe : {password}", ""]
        descriptor = os.open(CREDS, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(descriptor, "w", encoding="utf-8") as file:
            file.write("\n".join(lines))
    except (OSError, urllib.error.HTTPError):
        for user_id in users:
            try:
                request(f"{api}/auth/v1/admin/users/{user_id}", "DELETE", key)
            except urllib.error.HTTPError:
                pass
        raise
    print(f"Quatre comptes locaux créés. Identifiants enregistrés dans {CREDS} (ignoré par Git).")


if __name__ == "__main__":
    main()
