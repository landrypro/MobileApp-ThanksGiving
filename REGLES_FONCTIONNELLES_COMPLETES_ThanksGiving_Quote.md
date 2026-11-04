# Règles fonctionnelles complètes — ThanksGiving Quote

**Version :** 1.5 — API.Bible activée pour le pilote non commercial  
**Date :** 3 novembre 2026  
**Produit :** application mobile iOS et Android  
**Nom affiché :** ThanksGiving Quote  
**Sous-titre :** Rendre Grâce à DIEU chaque jour

Ce document complète la [spécification technique](SPECIFICATION_TECHNIQUE_ThanksGiving_Quote.md). Il décrit le comportement attendu de l’application, du contenu quotidien et de l’administration éditoriale.

## 1. Règle fondatrice

Chaque jour, ThanksGiving Quote propose **trois versets bibliques** dont le thème est **« Rendre Grâce à DIEU »** : un le matin, un à midi et un le soir. Chaque rendez-vous aide l’utilisateur à lire la Parole, méditer, prier et poser une action concrète de gratitude.

Le produit privilégie trois rendez-vous quotidiens courts, fiables, accessibles et bibliquement responsables. Il ne remplace pas une Bible complète, une étude biblique, une communauté chrétienne, un accompagnement pastoral, médical ou psychologique.

## 2. Principes de produit

1. L’application est utilisable sans compte dans sa première version.
2. Le contenu du jour est accessible en deux interactions maximum après ouverture de l’application.
3. La lecture de chaque rendez-vous doit prendre moins de deux minutes.
4. L’application privilégie la simplicité : trois versets par jour, chacun avec une méditation, une prière facultative et une action de gratitude.
5. Aucun élément essentiel ne dépend uniquement de la couleur, d’une animation ou d’une connexion réseau permanente.
6. Aucune publicité, paiement, réseau social, commentaire public, audio ou personnalisation par intelligence artificielle n’est inclus dans la première version.

### 2.1 Règles de pilote et de déploiement

1. La bêta fermée est proposée en français avec **Louis Segond 1910 (LSG 1910)** comme unique traduction. Le texte provient d’API.Bible via un connecteur serveur ; le corpus eBible déclaré public constitue un repli documenté. Les autres langues et traductions restent désactivées jusqu’à validation de leurs contenus, relectures et droits.
2. Le lancement public vise les huit langues retenues, activées par vagues. Une langue ne dépend pas de la publication d’une autre langue pour être activée ou retirée.
3. Le pilote comporte 30 jours de trois créneaux, soit 90 contenus français approuvés, et une réserve éditoriale de 30 jours supplémentaires, soit 90 contenus de réserve.
4. Les mesures de pilote sont agrégées et minimisées. Elles peuvent mesurer l’ouverture d’un créneau, l’activation d’un rappel, le retour à sept jours, la synchronisation et les incidents ; elles ne collectent jamais le texte d’une prière, d’une gratitude ou d’une note personnelle.
5. Le passage au lancement public est soumis à une revue produit, technique et éditoriale : droits valides, parcours critiques testés, aucun incident bloquant ouvert et objectifs de bêta examinés.

## 3. Périmètre fonctionnel de la première version

| Fonction | Règle principale |
| --- | --- |
| Trois versets quotidiens | Afficher un contenu de gratitude le matin, à midi et le soir pour chaque date civile. |
| Traductions | Permettre le choix d’une traduction autorisée dans la langue de l’utilisateur. |
| Méditation | Fournir une réflexion originale, brève et liée au passage. |
| Prière | Proposer une prière facultative liée au thème du jour. |
| Action | Proposer une action simple de gratitude. |
| Historique | Consulter les contenus antérieurs publiés. |
| Favoris | Enregistrer et retirer des contenus sur l’appareil. |
| Partage | Partager un contenu conforme aux droits de la traduction. |
| Rappels | Programmer, modifier ou désactiver indépendamment les rappels locaux du matin, de midi et du soir. |
| Hors connexion | Lire les contenus téléchargés et autorisés. |
| Réglages | Modifier langue, traduction, rappel et consulter les informations légales. |

