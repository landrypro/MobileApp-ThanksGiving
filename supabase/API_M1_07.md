# Contrat d'API M1-07 — ThanksGiving Quote

**Version :** 1.0  
**Date :** 6 novembre 2026

## 1. Principes de sécurité

- Le mobile n'appelle jamais API.Bible directement.
- `API_BIBLE_API_KEY` reste dans les secrets des Edge Functions.
- La lecture publique passe par une Edge Function et non par la Data API :
  `anon` et `authenticated` ne possèdent aucun droit direct sur
  `daily_verse_contents`.
- Le connecteur API.Bible accepte soit un JWT Supabase appartenant à une
  identité dont `app_metadata.roles` contient `admin`, `editorial_admin` ou
  `editor`, soit une clé secrète Supabase transmise dans l'en-tête `apikey`.
- Le connecteur ne sélectionne pas aléatoirement un verset, ne modifie pas son
  texte et ne publie aucune donnée. L'enregistrement et l'approbation relèvent
  de M1-08.

## 2. Lecture du jour et de l'historique

### Requête

```http
GET /functions/v1/daily-verses?date=2026-11-06&language=fr&translation=lsg1910&timezone=America/New_York
```

Paramètres :

| Paramètre | Règle |
| --- | --- |
| `date` | Date unique au format `AAAA-MM-JJ`. Incompatible avec `from/to`. Par défaut : date civile du fuseau demandé. |
| `from`, `to` | Plage inclusive obligatoire par paire, limitée à 30 jours. |
| `language` | Code de langue ; `fr` par défaut pour le pilote. |
| `translation` | Code autorisé ; `lsg1910` par défaut pour le pilote. |
| `timezone` | Fuseau IANA utilisé pour déterminer la date civile ; `UTC` par défaut. |

L'API refuse les dates futures selon le fuseau demandé. Elle sélectionne
uniquement les lignes `published` dont `published_at` est atteint. Un résultat
vide est une réponse `200` avec `data: []` ; l'application peut alors afficher
l'état « contenu absent » sans substituer silencieusement un autre jour.

### Réponse

```json
{
  "data": [
    {
      "id": "uuid",
      "date": "2026-11-06",
      "slot": "morning",
      "language_code": "fr",
      "translation_code": "lsg1910",
      "translation_name": "Louis Segond 1910",
      "reference": "Référence validée",
      "text": "Texte biblique validé",
      "reflection": "Méditation approuvée",
      "action": "Action approuvée",
      "prayer": null,
      "attribution": "Attribution validée",
      "status": "published",
      "version": 1,
      "source_bible_id": "identifiant API.Bible",
      "source_passage_id": "identifiant du passage"
    }
  ],
  "meta": {
    "request_id": "uuid",
    "server_time": "2026-11-06T12:00:00.000Z",
    "from": "2026-11-06",
    "to": "2026-11-06",
    "language_code": "fr",
    "translation_code": "lsg1910",
    "timezone": "America/New_York",
    "mode": "day",
    "count": 1
  }
}
```

La réponse possède un `ETag` et un cache public de cinq minutes. Une requête
avec un `If-None-Match` identique reçoit `304`.

## 3. Prévisualisation privée API.Bible

### Requête

```http
POST /functions/v1/api-bible-passage
Content-Type: application/json
Authorization: Bearer <jwt-editeur>
apikey: <cle-publiable-supabase>

{
  "bible_id": "identifiant autorisé dans le compte API.Bible",
  "passage_id": "PSA.100.4"
}
```

Un service interne peut remplacer les deux en-têtes précédents par une clé
secrète Supabase dans `apikey`. Cette clé ne doit jamais être utilisée par le
mobile ou un navigateur.

La fonction appelle uniquement :

```text
https://rest.api.bible/v1/bibles/{bibleId}/passages/{passageId}
```

Le texte est demandé sans notes, titres, numéros de chapitre ou de verset. La
réponse contient le texte brut du fournisseur, sa référence, le copyright, la
date de récupération, l'URL sans secret et l'empreinte SHA-256. Elle utilise
`Cache-Control: private, no-store`.

## 4. Codes d'erreur principaux

| HTTP | Code | Signification |
| --- | --- | --- |
| 400 | `invalid_date`, `invalid_timezone`, `invalid_body` | Paramètres ou corps invalides. |
| 401 | erreur d'authentification Supabase | Identité ou clé serveur absente/invalide. |
| 403 | `editorial_role_required`, `bible_not_allowed` | Rôle ou Bible ID non autorisé. |
| 404 | `future_content_forbidden`, `translation_not_available`, `passage_not_found` | Ressource non publique ou introuvable. |
| 413 | `request_too_large` | Corps supérieur à 2 Kio. |
| 503 | `content_service_unavailable`, `provider_rate_limited` | Dépendance temporairement indisponible. |

Chaque erreur produite par le code applicatif contient un `request_id`, sans
clé, contenu fournisseur brut ni détail interne.
