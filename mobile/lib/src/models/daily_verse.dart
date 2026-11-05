enum DailySlot {
  morning('morning'),
  midday('midday'),
  evening('evening');

  const DailySlot(this.wireName);

  final String wireName;

  static DailySlot fromWireName(String value) {
    return DailySlot.values.firstWhere(
      (slot) => slot.wireName == value,
      orElse: () => throw FormatException('Créneau quotidien inconnu : $value'),
    );
  }
}

enum EditorialStatus {
  draft('draft'),
  biblicalReview('biblical_review'),
  linguisticReview('linguistic_review'),
  approved('approved'),
  scheduled('scheduled'),
  published('published'),
  withdrawn('withdrawn');

  const EditorialStatus(this.wireName);

  final String wireName;

  static EditorialStatus fromWireName(String value) {
    return EditorialStatus.values.firstWhere(
      (status) => status.wireName == value,
      orElse: () => throw FormatException('Statut éditorial inconnu : $value'),
    );
  }
}

/// Date calendaire sans heure ni fuseau, utilisée comme clé éditoriale.
class CalendarDate {
  CalendarDate(this.year, this.month, this.day) {
    final parsed = DateTime.utc(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      throw ArgumentError.value(iso8601, 'date', 'Date calendaire invalide.');
    }
  }

  factory CalendarDate.fromDateTime(DateTime value) {
    return CalendarDate(value.year, value.month, value.day);
  }

  factory CalendarDate.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Date attendue au format AAAA-MM-JJ : $value');
    }
    return CalendarDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final int year;
  final int month;
  final int day;

  String get iso8601 =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) {
    return other is CalendarDate &&
        year == other.year &&
        month == other.month &&
        day == other.day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso8601;
}

/// Révision éditoriale d'un contenu quotidien.
///
/// La clé fonctionnelle est : date + créneau + langue + traduction + version.
class DailyVerse {
  DailyVerse({
    required this.id,
    required this.date,
    required this.slot,
    required this.languageCode,
    required this.translationCode,
    required this.translationName,
    required this.reference,
    required this.text,
    required this.reflection,
    required this.action,
    required this.attribution,
    required this.status,
    required this.version,
    this.prayer,
    this.sourceBibleId,
    this.sourcePassageId,
  }) {
    _requireNonBlank(id, 'id');
    _requireLanguageCode(languageCode);
    _requireNonBlank(translationCode, 'translationCode');
    _requireNonBlank(translationName, 'translationName');
    _requireNonBlank(reference, 'reference');
    _requireNonBlank(text, 'text');
    _requireNonBlank(reflection, 'reflection');
    _requireNonBlank(action, 'action');
    _requireNonBlank(attribution, 'attribution');
    if (version < 1) {
      throw ArgumentError.value(
          version, 'version', 'La version doit être positive.');
    }
    if (prayer != null && prayer!.trim().isEmpty) {
      throw ArgumentError.value(
          prayer, 'prayer', 'Utiliser null pour une prière absente.');
    }
  }

  final String id;
  final CalendarDate date;
  final DailySlot slot;
  final String languageCode;
  final String translationCode;
  final String translationName;
  final String reference;
  final String text;
  final String reflection;
  final String action;
  final String? prayer;
  final String attribution;
  final EditorialStatus status;
  final int version;
  final String? sourceBibleId;
  final String? sourcePassageId;

  String get stableKey =>
      '${date.iso8601}|${slot.wireName}|$languageCode|$translationCode';

  String get revisionKey => '$stableKey|v$version';

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'date': date.iso8601,
      'slot': slot.wireName,
      'language_code': languageCode,
      'translation_code': translationCode,
      'translation_name': translationName,
      'reference': reference,
      'text': text,
      'reflection': reflection,
      'action': action,
      'prayer': prayer,
      'attribution': attribution,
      'status': status.wireName,
      'version': version,
      'source_bible_id': sourceBibleId,
      'source_passage_id': sourcePassageId,
    };
  }

  factory DailyVerse.fromJson(Map<String, Object?> json) {
    final prayer = json['prayer'];
    final sourceBibleId = json['source_bible_id'];
    final sourcePassageId = json['source_passage_id'];

    return DailyVerse(
      id: _readString(json, 'id'),
      date: CalendarDate.parse(_readString(json, 'date')),
      slot: DailySlot.fromWireName(_readString(json, 'slot')),
      languageCode: _readString(json, 'language_code'),
      translationCode: _readString(json, 'translation_code'),
      translationName: _readString(json, 'translation_name'),
      reference: _readString(json, 'reference'),
      text: _readString(json, 'text'),
      reflection: _readString(json, 'reflection'),
      action: _readString(json, 'action'),
      prayer: _readOptionalString(prayer, 'prayer'),
      attribution: _readString(json, 'attribution'),
      status: EditorialStatus.fromWireName(_readString(json, 'status')),
      version: _readInt(json, 'version'),
      sourceBibleId: _readOptionalString(sourceBibleId, 'source_bible_id'),
      sourcePassageId:
          _readOptionalString(sourcePassageId, 'source_passage_id'),
    );
  }
}

void _requireNonBlank(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'La valeur est obligatoire.');
  }
}

void _requireLanguageCode(String value) {
  if (!RegExp(r'^[a-z]{2,3}(?:-[A-Z]{2})?$').hasMatch(value)) {
    throw ArgumentError.value(
      value,
      'languageCode',
      'Code attendu : fr, en, pt-BR, etc.',
    );
  }
}

String _readString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Le champ $key doit être une chaîne.');
  }
  return value;
}

String? _readOptionalString(Object? value, String key) {
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw FormatException('Le champ $key doit être une chaîne ou null.');
  }
  return value;
}

int _readInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('Le champ $key doit être un entier.');
  }
  return value;
}
