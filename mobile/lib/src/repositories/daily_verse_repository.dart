import '../models/daily_verse.dart';

abstract interface class DailyVerseRepository {
  List<DailyVerse> versesForToday();
}

/// Données provisoires uniquement. L'implémentation distante remplacera cette
/// classe lorsque l'API sécurisée de ThanksGiving Quote sera disponible.
class DemoDailyVerseRepository implements DailyVerseRepository {
  const DemoDailyVerseRepository();

  @override
  List<DailyVerse> versesForToday() {
    return const [
      DailyVerse(
        slot: DailySlot.morning,
        reference: 'Psaume 92:2',
        text: 'Le verset du matin sera fourni par la source biblique validée.',
        reflection: 'Commencez la journée en nommant une grâce déjà présente dans votre vie.',
        translation: 'Louis Segond 1910',
        attribution: 'Contenu de démonstration — source à connecter',
      ),
      DailyVerse(
        slot: DailySlot.midday,
        reference: 'Psaume 100:4',
        text: 'Le verset de midi sera fourni par la source biblique validée.',
        reflection: 'Faites une pause pour reconnaître la bonté de DIEU au cœur de votre journée.',
        translation: 'Louis Segond 1910',
        attribution: 'Contenu de démonstration — source à connecter',
      ),
      DailyVerse(
        slot: DailySlot.evening,
        reference: '1 Thessaloniciens 5:18',
        text: 'Le verset du soir sera fourni par la source biblique validée.',
        reflection: 'Relisez votre journée avec DIEU et rendez grâce pour ce qui a été vécu.',
        translation: 'Louis Segond 1910',
        attribution: 'Contenu de démonstration — source à connecter',
      ),
    ];
  }
}
