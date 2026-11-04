# Analyse de conformité API.Bible — ThanksGiving Quote

**Date :** 3 novembre 2026  
**Statut :** analyse de produit et de conformité opérationnelle ; ne remplace pas une revue juridique ni l’acceptation formelle d’un contrat par Gaius Consulting.

## 1. Documents examinés

1. *Minimum Acceptable Use Agreement*.
2. *Strictly Non-commercial Use Agreement*.
3. *Statement of Orthodoxy*.
4. *Terms of Service* fourni sous forme de 22 pages visuellement noires et sans texte extractible ; son contenu n’a donc pas pu être vérifié dans ce dossier.

## 2. Obligations opérationnelles identifiées

| Domaine | Obligation à respecter | Conséquence produit |
| --- | --- | --- |
| Intégrité du texte | Le texte biblique obtenu via API.Bible ne doit pas être modifié. | Conserver le texte source tel que reçu ; séparer strictement verset, méditation et prière originale. |
| Cache | Le contenu API.Bible placé en cache doit être actualisé au moins tous les 30 jours. | Ajouter `source_refreshed_at` et une tâche de contrôle qui bloque l’affichage d’un cache expiré si l’accord le requiert. |
| Format | Un contenu protégé est utilisé uniquement dans le format fourni : texte ou audio. | Le pilote n’utilise que le texte ; aucune synthèse vocale, aucun audio dérivé et aucune conversion texte-audio. |
| Citation | Les contenus protégés exigent une citation conforme aux conditions de l’ayant droit. | Conserver le gabarit d’attribution par traduction et l’afficher avec le verset et dans les réglages. |
| Attribution API.Bible | Le Starter Plan requiert une citation visible et un lien vers API.Bible dans l’interface. | Prévoir une attribution API.Bible dans « À propos / Sources » si le Starter Plan est retenu. |
| IA | Le contenu protégé ou sous licence Creative Commons obtenu via API.Bible ne peut pas servir à entraîner ou alimenter un modèle d’IA sans consentements écrits. | Maintenir l’exclusion de toute fonction IA pour le texte biblique et empêcher tout envoi de verset vers un LLM. |
| Marques | Logos et identités API.Bible, ABS et ayants droit ne sont pas libres d’emploi. | Ne pas intégrer leurs logos au prototype, à l’application ou aux visuels marketing sans permission écrite. |
| Ligne chrétienne | L’usage doit rester cohérent avec le message biblique et la déclaration d’orthodoxie présentée. | La ligne éditoriale de gratitude reste compatible en principe ; Gaius Consulting doit confirmer qu’elle accepte la déclaration avant de souscrire. |

## 3. Régime non commercial accepté

L’accord « Strictly Non-commercial » interdit notamment :

- la publicité ;
- les achats intégrés ;
- les abonnements gratuits avec options payantes ou les abonnements payants ;
- les usages de collecte de fonds, hormis une exception limitée aux liens discrets de dîme ou de don ;
- tout usage générant un revenu.

Gaius Consulting a confirmé avoir accepté les accords API.Bible applicables. ThanksGiving Quote est donc conçu comme un produit **strictement non commercial** pendant le pilote et tant que ce régime est utilisé. L’exception de don ne s’applique pas aux sociétés à but lucratif ; aucun lien de don ne sera donc intégré au pilote sans avis contractuel explicite.

## 4. Décision de conformité recommandée

### 4.1 Pilote français

Le pilote utilise **API.Bible côté serveur** pour récupérer l’édition LSG 1910 autorisée dans le compte Gaius Consulting. eBible reste une source de repli documentée pour le corpus LSG 1910 déclaré public, en cas d’indisponibilité ou de retrait de l’édition API.Bible.

Le connecteur côté serveur importe un passage choisi par l’équipe éditoriale. Il conserve le fournisseur, l’identifiant de Bible, la référence, l’URL, la date de récupération, l’empreinte du texte et l’attribution. Aucun verset n’est tiré de façon aléatoire ni modifié.

### 4.2 API.Bible pendant et après le pilote

API.Bible est le fournisseur privilégié du pilote et des traductions futures sous réserve des contrôles suivants :

1. L’édition exacte est disponible pour le compte et ses métadonnées sont archivées.
2. Les droits d’affichage, de cache, de partage, d’attribution et de territoire sont enregistrés dans le registre de droits.
3. Le cache issu d’API.Bible est actualisé au moins tous les 30 jours.
4. La citation API.Bible requise par le plan retenu est affichée et testée.
5. Tout changement vers un modèle économique commercial déclenche une revue préalable et, si nécessaire, l’adoption d’une licence commerciale.

## 5. Changements imposés au produit

| Élément | Décision |
| --- | --- |
| Fournisseur pilote | API.Bible, édition LSG 1910 autorisée dans le compte Gaius Consulting. |
| eBible | Source de repli documentée pour le corpus LSG 1910 déclaré public. |
| Partage pilote | Autorisé seulement avec la mention LSG 1910 et la source définie dans le registre de droits. |
| Cache pilote | Cache local des contenus éditoriaux LSG approuvés ; contrôle de provenance conservé. |
| IA | Hors périmètre et techniquement bloquée pour le texte biblique. |
| Revenus | Aucun mécanisme publicitaire, achat, abonnement, freemium ou collecte de fonds dans le pilote. |
| Logos | Aucun logo ABS/API.Bible ou ayant droit sans autorisation écrite. |

## 6. Checklist avant intégration API.Bible

- [x] Gaius Consulting confirme l’acceptation des accords API.Bible applicables au pilote non commercial.
- [ ] Copie lisible des Terms of Service archivée dans le registre contractuel de Gaius Consulting.
- [ ] Bible ID, édition, métadonnées de droits et territoire enregistrés.
- [ ] Attribution affichée et testée dans l’écran de verset et les réglages.
- [ ] Cache avec actualisation maximale de 30 jours testé.
- [ ] Absence de flux IA, audio dérivé et usage de logo vérifiée.
- [ ] Test de retrait rapide d’une traduction ou d’un contenu sous licence effectué.
