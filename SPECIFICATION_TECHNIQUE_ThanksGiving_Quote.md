# Spécification technique — ThanksGiving Quote

**Version :** 1.7 — API.Bible activée pour le pilote non commercial  
**Date :** 3 novembre 2026  
**Plateformes :** iOS et Android  
**Sous-titre :** Rendre Grâce à DIEU chaque jour  
**Langues retenues pour le lancement public :** français (`fr`), anglais (`en`), espagnol (`es`), portugais du Brésil (`pt-BR`), allemand (`de`), italien (`it`), arabe (`ar`) et swahili (`sw`). Le pilote fermé démarre en français avec une traduction autorisée.

## 1. Vision du produit

**ThanksGiving Quote** présente chaque jour trois versets bibliques centrés sur la reconnaissance envers Dieu : un le matin, un à midi et un le soir. L’application aide l’utilisateur à s’arrêter, méditer la Parole, exprimer sa gratitude et mettre cette attitude en pratique tout au long de la journée.

La promesse principale est simple : **trois rendez-vous quotidiens courts, fiables et accessibles pour rendre grâce à Dieu**. Le contenu doit encourager sans sortir le verset de son contexte biblique.

### Public visé

- Personnes chrétiennes francophones utilisant leur téléphone au quotidien et souhaitant nourrir une pratique régulière de reconnaissance. Le pilote vérifie ensuite l’adéquation auprès des autres langues prévues.
- Personnes découvrant la Bible et recherchant un contenu bref et compréhensible.
- Communautés souhaitant partager un verset et une prière avec leurs proches.

### Objectifs mesurables

- Permettre de lire le rendez-vous du moment en moins de deux interactions après l’ouverture.
- Rendre les trois contenus du jour disponibles hors connexion après leur première synchronisation.
- Permettre d’enregistrer et de retrouver un verset favori sans créer de compte.
- Permettre de choisir, modifier et désactiver les rappels quotidiens.
- Vérifier pendant la bêta qu’au moins 40 % des testeurs activent un rappel et qu’au moins 35 % reviennent après sept jours, sur une mesure agrégée et respectueuse de la vie privée.

## 2. Périmètre de la première version

| Fonction | Comportement attendu |
| --- | --- |
| Trois versets quotidiens | Affiche une référence biblique officielle pour chacun des trois moments de la date civile : matin, midi et soir. Le texte dépend de la traduction choisie parmi celles autorisées pour la langue de l’utilisateur. |
| Choix de traduction | Permet de changer de traduction dans une même langue; seules les éditions dont les droits et le texte ont été validés sont proposées. |
| Méditation | Présente une courte réflexion liée au verset et à la reconnaissance. |
| Prière et action | Propose une prière facultative et une action concrète de gratitude. |
| Historique | Permet de consulter les jours précédents déjà publiés. |
| Favoris | Enregistre et retire des contenus sur l’appareil. |
| Partage | Génère un texte partageable contenant le verset, la référence et le nom de la traduction; la méditation peut être ajoutée si ses droits le permettent. |
| Rappels quotidiens | L’utilisateur active, modifie ou désactive indépendamment les rappels du matin, de midi et du soir. |
| Hors connexion | Affiche le contenu déjà téléchargé et une réserve des prochains jours publiés à l’avance. |
| Réglages | Choix de la langue et de la traduction, heure du rappel, taille du texte via les réglages système, politique de confidentialité et informations sur les sources bibliques. |

### Hors périmètre initial

Compte utilisateur, synchronisation entre appareils, commentaires publics, réseau social, paiement, publicité, audio et personnalisation par intelligence artificielle. Ces fonctions pourront être évaluées après le lancement.

### Règles de localisation

