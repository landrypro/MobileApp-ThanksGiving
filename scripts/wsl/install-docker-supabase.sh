#!/usr/bin/env bash

set -Eeuo pipefail

readonly SUPABASE_CLI_VERSION="${SUPABASE_CLI_VERSION:-3.0.0}"
readonly DOCKER_SOURCE_FILE="/etc/apt/sources.list.d/docker.sources"
readonly LEGACY_DOCKER_SOURCE_FILE="/etc/apt/sources.list.d/docker.list"
readonly DISABLED_LEGACY_DOCKER_SOURCE_FILE="/etc/apt/sources.list.d/docker.list.disabled"

fail() {
  printf 'ERREUR: %s\n' "$1" >&2
  exit 1
}

if [[ "${EUID}" -eq 0 ]]; then
  fail "Exécutez ce script avec votre utilisateur Linux normal, pas avec root."
fi

command -v sudo >/dev/null 2>&1 || fail "sudo est requis."

# shellcheck source=/dev/null
source /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || fail "Ce script cible Ubuntu sous WSL 2. Distribution détectée: ${ID:-inconnue}."

init_process="$(ps -p 1 -o comm= | tr -d '[:space:]')"
[[ "$init_process" == "systemd" ]] || fail "systemd n'est pas actif. Consultez DOCKER_WSL_SETUP.md puis exécutez wsl.exe --shutdown depuis Windows."

printf 'Validation sudo...\n'
sudo -v

conflicting_packages=(
  docker.io
  docker-compose
  docker-compose-v2
  docker-doc
  docker-buildx
  podman-docker
  containerd
  runc
)
installed_conflicts=()
for package_name in "${conflicting_packages[@]}"; do
  if dpkg-query -W -f='${db:Status-Status}' "$package_name" 2>/dev/null | grep -q '^installed$'; then
    installed_conflicts+=("$package_name")
  fi
done

if (( ${#installed_conflicts[@]} > 0 )); then
  printf 'Paquets Docker conflictuels détectés: %s\n' "${installed_conflicts[*]}" >&2
  fail "Aucune suppression automatique n'est effectuée. Examinez ces paquets avant de continuer."
fi

printf 'Installation du dépôt officiel Docker...\n'
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

ubuntu_codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
[[ -n "$ubuntu_codename" ]] || fail "Le nom de version Ubuntu est introuvable."
docker_architecture="$(dpkg --print-architecture)"

if [[ -f "$LEGACY_DOCKER_SOURCE_FILE" ]] &&
   grep -Fq 'download.docker.com/linux/ubuntu' "$LEGACY_DOCKER_SOURCE_FILE"; then
  if [[ -e "$DISABLED_LEGACY_DOCKER_SOURCE_FILE" ]]; then
    fail "Le dépôt Docker historique et sa sauvegarde .disabled existent déjà. Examinez-les manuellement."
  fi
  printf 'Désactivation récupérable de l’ancien dépôt Docker %s...\n' "$LEGACY_DOCKER_SOURCE_FILE"
  sudo mv "$LEGACY_DOCKER_SOURCE_FILE" "$DISABLED_LEGACY_DOCKER_SOURCE_FILE"
fi

printf '%s\n' \
  'Types: deb' \
  'URIs: https://download.docker.com/linux/ubuntu' \
  "Suites: $ubuntu_codename" \
  'Components: stable' \
  "Architectures: $docker_architecture" \
  'Signed-By: /etc/apt/keyrings/docker.asc' |
  sudo tee "$DOCKER_SOURCE_FILE" >/dev/null

sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo systemctl enable --now docker
sudo groupadd --force docker
sudo usermod -aG docker "$USER"

printf 'Test du moteur Docker...\n'
sudo docker run --rm hello-world

printf 'Installation de Supabase CLI %s avec l’installateur officiel...\n' "$SUPABASE_CLI_VERSION"
curl -fsSL https://raw.githubusercontent.com/supabase/cli/main/install |
  bash -s -- --version "$SUPABASE_CLI_VERSION" --no-modify-path

profile_line='export PATH="$HOME/.supabase/bin:$PATH"'
if ! grep -Fqx "$profile_line" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# Supabase CLI\n%s\n' "$profile_line" >>"$HOME/.bashrc"
fi
export PATH="$HOME/.supabase/bin:$PATH"

supabase --version
docker compose version

printf '\nInstallation terminée.\n'
printf 'Fermez puis rouvrez WSL pour activer le groupe docker, ou exécutez: newgrp docker\n'
printf 'Ensuite: bash scripts/wsl/verify-supabase-migration.sh\n'

