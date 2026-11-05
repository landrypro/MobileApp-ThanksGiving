# Backend Supabase — ThanksGiving Quote

Ce dossier contient le socle serveur de M1-03 et le modèle de données M1-06.

## Séparation des responsabilités

- Flutter reçoit seulement `CONTENT_API_BASE_URL`, une URL publique.
- `API_BIBLE_API_KEY` existe uniquement dans les secrets des Edge Functions.
- la table `public.daily_verse_contents` a RLS activé et ne donne aucun droit aux rôles `anon` et `authenticated` ; le mobile n'y accède jamais directement ;
- l'API publique de lecture sera ajoutée dans M1-07 et ne renverra que les révisions autorisées.

## Secrets locaux

Copier `functions/.env.example` vers un fichier local ignoré, puis renseigner la nouvelle clé API.Bible hors du dépôt. Ne jamais ajouter la valeur réelle dans un fichier suivi par Git, une commande de compilation Flutter ou un journal.

## Environnements hébergés

Créer trois projets Supabase indépendants : développement, test et production. Définir `APP_ENV`, `API_BIBLE_ENDPOINT` et `API_BIBLE_API_KEY` dans les secrets de chaque projet. Les clés ne doivent pas être partagées entre environnements.

La migration a été créée par la CLI avec `supabase migration new create_daily_verse_contents`. Aucun projet distant n'est encore lié et aucune migration distante n'a été appliquée.

## Exécution locale retenue

Le moteur de conteneurs retenu pour ce projet est **Docker Engine dans WSL 2**. Les commandes Supabase locales devront être exécutées depuis la distribution WSL, avec une version récente de la CLI compatible avec la section `local_smtp` de `config.toml`.

Quand WSL et Docker seront actifs, le contrôle restant sera : démarrer Supabase, réinitialiser la base avec les migrations, puis vérifier les contraintes et RLS de `daily_verse_contents`.

La procédure et les scripts prêts à exécuter sont décrits dans [`DOCKER_WSL_SETUP.md`](../DOCKER_WSL_SETUP.md).
