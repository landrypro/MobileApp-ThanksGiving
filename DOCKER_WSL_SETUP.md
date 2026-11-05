# Préparation Docker sous WSL 2 — ThanksGiving Quote

Ce guide prépare l'environnement local nécessaire pour appliquer la migration M1-06 puis développer M1-07. Le choix retenu est **Ubuntu sous WSL 2 + Docker Engine dans Linux**, sans Docker Desktop.

## 1. Ressources et règles

- Windows 10 version 2004 ou ultérieure, ou Windows 11 ;
- virtualisation matérielle activée dans le BIOS/UEFI ;
- au moins 7 Go de mémoire disponibles pour la pile Supabase complète ;
- aucun secret API.Bible dans Docker, Flutter ou les scripts suivis par Git ;
- les services locaux Supabase sont liés à `127.0.0.1` et ne doivent pas être exposés à Internet.

## 2. Diagnostic Windows

Ouvrir PowerShell en administrateur, se placer à la racine du projet, puis exécuter :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\windows\Test-WslDockerPrerequisites.ps1
```

Le diagnostic actuel indique une version WSL trop ancienne et l'absence de distribution Linux. Pour préparer WSL 2 sans redémarrage automatique :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\windows\Enable-Wsl2ForTgq.ps1
```

Si le script demande un redémarrage, redémarrer Windows manuellement puis relancer le même script. Au premier lancement d'Ubuntu, créer le nom d'utilisateur et le mot de passe Linux demandés.

Contrôler ensuite :

```powershell
wsl.exe --version
wsl.exe --list --verbose
```

La distribution Ubuntu doit être en version `2`.

## 3. Vérifier systemd dans Ubuntu

Ouvrir Ubuntu et exécuter :

```bash
ps -p 1 -o comm=
```

Le résultat attendu est `systemd`. Sur une distribution plus ancienne, ajouter avec précaution les lignes suivantes à `/etc/wsl.conf` sans écraser ses autres réglages :

```ini
[boot]
systemd=true
```

Puis, depuis PowerShell :

```powershell
wsl.exe --shutdown
```

Rouvrir Ubuntu et contrôler de nouveau le processus numéro 1.

## 4. Installer Docker Engine et Supabase CLI

Depuis Ubuntu, accéder au projet Windows :

```bash
cd "/mnt/c/Users/Admin/OneDrive/Family Room/Documents/ChatGPT/MobileApp ThanksGiving"
bash scripts/wsl/install-docker-supabase.sh
```

Le script :

1. refuse de supprimer automatiquement d'éventuels paquets Docker conflictuels ;
2. désactive de manière récupérable un ancien `docker.list` qui dupliquerait le dépôt officiel ;
3. installe Docker depuis le dépôt APT officiel ;
4. active le service Docker avec systemd ;
5. ajoute l'utilisateur Linux au groupe `docker` ;
6. exécute l'image officielle `hello-world` ;
7. installe Supabase CLI `3.0.0`, version épinglée, avec l'installateur officiel et son contrôle de somme.

L'appartenance au groupe `docker` donne des privilèges équivalents à root. Fermer puis rouvrir Ubuntu après l'installation, ou utiliser temporairement :

```bash
newgrp docker
```

## 5. Appliquer et vérifier la migration M1-06

Depuis la racine du projet dans Ubuntu :

```bash
bash scripts/wsl/verify-supabase-migration.sh
```

Ce contrôle :

- crée un réseau Docker local lié à `127.0.0.1` ;
- démarre Supabase ;
- réinitialise la base locale et applique toutes les migrations ;
- vérifie la table `daily_verse_contents`, ses contraintes et l'unicité des versions ;
- vérifie que RLS est activé et forcé ;
- confirme que `anon` et `authenticated` n'ont aucun accès direct ;
- exécute les conseillers Supabase et affiche l'état final.

Pour arrêter l'environnement sans supprimer les données locales :

```bash
supabase --workdir "/mnt/c/Users/Admin/OneDrive/Family Room/Documents/ChatGPT/MobileApp ThanksGiving" stop
```

## 6. Emplacement du projet

Pour cette première migration, utiliser le dossier actuel sous `/mnt/c` évite de créer deux copies divergentes. Après la mise en place d'un dépôt Git distant, un clone dans le système de fichiers Linux (`~/src/...`) sera préférable pour les performances Docker et les outils Linux.

## 7. Condition de passage vers M1-07

M1-07 pourra être raccordé à la base réelle lorsque `verify-supabase-migration.sh` se termine avec :

```text
Migration M1-06 appliquée et vérifiée avec succès.
```