## 4. Règles des trois rendez-vous quotidiens

### 4.1 Rythme de publication

Chaque date civile comporte trois contenus indépendants :

| Créneau | Code | Heure locale de disponibilité | Intention éditoriale |
| --- | --- | --- | --- |
| Matin | `morning` | 05 h 00 | Commencer la journée dans la louange et la reconnaissance. |
| Midi | `midday` | 12 h 00 | Faire une pause pour reconnaître la présence et la bonté de DIEU. |
| Soir | `evening` | 18 h 00 | Terminer la journée par l’action de grâce, la paix et l’espérance. |

1. Un créneau devient visible à son heure locale de disponibilité.
2. Un créneau déjà disponible reste accessible jusqu’à la fin de la journée.
3. Un créneau futur affiche son nom et son heure, mais ne révèle ni le texte biblique ni la méditation avant son ouverture.
4. Le contenu de chaque créneau est identifié de manière stable par le couple `(date, créneau)`.
5. L’historique rend accessibles les trois créneaux d’une date passée.

### 4.2 Contenu obligatoire

Chaque publication de créneau contient obligatoirement :

1. Une date de publication.
2. Une référence biblique structurée : livre, chapitre, verset de début et verset de fin éventuel.
3. Le texte exact du verset dans la traduction choisie.
4. Le nom, l’édition et l’attribution requise de la traduction.
5. Une méditation originale reliée au thème de la gratitude.
6. Une version localisée du contenu pour chaque langue publiée.

### 4.3 Contenu facultatif recommandé

1. Une prière de gratitude courte, de 40 à 80 mots maximum dans chaque langue.
2. Une action de gratitude réalisable dans la journée, en une phrase.
3. Une question de réflexion facultative, sans obligation de réponse ni stockage automatique.

### 4.4 Choix des versets

1. Chaque verset ou passage doit être relié explicitement à la reconnaissance, à la louange, à la bonté de DIEU, à sa fidélité, à la grâce, au salut, à l’espérance, à la paix ou à la prière reconnaissante.
2. Le contexte biblique du passage est vérifié avant publication.
3. Un verset ne peut pas être employé pour soutenir une promesse de guérison, de richesse, de réussite matérielle ou de résultat spirituel garanti.
4. Les passages pouvant être facilement mal compris sont accompagnés d’une méditation qui rétablit leur contexte ou sont écartés de la programmation quotidienne.
5. Un même verset ne doit pas être repris pendant l’année, sauf série éditoriale annoncée et validée.
6. La programmation couvre les 365 jours de l’année et le 29 février, avec trois créneaux par date.
7. La même référence biblique est utilisée pour toutes les langues à une date et un créneau donnés. Le texte et la référence affichée peuvent varier selon l’édition biblique.

### 4.5 Ton éditorial

1. Le ton est chrétien, interconfessionnel, encourageant, humble, accessible et respectueux.
2. Les contenus évitent les controverses confessionnelles, politiques et culturelles qui ne servent pas l’objectif de gratitude.
3. La méditation est compréhensible par une personne découvrant la Bible.
4. La prière utilise un langage inclusif et non contraignant : elle invite à prier, sans imposer de formule.
5. L’action quotidienne ne doit pas créer de risque pour l’utilisateur ou une autre personne.

## 5. Règles de langues et localisations

### 5.1 Langues de lancement

L’application est disponible au lancement dans les langues suivantes :

| Code | Langue |
| --- | --- |
| `fr` | Français |
| `en` | Anglais |
| `es` | Espagnol |
| `pt-BR` | Portugais du Brésil |
| `de` | Allemand |
| `it` | Italien |
| `ar` | Arabe |
| `sw` | Swahili |

### 5.2 Sélection de langue

