import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models/daily_verse.dart';
import 'repositories/daily_verse_repository.dart';

class ThanksGivingApp extends StatelessWidget {
  const ThanksGivingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThanksGiving Quote',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(repository: DemoDailyVerseRepository()),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.repository, super.key});

  final DailyVerseRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<DailyVerse> _verses;
  var _selectedSlot = DailySlot.midday;
  var _tabIndex = 0;
  var _language = 'Français · FR';
  final Set<DailySlot> _favorites = <DailySlot>{};
  final Map<DailySlot, bool> _reminders = <DailySlot, bool>{
    DailySlot.morning: true,
    DailySlot.midday: true,
    DailySlot.evening: false,
  };

  @override
  void initState() {
    super.initState();
    _verses = widget.repository.versesForToday();
  }

  DailyVerse get _currentVerse => _verses.firstWhere((verse) => verse.slot == _selectedSlot);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _TodayPage(
        verse: _currentVerse,
        selectedSlot: _selectedSlot,
        isFavorite: _favorites.contains(_selectedSlot),
        onSlotSelected: _selectSlot,
        onFavorite: _toggleFavorite,
        onShare: _shareVerse,
      ),
      _HistoryPage(onSelectVerse: _selectSlot),
      _FavoritesPage(
        verses: _verses.where((verse) => _favorites.contains(verse.slot)).toList(),
        onSelectVerse: _selectSlot,
      ),
      _SettingsPage(
        language: _language,
        reminders: _reminders,
        onLanguageChanged: (value) => setState(() => _language = value),
        onReminderChanged: (slot, enabled) => setState(() => _reminders[slot] = enabled),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const _BrandTitle(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              label: Text(_language.split(' · ').last),
              onPressed: () => setState(() => _tabIndex = 3),
            ),
          ),
        ],
      ),
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (value) => setState(() => _tabIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Aujourd’hui'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Historique'),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: 'Favoris'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Réglages'),
        ],
      ),
    );
  }

  void _selectSlot(DailySlot slot) {
    setState(() {
      _selectedSlot = slot;
      _tabIndex = 0;
    });
  }

  void _toggleFavorite() {
    setState(() {
      if (_favorites.contains(_selectedSlot)) {
        _favorites.remove(_selectedSlot);
      } else {
        _favorites.add(_selectedSlot);
      }
    });
  }

  void _shareVerse() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Le partage natif sera activé après la validation des règles d’usage.')),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _BrandMark(),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ThanksGiving Quote', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text('Rendre Grâce à DIEU chaque jour', style: TextStyle(fontSize: 10, color: AppColors.muted)),
          ],
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.cyanDeep, shape: BoxShape.circle),
      child: const Text('+', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w700)),
    );
  }
}

class _TodayPage extends StatelessWidget {
  const _TodayPage({
    required this.verse,
    required this.selectedSlot,
    required this.isFavorite,
    required this.onSlotSelected,
    required this.onFavorite,
    required this.onShare,
  });

