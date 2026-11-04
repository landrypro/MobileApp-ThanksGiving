# ThanksGiving Quote — application mobile

Socle Flutter du pilote français de **ThanksGiving Quote**.

Le pilote propose trois rendez-vous de gratitude chaque jour : matin, midi et soir. Les textes bibliques définitifs ne sont pas embarqués dans ce socle : ils seront servis par l'API d'administration après validation éditoriale et de droits.

## État d'implémentation

- écran d'aujourd'hui avec les trois créneaux ;
- favoris locaux pendant la session ;
- historique de démonstration ;
- réglages de langue et de rappels ;
- thème fidèle aux couleurs Gaius Consulting ;
- jeu de données de démonstration, isolé derrière `DailyVerseRepository`.

## Démarrer sur un poste équipé de Flutter

1. Suivre [la préparation Windows](../INSTALLATION_FLUTTER_WINDOWS.md) pour installer le SDK Flutter stable et l'ajouter au `PATH`.
2. L'hôte Android est déjà généré. Depuis ce dossier, lancer les contrôles : `flutter analyze` puis `flutter test`.
3. Compiler : `flutter build apk --debug`.
4. Démarrer l'émulateur `TGQ_Pixel_3a_API_34` puis lancer : `flutter run -d emulator-5554`.

Sur le poste de développement actuel, Flutter est dans `D:\LOGICIEL\flutter_windows_3.47.9-stable\flutter` et l'émulateur est dans `D:\LOGICIEL\Android\avd`. En cas de terminal qui ne reconnaît pas encore `flutter`, rouvrir le terminal ou appeler `flutter.bat` par son chemin absolu. Pour les compilations sur ce poste, définir `GRADLE_USER_HOME` à `D:\LOGICIEL\Android\gradle-cache` afin de conserver le cache Gradle sur D:.

## Règle de sécurité API.Bible

La clé API.Bible ne doit jamais être ajoutée à cette application, dans `pubspec.yaml`, dans le dépôt ou dans un fichier de configuration mobile. L'application mobile appellera uniquement l'API sécurisée de ThanksGiving Quote ; cette API serveur conservera le secret et interrogera API.Bible.

## Prochaine tranche

1. Générer les projets Android et iOS avec le SDK Flutter.
2. Ajouter le stockage local chiffré et les notifications locales.
3. Connecter l'API de contenu sécurisée, avec cache hors-ligne et attribution par verset.
