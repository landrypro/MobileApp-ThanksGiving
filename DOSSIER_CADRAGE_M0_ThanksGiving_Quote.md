# Dossier de cadrage M0 — ThanksGiving Quote

**Version :** 1.0  
**Date :** 3 novembre 2026  
**Propriétaire :** Gaius Consulting  
**Références :** [Spécification technique](SPECIFICATION_TECHNIQUE_ThanksGiving_Quote.md) · [Règles fonctionnelles](REGLES_FONCTIONNELLES_COMPLETES_ThanksGiving_Quote.md) · [Backlog priorisé](BACKLOG_DEVELOPPEMENT_PRIORISE_ThanksGiving_Quote.md)

## 1. Décisions validées

| Sujet | Décision | Conséquence opérationnelle |
| --- | --- | --- |
| Pilote | Bêta fermée en français uniquement. | Les sept autres langues et leurs traductions restent désactivées. |
| Traduction | Louis Segond 1910 (LSG 1910). | Une seule édition française est proposée pendant la bêta. |
| Source biblique | API.Bible côté serveur pour le pilote ; eBible LSG 1910 comme repli documenté. | Les accords API.Bible applicables au pilote non commercial sont acceptés par Gaius Consulting ; aucune clé fournisseur n’est embarquée dans le téléphone. |
| Sélection des versets | Éditoriale et humaine, jamais aléatoire. | La Bible en ligne fournit le texte exact d’une référence choisie et validée. |
| Propriétaire | Gaius Consulting. | Gaius Consulting est l’éditeur, l’exploitant et le responsable des accès. |
| Bêta | 1 semaine interne, puis 4 semaines avec 30 à 50 testeurs francophones. | Les KPI pilotent la décision de lancement public. |
| Application | Flutter / Dart, architecture MVVM, SQLite via Drift. | Un code iOS/Android et un fonctionnement offline-first. |
| Service | Supabase : PostgreSQL, Auth, Edge Functions, Cron. | Données éditoriales, API, rôles, journal et tâches planifiées centralisés. |
| Administration | Console Next.js sécurisée. | Gaius Consulting rédige, relit, approuve, publie et retire les contenus. |

## 2. Ce que signifie « connecté à une Bible en ligne »

La connexion est faite par le serveur de ThanksGiving Quote, jamais directement par l’application mobile.

```text
Éditeur Gaius Consulting
        │ choisit une référence biblique
        ▼
Console d’administration ──► Connecteur biblique serveur
                                      │
                                      ├── API.Bible : édition LSG 1910 autorisée
                                      └── eBible : repli LSG 1910 déclaré public
                                      ▼
                         Aperçu + source + métadonnées de droits
                                      ▼
                         Relecture biblique et approbation
                                      ▼
                      API ThanksGiving Quote → application Flutter
```

Le connecteur enregistre systématiquement : l’édition, l’identifiant du fournisseur, la référence, le texte obtenu, l’URL source, la date de récupération, l’empreinte du texte et l’attribution. Un changement inattendu du texte source doit créer une alerte et exiger une nouvelle validation.

## 3. Gouvernance Gaius Consulting

Gaius Consulting doit renseigner une personne titulaire et une personne de secours pour chaque rôle avant le début de la bêta.

| Rôle | Titulaire à nommer | Responsabilité |
| --- | --- | --- |
| Product Owner | À compléter | Arbitrage du périmètre, budget, KPI et passage des jalons. |
| Responsable éditorial | À compléter | Calendrier, textes de méditation, prière, action et réserve. |
| Relecteur biblique | À compléter | Contexte, fidélité du passage et cohérence théologique. |
| Responsable technique | À compléter | Application, Supabase, sécurité, sauvegardes et incidents. |
| Approbateur suppléant | À compléter | Validation lorsque l’auteur ou le titulaire est indisponible. |

Un auteur ne peut jamais approuver seul le contenu qu’il a préparé.

## 4. Corpus du pilote

| Lot | Période | Créneaux | Volume |
| --- | --- | --- | --- |
| Publication initiale | Jours 1 à 30 | Matin, Midi, Soir | 90 contenus |
| Réserve | Jours 31 à 60 | Matin, Midi, Soir | 90 contenus |
| **Total avant bêta** | 60 jours | 3 créneaux par jour | **180 contenus** |

Chaque contenu français contient :

1. La date et le créneau (`morning`, `midday`, `evening`).
2. La référence biblique choisie par l’équipe éditoriale.
3. Le texte LSG 1910 importé de la source approuvée.
4. Une méditation originale de 80 à 140 mots.
5. Une prière facultative de 40 à 80 mots.
6. Une action de gratitude réalisable dans la journée.
7. Le rédacteur, le relecteur biblique, l’approbateur, le statut et le numéro de révision.

## 5. Plan de bêta