1. Pendant le pilote, le français est proposé au premier lancement. Lors du lancement public, l’application propose la langue du téléphone si elle fait partie des langues actives.
2. Si la langue du téléphone n’est pas active, le français est proposé par défaut.
3. L’utilisateur peut modifier la langue dans les réglages à tout moment.
4. Le choix manuel de l’utilisateur prévaut toujours sur la langue du téléphone.
5. Le changement de langue actualise l’interface, le contenu quotidien, l’historique disponible et les modèles de partage.
6. Le changement de langue ne supprime pas les favoris ; ceux-ci restent associés à l’identifiant stable du contenu quotidien.
7. Si le contenu localisé manque dans la langue choisie, l’application indique la dernière date disponible dans cette langue. Elle ne remplace jamais silencieusement le contenu par une autre langue.

### 5.3 Règles de localisation

1. Les interfaces, méditations, prières, actions, dates, noms de livres et textes de partage sont localisés.
2. Le texte biblique n’est jamais traduit par l’application : seule une édition biblique autorisée est affichée.
3. Une personne compétente dans la langue concernée valide chaque localisation avant publication.
4. L’arabe utilise une mise en page de droite à gauche, y compris dans les écrans de partage et les réglages.
5. Les chiffres, références bibliques et signes de ponctuation mixtes sont vérifiés en arabe pour rester lisibles.

## 6. Règles des traductions bibliques

### 6.1 Catalogue

1. Une traduction ne peut apparaître dans le catalogue public que si son édition exacte est identifiée.
2. Chaque traduction possède une fiche de droits contenant : titulaire, territoires, attribution, date d’expiration, règles de cache et règles de partage.
3. Une traduction sans droit confirmé reste désactivée et n’est pas proposée à l’utilisateur.
4. Une traduction peut être active dans un pays et inactive dans un autre selon ses droits.

### 6.2 Choix de traduction

1. L’utilisateur choisit une traduction parmi celles autorisées dans sa langue et son territoire.
2. Le changement de traduction conserve la date, la référence, la méditation, la prière, l’action et l’état favori.
3. Le changement de traduction remplace le texte biblique, la référence affichée si nécessaire et l’attribution.
4. La traduction active est visible sur l’écran du jour, dans les favoris et dans le partage.
5. La traduction par défaut de chaque langue est définie avant le lancement.
6. Si la traduction active devient indisponible, l’application informe l’utilisateur et propose une traduction autorisée ; elle ne substitue aucun texte sans l’indiquer.

### 6.3 Cache et partage des traductions

1. Le texte d’une traduction ne peut être mis en cache que si sa licence le permet.
2. Le texte d’une traduction ne peut être partagé que si sa licence le permet.
3. Une licence peut imposer un plafond de versets, une durée, une mention précise ou une restriction territoriale.
4. L’application applique les règles les plus restrictives lorsqu’une information de licence est incomplète.
5. Pour le pilote LSG 1910, la fiche de droits conserve la source API.Bible exacte, l’identifiant de Bible, l’URL, la date de vérification, l’empreinte du texte récupéré et l’attribution. Une édition dont les métadonnées ne correspondent pas à la fiche approuvée ne peut pas être importée.
6. Les accords API.Bible applicables au pilote non commercial sont acceptés par Gaius Consulting. Toute traduction obtenue via API.Bible respecte ses obligations d’attribution, d’actualisation du cache et d’interdiction de conversion de format ; ces règles priment sur les règles générales du produit.

## 7. Parcours de premier lancement

1. L’écran de bienvenue présente la mission : « Rendre Grâce à DIEU chaque jour ».
2. L’utilisateur peut commencer sans créer de compte.
3. La langue est proposée selon les règles de sélection de langue.
4. L’application affiche ensuite l’écran « Aujourd’hui ».
5. L’autorisation de notifications n’est jamais demandée au premier écran par défaut.
6. L’autorisation de notifications est demandée uniquement lorsque l’utilisateur active son premier rappel.
7. Si l’application est ouverte sans connexion avant toute synchronisation, elle explique qu’un téléchargement initial est nécessaire et propose une action « Réessayer ».

