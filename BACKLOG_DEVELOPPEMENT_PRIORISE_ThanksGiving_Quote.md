# Backlog de développement priorisé — ThanksGiving Quote

**Version :** 2.3 — API.Bible activée pour le pilote non commercial  
**Date :** 3 novembre 2026  
**Références :** [Spécification technique](SPECIFICATION_TECHNIQUE_ThanksGiving_Quote.md) · [Règles fonctionnelles](REGLES_FONCTIONNELLES_COMPLETES_ThanksGiving_Quote.md)

## 1. Cap produit et périmètre

ThanksGiving Quote aide une personne chrétienne francophone, utilisant son téléphone au quotidien, à marquer trois pauses simples pour **rendre grâce à DIEU** : le matin, à midi et le soir.

Le produit est construit en deux temps :

1. **Pilote français fermé :** valider le rythme de trois rendez-vous, la qualité éditoriale, la compréhension des rappels et la fiabilité technique.
2. **Lancement public multilingue :** déployer les 8 langues prévues seulement lorsque la chaîne éditoriale, les droits bibliques et les indicateurs du pilote sont validés.

| Créneau | Ouverture locale | Rappel initial proposé |
| --- | --- | --- |
| Matin | 05 h 00 | 08 h 00 |
| Midi | 12 h 00 | 12 h 00 |
| Soir | 18 h 00 | 20 h 00 |

## 2. Indicateurs de succès du pilote

Les mesures sont agrégées, minimisées et soumises au consentement lorsqu’il est requis. Elles ne doivent ni suivre le texte des prières ni identifier une personne sans nécessité.

| Indicateur | Cible provisoire à la fin de la bêta | Décision éclairée |
| --- | --- | --- |
| Activation | Au moins 70 % des testeurs lisent un premier créneau. | Vérifier la compréhension de l’accueil. |
| Rythme | Au moins 40 % lisent 2 créneaux ou plus sur 4 jours d’une même semaine. | Confirmer la pertinence de trois rendez-vous. |
| Rétention à 7 jours | Au moins 35 % des testeurs reviennent la semaine suivante. | Mesurer l’intérêt durable. |
| Rappels | Au moins 40 % activent au moins un rappel. | Valider la valeur des notifications. |
| Fiabilité | Aucun incident bloquant ; au moins 99 % des synchronisations et programmations de rappel réussissent pendant la bêta. | Autoriser le passage au lancement public. |
| Qualité éditoriale | 100 % des contenus publiés possèdent approbation et droit d’usage traçables. | Protéger le produit et la confiance des utilisateurs. |

> Ces seuils sont des objectifs de pilotage, non des données personnelles. Ils sont à réviser après le recrutement de la bêta.

## 2.1 Décisions M0 validées le 3 novembre 2026

| Décision | Choix validé | État d’exécution |
| --- | --- | --- |
| Traduction du pilote | Louis Segond 1910 (LSG 1910), seule édition française affichée pendant la bêta. | Vérifier l’édition exacte et enregistrer sa fiche de droits avant import. |
| Source biblique en ligne | API.Bible côté serveur pour le pilote LSG 1910 ; eBible est le repli documenté. | Vérifier le Bible ID et les métadonnées dans le compte Gaius ; archiver une copie lisible des Terms of Service. |
| Gouvernance | Gaius Consulting est propriétaire produit, éditorial et technique. | Désigner les personnes titulaires des rôles. |
| Contenu pilote | 30 jours publiés + 30 jours de réserve : 180 contenus au total. | Calendrier éditorial et corpus à préparer. |
| Bêta | 1 semaine interne (5 à 8 personnes), puis 4 semaines avec 30 à 50 testeurs francophones. | Recrutement à planifier. |
| Architecture | Flutter / SQLite-Drift ; Supabase PostgreSQL, Auth, Edge Functions et Cron ; console Next.js d’administration. | Environnements et dépôts à créer. |

## 3. Jalons, décisions de passage et priorité

| Jalon | Objectif | Décision de passage |
| --- | --- | --- |
| **M0 — Cadrage verrouillé** | Établir les droits, le processus éditorial, les KPI et le périmètre pilote. | Aucun texte biblique sous licence ne peut être intégré sans validation. |
| **M1 — Pilote français utilisable** | Livrer le parcours complet des trois créneaux en français à un groupe interne. | Le parcours critique est fiable sur iOS et Android. |
| **M2 — Bêta fermée** | Tester contenus, rappels, mode hors connexion et support avec des utilisateurs invités. | KPI et recettes critiques atteignent les seuils définis. |
| **M3 — Lancement public** | Ouvrir la version française, puis les 7 langues restantes par vagues validées. | Chaque langue possède contenus, relecture et droits validés. |