- Le pilote fermé propose le français. Le lancement public vise les huit langues dans l’interface, les méditations, les prières, les actions et les métadonnées de partage. Plusieurs traductions bibliques peuvent être disponibles dans une langue; on ne traduit pas soi-même le texte d’une autre version.
- Une même référence biblique est prévue pour chaque date dans les langues actives d’une vague de déploiement. Les textes exacts peuvent différer selon les traductions.
- Pendant le pilote, le français est proposé. Lors du lancement public, la langue suit celle du téléphone si elle fait partie des langues actives; sinon le français est proposé. Le choix manuel prime sur la langue du téléphone.
- Les dates, les noms des livres et la ponctuation sont adaptés à la langue. L’interface arabe prend en charge l’écriture de droite à gauche, y compris les écrans de partage.
- Aucun contenu méditatif d’une autre langue n’est affiché silencieusement en remplacement. Si une localisation manque, l’application indique la dernière date disponible dans la langue choisie.
- Toute publication est relue par une personne maîtrisant la langue concernée. La traduction automatique peut aider à produire un brouillon, mais ne constitue pas une validation.

## 3. Parcours utilisateur

1. Au premier lancement, l’application affiche brièvement sa mission puis ouvre le contenu du jour. Aucun compte n’est exigé.
2. Elle demande l’autorisation des notifications uniquement lorsque l’utilisateur active un rappel. Un refus n’empêche aucune autre fonction.
3. L’écran d’accueil présente les trois rendez-vous du jour. Il affiche le verset sélectionné, sa référence, sa traduction, la méditation, la prière et l’action associées.
4. L’utilisateur peut ajouter le contenu aux favoris ou utiliser la feuille de partage du téléphone.
5. L’historique donne accès aux dates antérieures; les dates futures ne sont pas visibles.
6. Si le réseau est indisponible, l’application indique que le contenu affiché provient du cache et présente la dernière date disponible.

### Navigation proposée

**Aujourd’hui** · **Historique** · **Favoris** · **Réglages**

## 4. Règles éditoriales

Chaque publication contient obligatoirement : une date de publication, une référence biblique complète, le texte exact du verset dans une traduction identifiée et une méditation originale. La prière et l’action du jour sont facultatives mais recommandées.

### Catalogue de traductions demandé

| Langue | Éditions souhaitées | Condition de mise à disposition |
| --- | --- | --- |
| Français | **Louis Segond 1910 (LSG, pilote)**, puis Bible en français courant (BFC), Bible du Semeur (BDS) et Parole de Vie (PDV) | Le pilote français utilise exclusivement LSG 1910, issue d’une source en ligne validée. BFC, BDS et PDV restent désactivées jusqu’à obtention d’un accord couvrant l’application, le cache et le partage. |
| Anglais | King James Version (KJV), Amplified Bible (AMP, édition exacte à préciser) | Vérifier la diffusion de la KJV au Royaume-Uni. Pour AMP, appliquer les conditions de The Lockman Foundation et obtenir tout accord supplémentaire nécessaire à l’usage prévu. |
| Espagnol, portugais du Brésil, allemand, italien, arabe, swahili | Traductions proposées en section 10 | Une édition initiale par langue; d’autres peuvent être ajoutées avec le même processus de validation. |

Le nom « Louis Second » mentionné dans le cadrage est normalisé ici en **Louis Segond**. Le contenu éditorial du jour, sa méditation et sa prière restent liés à la **référence biblique**; seul le texte du verset et ses mentions de droits changent lorsque l’utilisateur choisit une autre traduction. La rédaction vérifie que la méditation reste cohérente avec les éditions proposées.