## 8. Règles de l’écran « Aujourd’hui »

### 8.1 Informations affichées

L’écran « Aujourd’hui » affiche dans cet ordre :

1. La date du jour.
2. Le numéro de jour dans l’année, facultatif.
3. Les trois rendez-vous du jour : matin, midi et soir, avec leur état de disponibilité.
4. Le verset du créneau sélectionné.
5. La référence biblique.
6. La traduction et son attribution courte.
7. La méditation.
8. La prière, si elle est publiée.
9. L’action de gratitude, si elle est publiée.
10. Les actions « Ajouter aux favoris » et « Partager » lorsque le partage est autorisé.

### 8.2 Comportements

1. L’écran s’affiche depuis le cache dès que le créneau du moment est disponible localement.
2. La synchronisation en ligne se déroule ensuite en arrière-plan.
3. L’utilisateur peut sélectionner un créneau déjà disponible et ajouter ou retirer son contenu des favoris.
4. L’utilisateur peut ouvrir le sélecteur de traductions.
5. Une mention hors connexion apparaît lorsque le contenu affiché vient du cache sans connexion active.
6. Si le contenu d’un créneau n’existe pas ou n’est pas approuvé, l’application affiche le dernier contenu valide de ce créneau avec sa date réelle.
7. L’application ne présente jamais un contenu ancien comme une nouvelle publication quotidienne.

## 9. Règles de date, fuseau horaire et publications futures

1. Les trois contenus quotidiens correspondent à la date civile et aux heures de créneau du fuseau horaire de l’appareil.
2. Un changement de fuseau horaire peut modifier la date, le créneau disponible et le contenu affichés.
3. Après synchronisation, l’application peut comparer l’heure de l’appareil à celle du serveur pour détecter un décalage important.
4. À minuit local, la nouvelle journée est créée ; les créneaux deviennent ensuite disponibles à 05 h 00, 12 h 00 et 18 h 00.
5. Les contenus futurs peuvent être téléchargés dans le cache, mais restent invisibles avant leur date et leur heure de créneau.
6. Les dates futures ne sont jamais affichées dans l’historique public.

## 10. Règles d’historique

1. L’historique donne accès aux trois créneaux du jour courant et des jours précédemment publiés.
2. Un calendrier ou une liste permet de choisir une date disponible.
3. Les dates futures ne sont pas consultables.
4. Les jours déjà synchronisés sont accessibles hors connexion lorsque les droits des traductions le permettent.
5. Les jours non synchronisés nécessitent une connexion et proposent une action de rechargement.
6. Une publication corrigée présente la dernière révision approuvée après synchronisation.
7. Les brouillons, contenus retirés et traductions non autorisées n’apparaissent jamais dans l’historique public.
8. Un historique vide explique que les contenus apparaîtront après publication ou synchronisation.

## 11. Règles des favoris

1. Les favoris sont stockés localement dans la première version.
2. Un favori concerne un contenu de créneau identifié de manière stable par sa date et son créneau, et non une simple copie de texte.
3. L’utilisateur peut ajouter ou retirer un favori depuis l’écran « Aujourd’hui », l’historique ou la liste des favoris.
4. Les favoris sont classés du plus récent au plus ancien.
5. Une correction éditoriale conserve le statut favori du contenu concerné.
6. Le changement de langue ou de traduction ne supprime pas le favori.
7. Si le texte de la traduction demandée n’est pas disponible, le favori affiche sa référence et un message de connexion requise plutôt qu’un texte incorrectement attribué.
8. Les réglages indiquent que les favoris peuvent être perdus lors d’une désinstallation, car ils ne sont pas synchronisés dans la première version.

## 12. Règles de partage