| Priorité | Signification |
| --- | --- |
| **P0** | Indispensable au jalon concerné ; un élément rouge bloque le passage. |
| **P1** | Améliore l’expérience après validation du noyau ; ne bloque pas le pilote. |
| **P2** | Évolution post-lancement. |

## 4. Backlog P0 — M0 : cadrage et opération éditoriale

| ID | Travail | Livrable / critère d’acceptation | Responsable indicatif |
| --- | --- | --- | --- |
| M0-01 | Nommer le propriétaire produit, le responsable éditorial, les relecteurs bibliques et le responsable technique. | Rôles, accès, suppléants et délai de correction urgente documentés. | Porteur du projet |
| M0-02 | Établir une matrice des droits par traduction et territoire. | Pour chaque traduction : affichage, cache, partage, attribution, limite d’extrait, territoire, échéance et preuve de droit. Documenter séparément les contraintes API.Bible si cette source est retenue. | Éditorial / juridique |
| M0-03 | Choisir la traduction française du pilote parmi les options effectivement autorisées. | LSG 1910 accessible via API.Bible est la seule traduction activée. Les autres restent masquées tant que leurs droits ne sont pas validés. | Éditorial |
| M0-04 | Définir la chaîne éditoriale. | États : brouillon → relecture biblique → relecture linguistique → approuvé → planifié → publié → retiré ; identité et date de chaque approbation conservées. | Responsable éditorial |
| M0-05 | Préparer le catalogue du pilote. | Au minimum 30 jours × 3 créneaux = 90 contenus français approuvés, plus une réserve de 30 jours. Chaque contenu contient référence, méditation, prière facultative et action. | Équipe éditoriale |
| M0-06 | Définir les KPI, le consentement analytique et le tableau de suivi de bêta. | Les métriques de la section 2 sont calculables sans stocker de prière, texte saisi ou identifiant superflu. | Produit / technique |
| M0-07 | Définir la politique de cache et de rétention. | Durée, taille maximale, expiration, suppression après désinstallation et comportement d’une traduction non téléchargée sont documentés. | Produit / technique |
| M0-08 | Choisir l’hébergement, les sauvegardes, l’URL d’API et la supervision. | Environnements développement, test et production ; accès administrateur protégé ; sauvegarde et restauration testées. Aucun mécanisme de monétisation ne peut être introduit pendant le pilote sans revue des licences bibliques. | Technique |

## 5. Backlog P0 — M1 : pilote français utilisable

### EP-01 — Socle mobile, sécurité et accessibilité

| ID | Histoire / travail | Critère d’acceptation | Dépendances |
| --- | --- | --- | --- |
| M1-01 | Créer le projet mobile iOS et Android avec environnements séparés. | L’application est installable sur appareils de référence iOS et Android. | M0-08 |
| M1-02 | Mettre en place le design system issu du prototype : couleurs Gaius, composants, typographies et états. | Les écrans Matin, Midi et Soir sont cohérents, contrastés et lisibles avec police agrandie. | — |
| M1-03 | Centraliser la configuration et les secrets. | Aucun secret de production ou droit d’administration n’est embarqué dans l’application. | M1-01 |
| M1-04 | Mettre en place compilation continue, analyse statique et tests automatisés. | Toute modification validée produit une version testable et un rapport de qualité vert. | M1-01 |
| M1-05 | Assurer lecteur d’écran, navigation clavier, ordre de focus et préparation RTL. | Le parcours principal ne dépend pas uniquement de la couleur ou des icônes. | M1-02 |

### EP-02 — API et administration éditoriale minimale

| ID | Histoire / travail | Critère d’acceptation | Dépendances |
| --- | --- | --- | --- |
| M1-06 | Modéliser le contenu par `date + créneau + langue + traduction + version`. | Les trois créneaux `morning`, `midday`, `evening` sont identifiables et versionnés. | M0-04 |
| M1-07 | Créer l’API de lecture du jour et de l’historique. | Elle renvoie uniquement les contenus approuvés, adaptés à la langue et à la traduction autorisée. | M1-06, M0-02 |
| M1-08 | Fournir une administration réduite : créer, relire, approuver, planifier, publier, retirer. | Les brouillons ne sont jamais accessibles publiquement ; les rôles sont contrôlés. | M1-06, M0-01 |
| M1-09 | Gérer une correction urgente et l’invalidation de cache. | Une révision est horodatée, traçable et remplace le contenu lors de la synchronisation suivante. | M1-08 |

