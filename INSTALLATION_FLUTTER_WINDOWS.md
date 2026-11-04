# Préparation Flutter — poste Windows

Date de préparation : 3 novembre 2026 ; état vérifié le 4 novembre 2026  
Projet : **ThanksGiving Quote**

## État constaté

> Mise à jour du 4 novembre : Flutter 3.47.9, Android Studio, Platform 36, Build-Tools 28.0.3 et 36.0.0, ainsi que le NDK 28.2.13676358 sont installés. Les licences Android sont acceptées. L'APK de débogage a été compilé et lancé sur `TGQ_Pixel_3a_API_34`.

| Élément | État | Décision |
|---|---|---|
| Git pour Windows | Installé | Aucun changement requis. |
| Visual Studio Code | Installé | Utilisé comme éditeur. |
| Flutter SDK / Dart SDK | Installés sur D: | Flutter 3.47.9 / Dart 3.13.7. |
| Android Studio / Android SDK / `adb` | Installés | Chaîne Android validée par `flutter doctor`. |
| Java référencé par le poste | Java 8 | Ne pas l'utiliser pour la chaîne Android ; Android Studio apporte son JDK compatible. |

## Installation recommandée

La source de référence est la documentation Flutter pour Windows. Elle recommande le canal **stable**, Git, un chemin sans espaces ne nécessitant pas de droits administrateur, puis la validation avec `flutter doctor`.

- [Installer Flutter sous Windows](https://docs.flutter.dev/install/manual)
- [Configurer Android pour Flutter](https://docs.flutter.dev/platform-integration/android/setup)

### 1. Installer le SDK Flutter

1. Télécharger l'archive Windows du canal stable depuis la documentation officielle.
2. Extraire le SDK dans `C:\Users\Admin\develop\flutter`.
3. Ajouter `C:\Users\Admin\develop\flutter\bin` au `Path` **utilisateur**.
4. Fermer et rouvrir le terminal et VS Code.
5. Vérifier :

```powershell
flutter --version
dart --version
flutter doctor
```

Sur le poste actuel, le SDK a été installé par l'utilisateur dans `D:\LOGICIEL\flutter_windows_3.47.9-stable\flutter`, hors du projet et hors de OneDrive.

### 2. Installer Android Studio

1. Installer Android Studio stable.
2. Dans l’assistant, conserver l’installation de l’Android SDK, des Platform Tools et de l’émulateur Android.
3. Créer un émulateur de type téléphone dans **Tools > Device Manager**.
4. Depuis le terminal, accepter les licences :

```powershell
flutter doctor --android-licenses
flutter doctor -v
```

Le JDK intégré à Android Studio doit être la référence de la chaîne Android. Il n’est pas nécessaire de modifier globalement la version Java existante du poste.

### 3. Préparer le projet ThanksGiving Quote

Depuis le dossier `mobile` du projet :

```powershell
flutter create --platforms=android .
flutter pub get
flutter analyze
flutter test
flutter run
```

L'hôte Android est déjà généré. La génération, la signature et le test final iOS exigent ultérieurement un Mac avec Xcode ; le code Flutter restera commun.

## Vérification automatisée

Le script `scripts/Test-FlutterPrerequisites.ps1` effectue une vérification sans modification du poste. Exécuter avant et après l’installation :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-FlutterPrerequisites.ps1
```

## Sécurité

- Aucun secret API.Bible ne doit être saisi dans Flutter, Android Studio, les fichiers `.env` ou Git.
- La clé reste exclusivement dans les secrets Supabase (ou un coffre de secrets équivalent) et est utilisée par une API serveur.
- Le dossier Flutter SDK ne doit pas être placé dans OneDrive ni dans le dossier du dépôt.