1. Le partage utilise la feuille de partage native du téléphone.
2. Un partage autorisé contient au minimum : le texte du verset, la référence, le nom de la traduction et l’attribution exigée.
3. La méditation est ajoutée seulement lorsque l’équipe éditoriale l’autorise.
4. Une image de partage est proposée seulement lorsque les droits de la traduction le permettent.
5. Une traduction qui interdit le partage n’affiche pas l’action de partage ou explique sa restriction.
6. Les modèles de partage sont définis par traduction, par langue et par territoire si nécessaire.
7. Un texte partagé ne doit pas contenir de contenu futur, de brouillon ou de données personnelles.

## 13. Règles de rappel quotidien

1. Les trois rappels sont désactivés par défaut.
2. L’application propose trois heures : **08 h 00** le matin, **12 h 00** à midi et **20 h 00** le soir.
3. L’utilisateur peut activer, modifier ou désactiver indépendamment chacun des trois rappels dans les réglages.
4. L’autorisation système est demandée uniquement lors de l’activation du premier rappel.
5. Un refus de notification ne bloque ni la lecture, ni l’historique, ni les favoris, ni le partage.
6. Chaque rappel ouvre directement le créneau correspondant de l’écran « Aujourd’hui ».
7. Le texte de notification reste générique afin d’être valide hors connexion et de ne pas révéler un contenu non synchronisé.
8. Un changement d’heure ou de fuseau horaire recalcule les prochains rappels actifs.
9. La modification de l’heure d’un créneau remplace le rappel précédent de ce créneau.
10. La désactivation d’un créneau supprime uniquement son rappel ; la désactivation globale supprime tous les rappels programmés sur l’appareil.
11. L’application ne programme jamais deux rappels pour le même créneau de la même journée.

## 14. Règles hors connexion et synchronisation

1. Après une première synchronisation, les trois contenus du jour restent disponibles hors connexion à partir de leur heure de créneau.
2. L’application conserve jusqu’à 30 jours de contenus déjà approuvés, soit jusqu’à 90 créneaux, sous réserve des droits de chaque traduction.
3. Les contenus futurs présents dans le cache restent masqués jusqu’à leur date et leur heure de créneau.
4. Les favoris et préférences restent accessibles hors connexion.
5. Une erreur réseau ne supprime jamais les contenus déjà téléchargés, les favoris ou les préférences.
6. Si une traduction n’a pas été téléchargée, un changement de traduction hors connexion affiche la référence et un message de connexion requise.
7. L’application n’affiche jamais le texte d’une autre traduction sous le nom de la traduction demandée.
8. Le cache peut être invalidé par une nouvelle version approuvée du contenu.
9. Les contenus retirés pour une erreur grave sont masqués dès la prochaine synchronisation, avec un message approprié si l’utilisateur les consulte encore localement.

## 15. États vides, erreurs et messages utilisateur

| Situation | Comportement attendu |
| --- | --- |
| Première ouverture sans réseau | Expliquer qu’un téléchargement initial est nécessaire et proposer « Réessayer ». |
| Réseau indisponible après synchronisation | Afficher le contenu en cache et une indication hors connexion. |
| Contenu d’un créneau indisponible | Afficher le dernier contenu valide de ce créneau avec sa date réelle. |
| Traduction indisponible | Proposer une traduction autorisée ou expliquer la restriction. |
| Aucun favori | Expliquer comment ajouter un verset aux favoris. |
| Historique incomplet | Indiquer quelles dates nécessitent une connexion. |
| Notification refusée | Expliquer que le rappel peut être activé dans les réglages du téléphone. |
| Licence expirée | Désactiver le texte concerné et informer l’utilisateur sans afficher un texte non autorisé. |
| Contenu corrigé | Charger la dernière révision validée après synchronisation. |

## 16. Règles de confidentialité et de données