### EP-03 — Parcours des trois rendez-vous

| ID | Histoire / travail | Critère d’acceptation | Dépendances |
| --- | --- | --- | --- |
| M1-10 | Afficher la date, le jour de l’année et les sélecteurs Matin / Midi / Soir. | Chaque créneau indique son heure et son état : disponible ou à venir. | M1-07 |
| M1-11 | Ouvrir les créneaux à 05 h, 12 h et 18 h dans le fuseau de l’appareil. | Le contenu futur ne révèle ni texte ni méditation ; un créneau ouvert reste lisible jusqu’à minuit. | M1-10 |
| M1-12 | Afficher verset, référence, attribution, méditation, prière facultative et action. | Le texte correspond exactement à la traduction française autorisée, sans attribution incorrecte. | M0-03, M1-11 |
| M1-13 | Gérer chargement, contenu absent, contenu retiré et erreur réseau. | Aucun ancien contenu n’est présenté comme le contenu du jour ; les messages donnent une action utile. | M1-07 |
| M1-14 | Préserver le bon créneau à l’ouverture depuis une notification ou l’historique. | Un lien vers « Soir » ouvre directement le rendez-vous Soir correspondant. | M1-11 |

### EP-04 — Rappels, cache et préférences

| ID | Histoire / travail | Critère d’acceptation | Dépendances |
| --- | --- | --- | --- |
| M1-15 | Activer, modifier et désactiver séparément les rappels des trois créneaux. | Les heures initiales 08 h, 12 h et 20 h sont modifiables sans créer de doublon. | M1-01 |
| M1-16 | Demander la permission système seulement lors du premier rappel activé. | Le refus de permission ne bloque aucune lecture et explique comment réactiver les notifications. | M1-15 |
| M1-17 | Recalculer les rappels après changement d’heure, de fuseau ou de préférence. | Une seule notification est programmée pour chaque créneau et date. | M1-15 |
| M1-18 | Conserver préférences, contenus autorisés et derniers contenus ouverts sur l’appareil. | Après une synchronisation, les contenus du jour sont lisibles hors connexion selon leurs droits. | M0-07, M1-07 |
| M1-19 | Ne jamais révéler le contenu futur issu du cache. | Un contenu préchargé reste masqué avant sa date et son heure de créneau. | M1-11, M1-18 |

### EP-05 — Historique, favoris, partage et légalité

| ID | Histoire / travail | Critère d’acceptation | Dépendances |
| --- | --- | --- | --- |
| M1-20 | Ajouter et retirer un favori local lié à une date et un créneau. | Le favori persiste après redémarrage et suit une correction de contenu. | M1-11, M1-18 |
| M1-21 | Afficher les favoris, du plus récent au plus ancien. | Si une traduction n’est pas en cache, la référence et une explication s’affichent sans texte erroné. | M1-20 |
| M1-22 | Afficher l’historique des dates passées et de leurs trois créneaux. | Les dates futures, brouillons et contenus retirés sont inaccessibles. | M1-07, M1-11 |
| M1-23 | Partager uniquement les contenus autorisés avec attribution obligatoire. | L’action est absente ou explique la restriction si les droits l’interdisent. | M0-02, M1-12 |
| M1-24 | Publier confidentialité, licences, contact et informations sur les données locales. | Les informations sont accessibles dans l’application et conformes aux exigences des boutiques. | M0-02, M0-06 |

## 6. Backlog P0 — M2 : bêta fermée et contrôle de qualité

