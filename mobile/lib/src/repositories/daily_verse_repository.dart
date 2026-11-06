import '../models/daily_verse.dart';

abstract interface class DailyVerseRepository {
  List<DailyVerse> versesForDay({
    required CalendarDate date,
    required String languageCode,
  });
}

/// Données provisoires limitées à l'environnement de développement.
///
/// L'implémentation distante M1-07 remplacera cette classe lorsque l'API
/// sécurisée de ThanksGiving Quote sera disponible.
class DemoDailyVerseRepository implements DailyVerseRepository {
  const DemoDailyVerseRepository();

  @override
  List<DailyVerse> versesForDay({
    required CalendarDate date,
    required String languageCode,
  }) {
    if (languageCode != 'fr') {
      throw ArgumentError.value(
        languageCode,
        'languageCode',
        'Le jeu de démonstration du pilote est uniquement en français.',
      );
    }

    return [
      _demoVerse(
        date: date,
        slot: DailySlot.morning,
        reference: 'Psaume 92:2',
        text: 'Le verset du matin sera fourni par la source biblique validée.',
        reflection:
            'Commencez la journée en nommant une grâce déjà présente dans votre vie.',
        action: 'Notez une raison de remercier DIEU ce matin.',
      ),
      _demoVerse(
        date: date,
        slot: DailySlot.midday,
        reference: 'Psaume 100:4',
        text: 'Le verset de midi sera fourni par la source biblique validée.',
        reflection:
            'Faites une pause pour reconnaître la bonté de DIEU au cœur de votre journée.',
        action: 'Exprimez maintenant une reconnaissance précise à DIEU.',
      ),
      _demoVerse(
        date: date,
        slot: DailySlot.evening,
        reference: '1 Thessaloniciens 5:18',
        text: 'Le verset du soir sera fourni par la source biblique validée.',
        reflection:
            'Relisez votre journée avec DIEU et rendez grâce pour ce qui a été vécu.',
        action: 'Terminez la journée en citant trois sujets de reconnaissance.',
      ),
    ];
  }

  DailyVerse _demoVerse({
    required CalendarDate date,
    required DailySlot slot,
    required String reference,
    required String text,
    required String reflection,
    required String action,
  }) {
    return DailyVerse(
      id: 'demo-${date.iso8601}-${slot.wireName}-fr-jnd-v1',
      date: date,
      slot: slot,
      languageCode: 'fr',
      translationCode: 'jnd',
      translationName: 'Bible J.N. Darby',
      reference: reference,
      text: text,
      reflection: reflection,
      action: action,
      attribution: 'Contenu de démonstration — source à connecter',
      status: EditorialStatus.published,
      version: 1,
    );
  }
}