1. Aucun compte utilisateur n’est requis dans la première version.
2. Les favoris, la langue, la traduction et les rappels sont conservés sur l’appareil.
3. Aucune donnée personnelle n’est nécessaire pour lire le contenu quotidien.
4. Toute analytique d’usage est désactivée par défaut ou soumise à un consentement explicite avant activation.
5. Les rapports de crash ne doivent pas contenir de texte de favoris, de préférences détaillées ou de données identifiantes non nécessaires.
6. La politique de confidentialité est accessible depuis les réglages.
7. L’application explique clairement les données techniques réellement transmises au serveur.
8. Les communications avec le service de contenu utilisent HTTPS.
9. Le pilote ne comporte ni publicité, ni achat intégré, ni abonnement, ni freemium, ni collecte de fonds. Toute évolution de ce modèle exige une revue préalable des licences bibliques activées.

## 17. Règles d’accessibilité et d’ergonomie

1. L’application respecte la taille de texte choisie dans les réglages du système.
2. Les écrans restent utilisables avec les lecteurs d’écran iOS et Android.
3. Chaque action possède un libellé accessible et compréhensible.
4. Les zones tactiles respectent les dimensions recommandées par les plateformes mobiles.
5. Les contrastes restent lisibles avec la palette cyan, vert lime et gris du logo.
6. Les informations importantes sont communiquées par du texte ou une icône accompagnée d’un libellé, et non par la couleur seule.
7. Le texte biblique demeure sélectionnable et copiable lorsque les droits le permettent.
8. Les animations sont brèves, facultatives et respectent les préférences système de réduction des mouvements.
9. Les parcours principaux sont vérifiés en arabe, en mode droite à gauche.

## 18. Règles d’administration éditoriale

### 18.1 Rôles

| Rôle | Responsabilité |
| --- | --- |
| Rédacteur | Prépare le verset, la méditation, la prière et l’action. |
| Relecteur biblique | Vérifie le passage, le contexte et la cohérence théologique. |
| Relecteur linguistique | Vérifie la qualité dans chaque langue. |
| Approbateur | Valide la publication avant sa mise à disposition. |
| Responsable éditorial | Supervise la ligne éditoriale et les corrections. |
| Responsable technique | Supervise l’API, la sécurité, les sauvegardes et le cache. |

Gaius Consulting est l’entité propriétaire, éditrice et exploitante. Elle désigne nominativement les titulaires de ces rôles avant l’ouverture de la bêta.

### 18.2 Publication

1. Un rédacteur ne peut pas approuver seul son propre contenu.
2. Les statuts de contenu sont : `brouillon`, `en relecture`, `approuvé`, `programmé`, `publié`, `corrigé` et `retiré`.
3. Une publication de créneau ne devient publique que lorsque toutes les localisations prévues pour sa vague de déploiement sont approuvées. Le pilote français peut donc être publié indépendamment des autres langues.
4. Une réserve d’au moins 30 jours approuvés est maintenue en permanence, soit 90 créneaux, pour chaque langue active.
5. Une alerte est envoyée à l’équipe lorsque la réserve descend sous 45 jours.
6. Toute publication conserve son auteur, ses relecteurs, son approbateur et son numéro de révision.

### 18.3 Correction urgente

En cas d’erreur éditoriale, biblique, linguistique ou de droits :

1. Retirer immédiatement la localisation ou la traduction concernée si nécessaire.
2. Préparer une correction avec une nouvelle révision.
3. Faire approuver la correction par une personne distincte de son auteur.
4. Publier la révision approuvée.
5. Invalider la version concernée dans le cache à l’aide de son numéro de version.
6. Conserver l’historique de la correction.
7. Corriger toutes les langues actives concernées si la référence biblique commune est modifiée.

## 19. Règles de licence et de conformité

1. Les droits de reproduction sont confirmés avant toute mise en production d’une traduction.
2. Les droits de cache hors connexion sont confirmés séparément des droits de lecture en ligne.
3. Les droits de partage sont confirmés séparément des droits de cache.
4. Toute attribution imposée est affichée dans l’application et ajoutée au partage.
5. Les territoires autorisés sont enregistrés pour chaque édition.
6. Une traduction dont la licence expire est désactivée avant l’expiration si son renouvellement n’est pas confirmé.
7. Les règles les plus restrictives de chaque licence prévalent sur les choix de produit.