La [Bible en français courant et Parole de Vie](https://www.alliancebiblique.fr/traduction) sont présentées par l’Alliance biblique française; leur disponibilité sur un site de lecture ne vaut pas autorisation de les intégrer à une autre application. [Biblica](https://www.biblica.com/permissions/) indique que l’utilisation de ses textes dans une application peut nécessiter une permission ou une licence. [The Lockman Foundation](https://www.lockman.org/permission-to-quote-copyright-trademark-information/) donne des plafonds et des mentions propres à l’AMP, y compris pour les applications. [Cambridge](https://www.cambridge.org/rights-and-permissions/permissions-faqs) traite les demandes relatives à la KJV.

- La méditation explique le lien avec la gratitude sans promettre un résultat spirituel, matériel ou médical.
- Une personne responsable relit les références, le contexte du passage, la langue et la conformité aux droits de citation avant publication.
- Le contenu est rédigé pour être compréhensible sans présumer du niveau de connaissance biblique de l’utilisateur.
- Toute modification après publication crée une nouvelle version et conserve un historique éditorial.
- Les droits d’utilisation de la traduction biblique doivent être vérifiés **avant** la mise en production : reproduction dans l’application, mise en cache hors connexion, partage et attribution peuvent relever de conditions distinctes.
- Une traduction sans droit confirmé reste désactivée dans le catalogue public. Les règles de licence sont enregistrées par édition : territoires, plafond de versets, cache autorisé, partage autorisé, texte d’attribution et durée de validité.

## 5. Règles fonctionnelles détaillées

### 5.1 Sélection du jour et des trois rendez-vous

- Le « jour » correspond à la date civile du fuseau horaire de l’appareil. Chaque jour comporte trois créneaux : `morning`, `midday` et `evening`.
- Les versets deviennent disponibles à l’heure locale suivante : matin à **05 h 00**, midi à **12 h 00** et soir à **18 h 00**. Les créneaux précédents restent accessibles jusqu’à la fin de la journée.
- La référence et la méditation de chaque créneau sont les mêmes pour tous les utilisateurs d’une même langue à cette date; le texte du verset dépend de la traduction choisie.
- Le serveur publie un ensemble éditorial par couple `(date, créneau)` et une localisation par triplet `(date, créneau, langue)`; l’application utilise cette clé pour éviter les doublons.
- Après une synchronisation en ligne, l’heure du serveur sert à détecter un décalage important de l’horloge de l’appareil. L’application conserve le dernier contenu valide et propose une nouvelle synchronisation en cas d’incohérence.
- Un changement de fuseau horaire peut changer la date affichée; le comportement suit la date civile du nouveau fuseau.
- Si le contenu d’un créneau manque côté serveur, l’application affiche le dernier contenu disponible pour ce créneau avec sa date réelle. Elle ne le présente jamais comme un nouveau verset.

### 5.2 Notifications

- Trois rappels locaux peuvent être activés séparément : matin, midi et soir. Ils sont tous désactivés tant que l’utilisateur n’a pas donné son accord.
- Les heures proposées sont **08 h 00** le matin, **12 h 00** à midi et **20 h 00** le soir. L’utilisateur peut modifier ou désactiver chaque rappel.
- Chaque rappel ouvre directement le créneau correspondant de l’écran « Aujourd’hui ». Son texte reste générique afin de fonctionner hors connexion et de ne pas afficher de contenu non synchronisé.
- Les changements d’heure et de fuseau déclenchent le recalcul des trois prochains rappels.
- La désactivation d’un créneau supprime seulement le rappel correspondant ; la désactivation globale supprime les trois rappels programmés sur l’appareil.

### 5.3 Cache et favoris

- Au lancement ou au retour en ligne, l’application récupère les trois contenus du jour et jusqu’à **30 jours** de publications déjà approuvées pour un usage hors connexion. Elle met en cache le texte de la traduction choisie seulement si ses droits le permettent.
- Les contenus futurs présents dans le cache ne deviennent visibles qu’à leur date et à leur heure de créneau.
- Les favoris sont stockés localement; leur perte lors d’une désinstallation est expliquée dans les réglages.
- Une version modifiée d’un contenu met à jour le cache tout en conservant le statut « favori » associé à son identifiant stable.
- En mode avion, un changement vers une traduction non téléchargée affiche la référence et la méditation avec un message de connexion requise; l’application n’attribue jamais le texte d’une autre traduction à la nouvelle édition.

## 6. Architecture proposée

```text
Équipe éditoriale → Interface d’administration → API de contenu → Base de données
                                                ↓
Application Flutter iOS/Android ← HTTPS/JSON ← API
          ↓
Stockage local : cache, favoris, préférences et rappels locaux
```

**Application mobile :** Flutter / Dart, avec une architecture MVVM : vues, ViewModels, repositories et services. Un stockage SQLite local, accédé via Drift, conserve les publications synchronisées, les favoris et les préférences. Les rappels utilisent les services de notification locale du système.

**Service de contenu :** Supabase fournit PostgreSQL, l’authentification des administrateurs, les politiques d’accès, les Edge Functions et les tâches planifiées. Une console d’administration Next.js réservée à Gaius Consulting permet la rédaction, la relecture, l’approbation et le retrait du contenu. Les Edge Functions exposent l’API HTTPS de lecture et appellent les services bibliques externes ; les clés et le rôle de service restent exclusivement côté serveur.

**Connexion à la Bible en ligne :** le téléphone ne contacte jamais directement le fournisseur biblique. Pour le pilote, lorsqu’un éditeur choisit une référence, un connecteur serveur importe le texte LSG 1910 depuis API.Bible, avec son identifiant d’édition, son URL, sa date de récupération, son empreinte et son attribution. Le texte est ensuite figé, relu et approuvé avant publication. Aucun choix aléatoire de verset ne provient de la source. eBible constitue le repli documenté pour le corpus LSG 1910 déclaré public.

**Publication :** une référence commune est choisie, puis chaque langue active reçoit sa méditation, sa prière et son action. Les textes bibliques sont associés séparément à chaque traduction autorisée. Les localisations et variantes de verset prévues pour une vague de déploiement sont relues et approuvées avant la publication du jour. L’API ne sert au public que les localisations et traductions approuvées. Le pilote français garde une réserve d’au moins 30 jours validés ; chaque langue publique active garde ensuite cette même réserve.

### 6.1 Modèle de données minimal

| Entité | Champs principaux | Contraintes |
| --- | --- | --- |
| `daily_content` | `id`, `publication_date`, `slot`, `book_code`, `chapter`, `verse_start`, `verse_end`, `status`, `created_at`, `updated_at` | Une référence biblique commune par couple `(date, créneau)` ; `slot` vaut `morning`, `midday` ou `evening`. |
| `content_localization` | `id`, `content_id`, `locale`, `revision`, `status`, `display_reference`, `reflection`, `prayer`, `gratitude_action` | Une localisation active par contenu, créneau et langue. |
| `bible_translation` | `code`, `locale`, `name`, `edition`, `rights_holder`, `license_status`, `territories`, `offline_allowed`, `sharing_allowed`, `attribution`, `expires_at` | Une édition exacte et ses droits documentés; publication seulement si autorisée. |
| `bible_source` | `id`, `provider`, `provider_bible_id`, `source_url`, `license_snapshot`, `checked_at` | Trace la source en ligne et la vérification de droits de chaque édition. |
| `verse_variant` | `content_id`, `translation_code`, `source_id`, `provider_verse_id`, `verse_text`, `display_reference`, `content_hash`, `retrieved_at`, `revision`, `status` | Texte exact du passage dans une édition; une variante active par contenu et traduction, traçable jusqu’à sa source. |
| `content_revision` | `id`, `localization_id`, `revision`, `snapshot`, `editor_id`, `approved_by`, `approved_at` | Historique non modifiable après validation. |
| `editor` | `id`, `role`, `active` | Accès réservé à l’administration. |
| `local_favorite` | `content_id`, `saved_at` | Présent uniquement sur l’appareil dans la première version. |
| `local_preferences` | `morning_notification_enabled`, `morning_notification_time`, `midday_notification_enabled`, `midday_notification_time`, `evening_notification_enabled`, `evening_notification_time`, `locale`, `translation_code` | Présent uniquement sur l’appareil. |

Le modèle conserve une référence structurée commune et une référence affichable dans chaque langue ou traduction, par exemple « Psaume 100:4 ». Les champs de texte autorisent Unicode et les références comprenant plusieurs versets. `locale` utilise des identifiants normalisés tels que `fr`, `pt-BR` et `ar`. Les correspondances de numérotation entre éditions sont vérifiées avant publication.

### 6.2 Contrat API minimal

| Route | Usage | Réponse attendue |
| --- | --- | --- |
| `GET /v1/translations?locale=fr` | Catalogue des éditions accessibles | Code, édition, statut, mention de droits et capacités autorisées pour la zone de diffusion. |
| `GET /v1/content/daily?date=AAAA-MM-JJ&locale=fr&translation=LSG1910` | Trois contenus d’une date dans une langue et une édition | Trois créneaux `morning`, `midday`, `evening` avec statut de disponibilité, publication approuvée, identifiant stable, révisions, métadonnées, texte exact et attribution. |
| `GET /v1/content/range?from=...&to=...&locale=fr&translation=LSG1910` | Historique et réserve hors connexion dans une édition | Liste ordonnée des publications accessibles; maximum 30 jours futurs si le cache est autorisé. |
| `GET /v1/health` | Supervision du service | État technique sans données personnelles. |

Les réponses portent un identifiant de version ou un `ETag` pour éviter de retélécharger un contenu inchangé. Les erreurs distinguent une date sans publication (`404`), une requête invalide (`400`) et une indisponibilité temporaire du service (`503`). L’API administrative est séparée des routes publiques et impose authentification et rôles.

## 7. Exigences non fonctionnelles

### Accessibilité et ergonomie

- Lecture compatible avec les lecteurs d’écran, l’agrandissement de police et les paramètres de contraste du système.
- Taille des zones tactiles, ordre de lecture et libellés vérifiés sur les deux plateformes.
- Aucun élément essentiel n’est communiqué uniquement par la couleur.
- Le texte biblique reste sélectionnable et lisible sans animation obligatoire.
- Les écrans arabes, la navigation et le texte partagé sont vérifiés de droite à gauche; les références et nombres mixtes restent lisibles.

### Vie privée et sécurité

- Aucun compte et aucune donnée personnelle nécessaires pour lire les versets.
- Favoris et préférences restent sur l’appareil dans la première version.
- Communications chiffrées par HTTPS; secrets et accès éditoriaux conservés côté serveur.
- Rôles distincts de rédaction et d’approbation; journal des changements éditoriaux.
- Une politique de confidentialité décrit les données techniques réellement collectées. L’analyse d’usage, si ajoutée, doit être définie et consentie selon les obligations applicables avant activation.

### Fiabilité et performance

- L’écran du jour s’affiche immédiatement à partir du cache lorsqu’il existe; la synchronisation se fait ensuite en arrière-plan.
- Les erreurs réseau n’effacent jamais un contenu déjà téléchargé ni les favoris.
- La sauvegarde de la base serveur et la restauration sont documentées et testées avant lancement.
- Les erreurs de publication, de synchronisation et de notification sont observables sans enregistrer le texte des préférences personnelles.

## 8. Critères d’acceptation

1. Pour une date, un créneau, une langue et une traduction donnés, deux installations synchronisées affichent le même verset et la même révision.
2. Une publication non approuvée ou datée dans le futur n’apparaît pas dans l’historique public avant sa date.
3. Après téléchargement, les trois contenus du jour restent lisibles en mode avion à partir de leur heure de disponibilité; les favoris restent utilisables.
4. À minuit dans le fuseau local, l’écran « Aujourd’hui » passe à la nouvelle date après ouverture ou reprise de l’application.
5. Un refus de notification n’interrompt ni la lecture, ni les favoris, ni le partage.
6. La modification de l’heure d’un rappel de créneau remplace le rappel précédent sans notification en double.
7. Un partage contient la référence biblique et l’attribution de traduction requise.
8. Si le service ne fournit pas le contenu du jour, l’application signale explicitement la date du dernier contenu disponible.
9. Une correction éditoriale approuvée remplace la version en cache lors de la prochaine synchronisation et conserve le favori.
10. Les parcours « Aujourd’hui », « Historique », « Favoris » et « Réglages » restent utilisables avec lecteur d’écran et texte agrandi.
11. Les langues actives d’une même vague affichent la même référence pour une date et un créneau donnés, avec leur traduction et leur méditation approuvées.
12. Le changement de langue actualise l’interface, le contenu du jour et le partage sans perdre les favoris.
13. Les écrans arabes sont lisibles de droite à gauche et aucune chaîne non traduite ne subsiste dans les parcours principaux.
14. Le changement de traduction conserve la date, la référence, la méditation et le statut favori, mais remplace le texte biblique et l’attribution.
15. Une traduction sans autorisation enregistrée n’apparaît pas dans la liste publique et aucun texte ne peut être servi par son code.
16. Un changement de traduction hors connexion n’affiche pas un verset incorrectement attribué si son texte n’est pas en cache.

## 9. Plan de réalisation

1. **M0 — Cadrage verrouillé :** valider les droits, le processus éditorial, les indicateurs de bêta, l’hébergement et la politique de cache. Préparer 30 jours de trois créneaux français, plus 30 jours de réserve.
2. **M1 — Pilote français :** valider l’écran des trois rendez-vous, la lisibilité, le ton de la méditation, les trois rappels, l’API et l’administration éditoriale minimale.
3. **M2 — Bêta fermée :** tester sur iOS et Android les notifications, les changements de date et de fuseau, le mode avion, les corrections urgentes, l’accessibilité et les indicateurs de succès.
4. **M3 — Lancement public progressif :** publier le français après revue de passage, puis activer les sept autres langues par vagues lorsque leurs contenus, droits et relectures sont validés.

## 10. Décisions de cadrage retenues

Les décisions ci-dessous reprennent les réponses validées. Les **éditions exactes** et les **droits d’utilisation** restent des conditions préalables à l’activation de chaque traduction.

1. **Langues de lancement.** La bêta fermée commence en français. Le lancement public vise les huit langues `fr`, `en`, `es`, `pt-BR`, `de`, `it`, `ar` et `sw`, activées par vagues. Le français sert de langue de travail éditoriale; toute version affichée au public est relue par une personne maîtrisant sa langue.
2. **Versions bibliques.** Le pilote français utilise **Louis Segond 1910 (LSG 1910)** comme unique traduction, récupérée par API.Bible au titre des accords acceptés par Gaius Consulting pour le pilote non commercial. Le cache API.Bible est actualisé au moins tous les 30 jours ; toute attribution requise est affichée. eBible constitue le repli documenté pour le corpus LSG 1910 déclaré public. BFC, BDS et PDV sont envisagées après le pilote, avec droits validés. KJV et AMP, puis Reina-Valera 1909 (ES), Bíblia Portuguesa Mundial (PT-BR), Luther 1912 (DE), Riveduta 1927 (IT), Van Dyck (AR) et Open Neno 2024 (SW), restent des candidats de vagues ultérieures sous réserve de relecture et de droits. [Louis Segond 1910 — eBible](https://ebible.org/fraLSG/copyright.htm) · [Analyse conformité API.Bible](ANALYSE_CONFORMITE_API_BIBLE_ThanksGiving_Quote.md).
3. **Reproduction dans l’application.** Conserver pour chaque traduction une fiche de droits avec source, édition exacte, titulaire, territoires visés, attribution requise et preuve de permission. N’intégrer un texte qu’après vérification de son statut dans les pays de diffusion. Le statut « domaine public » indiqué par eBible est présenté pour les États-Unis et ne règle pas automatiquement la situation dans chaque pays. [Politique eBible](https://ebible.org/legal.php).
4. **Usage hors connexion.** Mettre en cache la traduction choisie seulement si sa licence l’autorise; limiter la réserve à 30 jours et appliquer les plafonds propres à chaque édition. Pour Open Neno, faire vérifier l’application des obligations CC BY-SA au texte extrait et à ses éventuelles adaptations avant intégration. Si une édition interdit ce cache, la rendre accessible uniquement en ligne ou en choisir une autre.
5. **Partage.** Partager le verset avec sa référence, le nom de la traduction et les mentions exigées par cette traduction. Prévoir un gabarit de partage distinct par licence; ne pas inclure automatiquement la méditation ni une image sous des droits non vérifiés. Le partage de la méditation originale peut être activé après validation éditoriale.
6. **Ligne éditoriale.** Adopter une orientation chrétienne interconfessionnelle, centrée sur les livres bibliques communs aux principales traditions, la gratitude, l’espérance et la prière. Éviter les affirmations polémiques et les promesses de guérison ou de prospérité. Préciser publiquement cette orientation dans « À propos ».
7. **Relecture et approbation.** **Gaius Consulting** est le propriétaire produit, éditorial et technique de l’application. La société désigne nominativement un Product Owner, un responsable éditorial, un relecteur biblique et un responsable technique ; un auteur ne peut pas approuver seul son propre contenu. La validation vérifie le passage, le contexte, la fidélité du verset, la qualité de la langue, le ton et l’attribution.
8. **Couverture annuelle.** Fournir **trois contenus par date de l’année**, y compris le 29 février : un le matin, un à midi et un le soir. Le pilote français prépare **30 jours de publication (90 contenus) plus 30 jours de réserve (90 contenus), soit 180 contenus au total**. Chaque langue publique passe ensuite à 90 jours, soit 270 contenus, et maintient au moins 30 jours approuvés d’avance. L’administration alerte sous 45 jours de réserve.
9. **Marque.** Utiliser **ThanksGiving Quote** comme nom affiché et le sous-titre français exact **« Rendre Grâce à DIEU chaque jour »**. Prévoir une adaptation fidèle du sous-titre dans les sept autres langues. Vérifier la disponibilité du nom, du domaine et des identifiants des boutiques avant la publication.
10. **Exploitation et corrections.** L’architecture retenue est Flutter / SQLite-Drift pour l’application, Supabase (PostgreSQL, Auth, Edge Functions et Cron) pour le service, et une console Next.js pour l’administration Gaius Consulting. Aucun mécanisme de publicité, achat intégré, abonnement, freemium ou collecte de fonds ne fait partie du pilote. Mettre en place des alertes de contenu manquant, échec de publication, échec de synchronisation et réserve éditoriale sous 45 jours. En cas d’erreur, retirer immédiatement la localisation concernée, publier une révision approuvée, invalider le cache par son numéro de version et consigner la correction ; si la référence change, corriger toutes les langues actives concernées. Définir une personne de garde et un délai interne de traitement avant le lancement.

### Points à valider en priorité

Les choix de pilote sont retenus. Avant d’ouvrir la bêta, Gaius Consulting doit désigner les personnes titulaires des rôles, vérifier dans son compte API.Bible l’édition LSG 1910 et ses métadonnées, enregistrer la fiche de provenance et de droits, préparer les 180 contenus et créer les environnements Supabase. Les accords API.Bible applicables au pilote non commercial sont confirmés comme acceptés ; une copie lisible des Terms of Service doit néanmoins être archivée dans le registre contractuel. Les éditions BFC, BDS, PDV et les traductions des sept autres langues restent soumises à leurs permissions propres.
