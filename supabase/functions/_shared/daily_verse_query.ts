const ISO_DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;
const LANGUAGE_PATTERN = /^[a-z]{2,3}(?:-[A-Z]{2})?$/;
const TRANSLATION_PATTERN = /^[a-z0-9][a-z0-9_-]{1,49}$/;
const MAX_HISTORY_DAYS = 30;

export interface DailyVerseReadQuery {
  readonly from: string;
  readonly to: string;
  readonly languageCode: string;
  readonly translationCode: string;
  readonly timeZone: string;
  readonly mode: "day" | "history";
}

export class ReadQueryError extends Error {
  constructor(
    readonly code: string,
    message: string,
    readonly status: number,
  ) {
    super(message);
    this.name = "ReadQueryError";
  }
}

export function parseDailyVerseReadQuery(
  requestUrl: string,
  now: Date = new Date(),
  allowedTranslations = readAllowedTranslations(),
): DailyVerseReadQuery {
  const url = new URL(requestUrl);
  const timeZone = readTimeZone(url.searchParams.get("timezone") ?? "UTC");
  const today = dateInTimeZone(now, timeZone);
  const languageCode = url.searchParams.get("language") ?? "fr";
  const requestedTranslation = url.searchParams.get("translation");

  if (!LANGUAGE_PATTERN.test(languageCode)) {
    throw new ReadQueryError(
      "invalid_language",
      "Le paramètre language est invalide.",
      400,
    );
  }

  const translationCode = requestedTranslation ??
    defaultTranslationFor(languageCode, allowedTranslations);
  if (!translationCode || !TRANSLATION_PATTERN.test(translationCode)) {
    throw new ReadQueryError(
      "translation_not_available",
      "Cette traduction n'est pas disponible.",
      404,
    );
  }

  if (!allowedTranslations.has(`${languageCode}:${translationCode}`)) {
    throw new ReadQueryError(
      "translation_not_available",
      "Cette traduction n'est pas disponible.",
      404,
    );
  }

  const date = url.searchParams.get("date");
  const from = url.searchParams.get("from");
  const to = url.searchParams.get("to");
  if (date && (from || to)) {
    throw new ReadQueryError(
      "conflicting_dates",
      "Utilisez date ou le couple from/to, pas les deux.",
      400,
    );
  }
  if ((from && !to) || (!from && to)) {
    throw new ReadQueryError(
      "incomplete_range",
      "Les paramètres from et to sont tous les deux obligatoires.",
      400,
    );
  }

  const mode = from && to ? "history" : "day";
  const parsedFrom = parseIsoDate(from ?? date ?? today, "from/date");
  const parsedTo = parseIsoDate(to ?? date ?? today, "to/date");

  if (parsedFrom.valueOf() > parsedTo.valueOf()) {
    throw new ReadQueryError(
      "invalid_range",
      "La date de début doit précéder la date de fin.",
      400,
    );
  }
  if (inclusiveDayCount(parsedFrom, parsedTo) > MAX_HISTORY_DAYS) {
    throw new ReadQueryError(
      "range_too_large",
      `Une requête ne peut pas dépasser ${MAX_HISTORY_DAYS} jours.`,
      400,
    );
  }
  if (formatIsoDate(parsedTo) > today) {
    throw new ReadQueryError(
      "future_content_forbidden",
      "Les contenus futurs ne sont pas accessibles.",
      404,
    );
  }

  return Object.freeze({
    from: formatIsoDate(parsedFrom),
    to: formatIsoDate(parsedTo),
    languageCode,
    translationCode,
    timeZone,
    mode,
  });
}

export function readAllowedTranslations(
  rawValue = Deno.env.get("CONTENT_ALLOWED_TRANSLATIONS") ?? "fr:jnd",
): ReadonlySet<string> {
  const entries = rawValue
    .split(",")
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
  const allowed = new Set<string>();

  for (const entry of entries) {
    const separator = entry.indexOf(":");
    const languageCode = entry.slice(0, separator);
    const translationCode = entry.slice(separator + 1);
    if (
      separator < 1 || !LANGUAGE_PATTERN.test(languageCode) ||
      !TRANSLATION_PATTERN.test(translationCode)
    ) {
      throw new Error(
        "CONTENT_ALLOWED_TRANSLATIONS doit utiliser le format langue:traduction.",
      );
    }
    allowed.add(`${languageCode}:${translationCode}`);
  }

  if (allowed.size === 0) {
    throw new Error("CONTENT_ALLOWED_TRANSLATIONS ne peut pas être vide.");
  }
  return allowed;
}

function readTimeZone(value: string): string {
  if (value.length > 64) {
    throw new ReadQueryError(
      "invalid_timezone",
      "Le paramètre timezone est invalide.",
      400,
    );
  }
  try {
    new Intl.DateTimeFormat("fr-CA", { timeZone: value }).format(new Date());
  } catch {
    throw new ReadQueryError(
      "invalid_timezone",
      "Le paramètre timezone est invalide.",
      400,
    );
  }
  return value;
}

function defaultTranslationFor(
  languageCode: string,
  allowedTranslations: ReadonlySet<string>,
): string | undefined {
  const prefix = `${languageCode}:`;
  for (const pair of allowedTranslations) {
    if (pair.startsWith(prefix)) {
      return pair.slice(prefix.length);
    }
  }
  return undefined;
}

function parseIsoDate(value: string, parameterName: string): Date {
  if (!ISO_DATE_PATTERN.test(value)) {
    throw new ReadQueryError(
      "invalid_date",
      `Le paramètre ${parameterName} doit utiliser le format AAAA-MM-JJ.`,
      400,
    );
  }
  const parsed = new Date(`${value}T00:00:00.000Z`);
  if (Number.isNaN(parsed.valueOf()) || formatIsoDate(parsed) !== value) {
    throw new ReadQueryError(
      "invalid_date",
      `Le paramètre ${parameterName} contient une date invalide.`,
      400,
    );
  }
  return parsed;
}

function dateInTimeZone(value: Date, timeZone: string): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(value);
  const part = (type: Intl.DateTimeFormatPartTypes) =>
    parts.find((item) => item.type === type)?.value ?? "";
  return `${part("year")}-${part("month")}-${part("day")}`;
}

function inclusiveDayCount(from: Date, to: Date): number {
  return Math.floor((to.valueOf() - from.valueOf()) / 86_400_000) + 1;
}

function formatIsoDate(value: Date): string {
  return value.toISOString().slice(0, 10);
}