| ID | Travail | Critère d’acceptation | Dépendances |
| --- | --- | --- | --- |
| M2-01 | Écrire une matrice de recette pour 05 h, 12 h, 18 h, minuit, changement de fuseau, heure d’été, mode avion et contenu retiré. | Chaque scénario est exécuté sur iOS et Android réels ; les résultats sont tracés. | M1-10 à M1-19 |
| M2-02 | Tester les rappels : permission refusée, permission accordée, batterie optimisée, appareil redémarré et appui sur notification. | Aucun échec silencieux ou doublon connu n’est accepté avant bêta. | M1-15 à M1-17 |
| M2-03 | Tester le cache : première ouverture sans réseau, contenus expirés, cache plein, désinstallation et correction urgente. | Le comportement suit la politique M0-07 et ne perd pas de données de manière trompeuse. | M1-18, M1-19 |
| M2-04 | Mettre en place les alertes d’exploitation. | Alerte sur contenu manquant, échec de publication, échec de synchronisation, correction urgente et réserve éditoriale sous 45 jours. | M0-08, M1-07 |
| M2-05 | Réaliser la revue éditoriale et juridique des 90 contenus du pilote et de leur attribution. | 100 % des contenus bêta sont approuvés et traçables. | M0-02 à M0-05 |
| M2-06 | Lancer la bêta fermée, collecter les KPI et les retours sans données spirituelles sensibles. | Les indicateurs de la section 2 et les incidents sont examinés lors d’une revue de passage M3. | M0-06, M2-01 à M2-05 |

## 7. Backlog P0 — M3 : lancement public progressif

| ID | Travail | Critère d’acceptation | Dépendances |
| --- | --- | --- | --- |
| M3-01 | Préparer les fiches App Store et Google Play, les captures, la confidentialité et le support. | Les exigences de métadonnées et de politique sont vérifiées avant soumission. | M1-24, M2-06 |
| M3-02 | Publier la version française après revue de passage. | Les critères KPI, qualité, droits et support sont satisfaits ou une réserve est formellement acceptée. | M2-06 |
| M3-03 | Préparer les 7 langues supplémentaires : EN, ES, PT-BR, DE, IT, AR, SW. | Chaque locale possède sa relecture native, sa traduction autorisée, ses contenus et sa validation RTL pour l’arabe. | M0-02, M0-04 |
| M3-04 | Déployer les langues par vagues, avec surveillance éditoriale et technique renforcée. | Aucune langue n’est activée sans contenu, droits et tests validés ; un retrait ciblé est possible. | M3-03, M2-04 |
| M3-05 | Passer de 30 à 90 jours de contenu publié et maintenir 30 jours de réserve pour chaque langue active. | La réserve éditoriale est suivie automatiquement et aucune rupture prévisible ne survient. | M2-04, M3-04 |

## 8. Backlog P1 — après validation du noyau

| ID | Évolution | Valeur / condition |
| --- | --- | --- |
| P1-01 | Calendrier enrichi avec état de lecture par créneau. | Visualiser le parcours sans créer de pression. |
| P1-02 | Images de partage conformes aux droits. | Seulement pour les traductions qui l’autorisent. |
| P1-03 | Recherche locale par référence et favoris. | Retrouver simplement une parole sauvegardée. |
| P1-04 | Réglage de contraste renforcé et taille de texte interne. | Renforcer l’accessibilité. |
| P1-05 | Statistiques locales privées de régularité. | Sans classement, profilage ou collecte de texte personnel. |
| P1-06 | Signalement éditorial depuis l’application. | Accélérer le traitement des erreurs de référence ou de traduction. |

## 9. Backlog P2 — après lancement

| ID | Évolution | Condition préalable |
| --- | --- | --- |
| P2-01 | Compte optionnel et synchronisation chiffrée des favoris. | Étude sécurité, confidentialité, coût et support. |
| P2-02 | Widgets iOS et Android. | Licences compatibles avec l’affichage hors application. |
| P2-03 | Plans thématiques de gratitude. | Catalogue éditorial supplémentaire approuvé. |
| P2-04 | Audio, lecture vocale ou musique. | Droits audio et accessibilité validés. |
| P2-05 | Communauté ou groupes de prière. | Modération, sécurité et protection des utilisateurs conçues. |

## 10. Définition de terminé et règles de passage

Une tâche ne peut être déclarée terminée que si :

1. Son critère d’acceptation est démontré sur les plateformes concernées.
2. Ses tests automatisés et sa recette manuelle associée sont au vert.
3. Les états erreur, hors connexion, accessibilité et confidentialité ont été vérifiés lorsqu’ils sont concernés.
4. Les traductions, attributions, cache et partage respectent la matrice des droits M0-02.
5. La revue produit est tracée ; la revue éditoriale est également tracée pour tout contenu affiché.
6. Aucune alerte critique ouverte ne concerne la tâche avant passage de jalon.

Le passage de M0 à M1, de M1 à M2 et de M2 à M3 fait l’objet d’une revue formelle réunissant produit, technique et éditorial. Une réserve ne peut être acceptée que si elle est documentée, datée, attribuée et sans risque sur les droits, la sécurité ou la publication du contenu biblique.
