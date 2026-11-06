# Backend Supabase — ThanksGiving Quote

Ce dossier contient le socle serveur de M1-03, le modèle de données M1-06 et
l'API sécurisée M1-07.

## Séparation des responsabilités

- Flutter reçoit seulement `CONTENT_API_BASE_URL`, une URL publique.
- `API_BIBLE_API_KEY` existe uniquement dans les secrets des Edge Functions.
- la table `public.daily_verse_contents` a RLS activé et ne donne aucun droit aux rôles `anon` et `authenticated` ; le mobile n'y accède jamais directement ;
- l'API publique de lecture M1-07 ne renvoie que les révisions `published`
  dont la date de publication est atteinte et dont le couple langue/traduction
  figure dans `CONTENT_ALLOWED_TRANSLATIONS` ;
- le connecteur API.Bible est réservé aux identités éditoriales ou aux appels
  serveur-à-serveur ; il ne choisit jamais un verset et ne publie rien.

## API M1-07

- `GET /functions/v1/daily-verses` : lecture publique d'une date ou d'une plage
  historique de 30 jours maximum ;
- `POST /functions/v1/api-bible-passage` : récupération privée d'un passage
  explicitement choisi, limitée aux Bible IDs configurés côté serveur.

Le contrat détaillé, les paramètres et les codes d'erreur sont documentés dans
[`API_M1_07.md`](API_M1_07.md).

## Secrets locaux

Utiliser le script interactif suivant depuis WSL. La saisie de la clé est
masquée et le fichier produit est ignoré par Git :

```bash
bash scripts/wsl/configure-supabase-function-secrets.sh
```

Le script demande une nouvelle clé API.Bible, consulte les éditions
accessibles à ce compte et vérifie l'édition française Bible J.N. Darby
`a93a92589195411f-01`. Si elle est absente, il affiche les éditions françaises
accessibles et n'enregistre aucun secret. L'accès à une édition ne valide pas
automatiquement ses droits de cache ou de partage. Ne jamais ajouter la clé dans un fichier suivi par
Git, une commande de compilation Flutter ou un journal.

## Environnements hébergés

Créer trois projets Supabase indépendants : développement, test et production. Définir `APP_ENV`, `API_BIBLE_ENDPOINT` et `API_BIBLE_API_KEY` dans les secrets de chaque projet. Les clés ne doivent pas être partagées entre environnements.

La migration a été créée par la CLI avec `supabase migration new create_daily_verse_contents`. Aucun projet distant n'est encore lié et aucune migration distante n'a été appliquée.

## Exécution locale retenue

Le moteur de conteneurs retenu pour ce projet est **Docker Engine dans WSL 2**. Les commandes Supabase locales devront être exécutées depuis la distribution WSL, avec une version récente de la CLI compatible avec la section `local_smtp` de `config.toml`.

La recette locale M1-07 s'exécute avec :

```bash
bash scripts/wsl/verify-m1-07.sh
```

Elle injecte des données techniques temporaires, prouve que seuls les trois
contenus publiés sont renvoyés, refuse une date future et vérifie que le
connecteur API.Bible répond `401` sans identité. Les fixtures sont supprimées
automatiquement.

La procédure et les scripts prêts à exécuter sont décrits dans [`DOCKER_WSL_SETUP.md`](../DOCKER_WSL_SETUP.md).
