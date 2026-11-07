# Administration éditoriale — ThanksGiving Quote

Console Next.js de Gaius Care pour les brouillons, les relectures, les
approbations, la planification, la publication et les retraits.

## Démarrage local

1. Démarrer Supabase avec Docker Engine dans WSL et appliquer les migrations.
2. Depuis `admin/`, exécuter `npm ci`.
3. Copier `.env.example` vers `.env.local` et renseigner uniquement l'URL locale
   et la **clé publiable** du projet (`supabase status -o env` affiche la clé
   `ANON_KEY` compatible avec le pilote local). Ne jamais placer une clé de
   service ou la clé API.Bible dans ce dossier.
4. Exécuter `npm run dev` et ouvrir `http://127.0.0.1:3000`.
5. Pour une démonstration locale, exécuter
   `python3 scripts/wsl/create-editorial-demo-users.py` depuis la racine du
   dépôt dans WSL. Les quatre comptes et leurs mots de passe aléatoires sont
   consignés dans `admin/.demo-login.local.txt`, ignoré par Git. Ils couvrent
   rédaction, relecture biblique, relecture linguistique et approbation.
   En dehors du local, les comptes et rôles sont créés par un administrateur
   Auth, hors de cette console.

Les données de démonstration sont facultatives et se chargent avec la commande
indiquée dans [`supabase/README.md`](../supabase/README.md). Elles ne contiennent
aucun verset biblique. Le bouton « Publier » est visible pour une fiche
planifiée, mais le serveur refuse l'opération par défaut. Pour tester
localement l'action sur une fiche `demo`, définir
`APP_ENV=development` et `EDITORIAL_DEMO_PUBLICATION_ENABLED=true` dans
l'environnement de l'Edge Function. La fonction PostgreSQL refuse toujours la
publication JND.

## Contrôles

```bash
npm ci
npm run build
```