| Phase | Durée | Participants | But |
| --- | --- | --- | --- |
| Test interne | 7 jours | 5 à 8 personnes Gaius Consulting | Corriger les défauts bloquants, les références et les rappels. |
| Bêta fermée | 28 jours | 30 à 50 testeurs francophones invités | Valider usage, rythme de trois rendez-vous et fiabilité. |
| Revue de passage | 1 séance | Produit, éditorial, technique | Décider de corriger, prolonger ou ouvrir le lancement français. |

| KPI | Seuil de passage |
| --- | --- |
| Première lecture | Au moins 70 % des testeurs ouvrent un créneau. |
| Rythme | Au moins 40 % lisent 2 créneaux ou plus sur 4 jours d’une semaine. |
| Retour à 7 jours | Au moins 35 % des testeurs reviennent la semaine suivante. |
| Rappels | Au moins 40 % activent au moins un rappel. |
| Satisfaction | Moyenne d’au moins 4/5. |
| Fiabilité | Aucun incident bloquant ; au moins 99 % de synchronisations et rappels programmés réussis. |

Les métriques sont agrégées et ne contiennent ni prière, ni note personnelle, ni texte de favori, ni identifiant superflu.

## 6. Architecture cible

```text
Flutter iOS / Android
  ├── Views + ViewModels
  ├── Repositories : contenu, favoris, préférences, rappels
  └── SQLite / Drift : cache 30 jours, favoris, préférences
                    │ HTTPS
                    ▼
Supabase
  ├── PostgreSQL : contenus, traductions, révisions, droits, journal
  ├── Auth : administrateurs Gaius Consulting uniquement
  ├── RLS : lecture publique limitée aux contenus publiés
  ├── Edge Functions : API publique, import biblique, contrôles
  └── Cron : vérification des créneaux, réserve et alertes
                    │
                    ▼
Fournisseur biblique en ligne du pilote : API.Bible
Source de repli documentée : eBible LSG 1910

Console Next.js d’administration Gaius Consulting
  └── Authentification administrateur, jamais accessible aux lecteurs publics
```

### Règles de sécurité non négociables

- La clé API.Bible, les secrets Supabase et le rôle `service_role` restent exclusivement côté serveur.
- Toutes les tables exposées activent Row Level Security ; les lecteurs anonymes ne peuvent consulter que les contenus `published` et autorisés.
- Les écritures éditoriales nécessitent une session administrateur et un rôle applicatif autorisé.
- Les contenus futurs, brouillons, journaux d’audit et informations de droits ne sont jamais exposés à l’application publique.
- Les sauvegardes sont quotidiennes, les accès administrateurs sont individuels et les incidents sont journalisés.

## 7. Modèle minimal à créer dans Supabase

| Table | Rôle |
| --- | --- |
| `bible_sources` | Édition, fournisseur, URL, licence, date de vérification. |
| `bible_translations` | LSG 1910 et ses capacités : affichage, cache, partage, attribution. |
| `daily_contents` | Date, créneau, référence, statut de publication. |
| `verse_variants` | Texte exact LSG, identifiant fournisseur, empreinte, révision. |
| `content_localizations` | Méditation, prière, action et référence affichable en français. |
| `content_reviews` | Auteur, relecteur, approbateur, décision, commentaire et date. |
| `content_revisions` | Instantané immuable lors de chaque publication ou correction. |
| `admin_roles` | Rôle et statut des administrateurs Gaius Consulting. |
| `operational_events` | Événements techniques agrégés : synchronisation, import, alerte. |

## 8. Prochaines actions exécutables

| Ordre | Action | Responsable | Prérequis |
| --- | --- | --- | --- |
| 1 | Nommer les cinq titulaires ou suppléants Gaius Consulting. | Product Owner | Aucun. |
| 2 | Vérifier dans le compte API.Bible l’édition LSG 1910 autorisée, puis enregistrer ses métadonnées et l’attribution. Conserver eBible LSG 1910 comme repli de provenance. | Responsable technique / éditorial | Accès au compte API.Bible Gaius Consulting. |
| 3 | Ouvrir le projet Supabase de développement au nom de Gaius Consulting. | Responsable technique | Compte Gaius Consulting. |
| 4 | Créer le dépôt de code, le projet Flutter et la console Next.js. | Responsable technique | Projet Supabase de développement. |
| 5 | Créer le registre de droits LSG 1910 et importer un verset API.Bible de test dans un environnement non public. | Technique + éditorial | Étapes 2 et 3. |
| 6 | Préparer et faire approuver les 180 contenus du pilote. | Éditorial + relecteur biblique | Registre de droits LSG 1910. |
| 7 | Construire puis tester le parcours Matin / Midi / Soir et les rappels. | Équipe produit / technique | Étapes 3 à 5. |

## 9. Conditions avant de commencer le code connecté

Le code Flutter local peut être initialisé sans compte externe. En revanche, la création du projet Supabase, les environnements de publication et l’intégration API.Bible nécessitent des comptes détenus ou explicitement autorisés par Gaius Consulting. Les accords API.Bible sont confirmés comme acceptés ; les clés restent néanmoins confidentielles et ne sont jamais placées dans l’application mobile.