## 20. Règles de lancement

Le pilote, puis chaque vague de lancement public, sont autorisés seulement lorsque les conditions suivantes sont remplies :

1. Au moins une traduction validée est disponible dans chaque langue de la vague concernée ; le pilote peut ne contenir que le français.
2. Les droits de lecture, cache et partage sont documentés pour chaque traduction activée.
3. Le pilote dispose de 30 jours de trois créneaux, soit 90 contenus, et de 30 jours de réserve supplémentaires, soit 180 contenus au total. Chaque langue publique dispose avant son activation de 90 jours, soit 270 contenus, et de 30 jours de réserve.
4. Les scénarios de changement de date, de fuseau, de langue, de traduction et de rappel ont été testés.
5. Les parcours hors connexion, les messages d’erreur, la correction urgente et le retrait de contenu ont été vérifiés.
6. L’accessibilité a été vérifiée sur iOS et Android ; l’interface arabe de droite à gauche est vérifiée avant l’activation de l’arabe.
7. La politique de confidentialité, les sources bibliques et les coordonnées de contact sont publiées.
8. Les alertes de contenu manquant, échec de synchronisation, échec de publication et réserve éditoriale insuffisante sont opérationnelles.
9. Les objectifs de bêta sont examinés, aucun incident bloquant n’est ouvert et la revue produit, technique et éditoriale autorise le passage.
10. Le nom, le domaine et les identifiants de boutiques sont disponibles.

## 21. Critères de validation fonctionnelle

1. Deux appareils synchronisés affichent le même contenu pour une date, un créneau, une langue et une traduction donnés.
2. Un contenu futur n’est jamais visible avant sa date et son heure de créneau.
3. Les trois contenus du jour restent lisibles en mode avion après téléchargement, à partir de leur heure de créneau.
4. Le refus de notification n’empêche aucune autre fonction.
5. La modification de l’heure d’un rappel de créneau ne crée pas de doublon.
6. Le partage contient la référence et l’attribution requises.
7. Une traduction non autorisée n’apparaît jamais dans le catalogue public.
8. Un changement de traduction conserve la date, la référence, la méditation et l’état favori, mais remplace le texte biblique et l’attribution.
9. Un changement de langue ne supprime pas les favoris.
10. Une traduction non téléchargée hors connexion ne présente jamais un texte attribué à tort.
11. Une correction approuvée remplace la version en cache lors de la prochaine synchronisation et préserve le favori.
12. Les écrans principaux sont utilisables avec texte agrandi, lecteur d’écran et affichage arabe de droite à gauche.
13. À 05 h 00, 12 h 00 et 18 h 00 locales, le créneau correspondant devient disponible sans révéler les contenus ultérieurs avant leur heure.

## 22. Décisions restantes à confirmer

| Sujet | Proposition |
| --- | --- |
| Rythme de contenu confirmé | Trois versets par date : matin, midi et soir. |
| Heures de disponibilité proposées | 05 h 00, 12 h 00 et 18 h 00 locales. |
| Heures de rappel proposées | 08 h 00, 12 h 00 et 20 h 00, activables séparément. |
| Longueur de la méditation | 80 à 140 mots maximum selon la langue. |
| Longueur de la prière | 40 à 80 mots maximum. |
| Longueur de l’action | Une phrase courte, réalisable dans la journée. |
| Ordre de l’écran du jour | Verset, méditation, prière, action. |
| Tri des favoris | Du plus récent au plus ancien. |
| Analyse d’usage | Désactivée ou soumise à consentement explicite. |
| Traduction par défaut | Une édition autorisée à définir dans chaque langue au moment de son activation. |

---

**Statut du document :** proposition complète à valider par le responsable produit, le responsable éditorial et le responsable technique avant le développement.