  final DailyVerse verse;
  final DailySlot selectedSlot;
  final bool isFavorite;
  final ValueChanged<DailySlot> onSlotSelected;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      children: [
        Text('Bonjour, Grâce', style: textTheme.headlineSmall?.copyWith(color: AppColors.navy, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Trois instants pour reconnaître la bonté de DIEU.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 18),
        const _RhythmHeader(),
        const SizedBox(height: 10),
        Row(
          children: DailySlot.values.map((slot) {
            final selected = slot == selectedSlot;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: slot == DailySlot.evening ? 0 : 8),
                child: _SlotButton(slot: slot, selected: selected, onPressed: () => onSlotSelected(slot)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _VerseCard(verse: verse),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: onFavorite,
              tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
              icon: Icon(isFavorite ? Icons.star : Icons.star_outline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.ios_share),
                label: const Text('Partager le verset'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('À méditer', style: textTheme.titleMedium?.copyWith(color: AppColors.navy, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(verse.reflection, style: const TextStyle(height: 1.45)),
          ),
        ),
      ],
    );
  }
}

class _RhythmHeader extends StatelessWidget {
  const _RhythmHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Vos 3 rendez-vous de grâce', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
        Text('Chaque jour', style: TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({required this.slot, required this.selected, required this.onPressed});

  final DailySlot slot;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.limePale : Colors.white,
          border: Border.all(color: selected ? AppColors.limePale : AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(slot.icon, color: selected ? AppColors.navy : AppColors.cyanDeep, size: 19),
            const SizedBox(height: 4),
            Text(slot.label, style: TextStyle(color: selected ? AppColors.navy : AppColors.ink, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 2),
            Text(slot.availableAt, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({required this.verse});

  final DailyVerse verse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cyanDeep,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${verse.slot.label.toUpperCase()} · VERSET ${verse.slot.index + 1} SUR 3', style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: .5)),
          const SizedBox(height: 20),
          Text('“${verse.text}”', style: const TextStyle(color: Colors.white, fontSize: 23, height: 1.35, fontWeight: FontWeight.w600)),
          const SizedBox(height: 22),
          Text(verse.reference.toUpperCase(), style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Text(verse.translation, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(verse.attribution, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

class _HistoryPage extends StatelessWidget {
  const _HistoryPage({required this.onSelectVerse});

  final ValueChanged<DailySlot> onSelectVerse;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Votre parcours', style: TextStyle(color: AppColors.navy, fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        const Text('Un fil de reconnaissance, jour après jour.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 20),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Historique hors-ligne', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Les lectures terminées seront conservées sur cet appareil et synchronisées lorsque la connexion sera disponible.'),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Les rendez-vous du jour', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...DailySlot.values.map((slot) => Card(
          child: ListTile(
            leading: Icon(slot.icon, color: AppColors.cyanDeep),
            title: Text(slot.label),
            subtitle: Text('Disponible à ${slot.availableAt}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onSelectVerse(slot),
          ),
        )),
      ],
    );
  }
}

class _FavoritesPage extends StatelessWidget {
  const _FavoritesPage({required this.verses, required this.onSelectVerse});

  final List<DailyVerse> verses;
  final ValueChanged<DailySlot> onSelectVerse;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Vos favoris', style: TextStyle(color: AppColors.navy, fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        const Text('Gardez les paroles qui vous accompagnent.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 20),
        if (verses.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Aucun verset gardé pour le moment. Touchez l’étoile sur un verset pour le retrouver ici.'),
            ),
          )
        else
          ...verses.map((verse) => Card(
            child: ListTile(
              title: Text(verse.reference, style: const TextStyle(color: AppColors.cyanDeep, fontWeight: FontWeight.w700)),
              subtitle: Text(verse.slot.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelectVerse(verse.slot),
            ),
          )),
      ],
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.language,
    required this.reminders,
    required this.onLanguageChanged,
    required this.onReminderChanged,
  });

  final String language;
  final Map<DailySlot, bool> reminders;
  final ValueChanged<String> onLanguageChanged;
  final void Function(DailySlot slot, bool enabled) onReminderChanged;

  @override
  Widget build(BuildContext context) {
    const languages = <String>['Français · FR', 'English · EN', 'Español · ES', 'Português · PT', 'Deutsch · DE', 'Italiano · IT', 'العربية · AR', 'Kiswahili · SW'];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Réglages', style: TextStyle(color: AppColors.navy, fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        const Text('Personnalisez votre temps de méditation.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 20),
        const _SectionLabel('Langue de l’application'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: languages.map((item) => ChoiceChip(
            label: Text(item.split(' · ').last),
            selected: item == language,
            onSelected: (_) => onLanguageChanged(item),
          )).toList(),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Rappels des 3 rendez-vous'),
        Card(
          child: Column(
            children: DailySlot.values.map((slot) => SwitchListTile(
              title: Text(slot.label),
              subtitle: Text('Rappel à ${slot.defaultReminder}'),
              value: reminders[slot] ?? false,
              onChanged: (enabled) => onReminderChanged(slot, enabled),
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Accès hors connexion'),
        const Card(
          child: ListTile(
            leading: Icon(Icons.offline_pin_outlined, color: AppColors.cyanDeep),
            title: Text('Préparation du cache local'),
            subtitle: Text('Les derniers contenus validés seront accessibles sans connexion.'),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
    );
  }
}
