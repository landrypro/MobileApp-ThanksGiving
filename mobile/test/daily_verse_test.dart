import 'package:flutter_test/flutter_test.dart';
import 'package:thanksgiving_quote/src/models/daily_verse.dart';

void main() {
  group('DailyVerse', () {
    test('conserve le contrat date, créneau, langue, traduction et version',
        () {
      final verse = _verse();
      final decoded = DailyVerse.fromJson(verse.toJson());

      expect(decoded.date, CalendarDate(2026, 11, 4));
      expect(decoded.slot, DailySlot.midday);
      expect(decoded.languageCode, 'fr');
      expect(decoded.translationCode, 'lsg1910');
      expect(decoded.status, EditorialStatus.approved);
      expect(decoded.version, 2);
      expect(decoded.action, 'Remercier DIEU pour une grâce précise.');
      expect(
        decoded.revisionKey,
        '2026-11-04|midday|fr|lsg1910|v2',
      );
    });

    test('refuse une version non positive', () {
      expect(() => _verse(version: 0), throwsArgumentError);
    });

    test('refuse un code langue non normalisé', () {
      expect(() => _verse(languageCode: 'FR_fr'), throwsArgumentError);
    });

    test('refuse une date calendaire impossible', () {
      expect(() => CalendarDate(2026, 2, 30), throwsArgumentError);
    });
  });
}

DailyVerse _verse({
  int version = 2,
  String languageCode = 'fr',
}) {
  return DailyVerse(
    id: 'content-123',
    date: CalendarDate(2026, 11, 4),
    slot: DailySlot.midday,
    languageCode: languageCode,
    translationCode: 'lsg1910',
    translationName: 'Louis Segond 1910',
    reference: 'Psaume 100:4',
    text: 'Texte biblique validé.',
    reflection: 'Reconnaître la bonté de DIEU.',
    action: 'Remercier DIEU pour une grâce précise.',
    prayer: null,
    attribution: 'Louis Segond 1910',
    status: EditorialStatus.approved,
    version: version,
    sourceBibleId: 'source-bible-id',
    sourcePassageId: 'source-passage-id',
  );
}
