import 'package:flutter/material.dart';

enum DailySlot {
  morning('Matin', '05 h', '08:00', Icons.wb_sunny_outlined),
  midday('Midi', '12 h', '12:00', Icons.wb_twilight_outlined),
  evening('Soir', '18 h', '20:00', Icons.nights_stay_outlined);

  const DailySlot(this.label, this.availableAt, this.defaultReminder, this.icon);

  final String label;
  final String availableAt;
  final String defaultReminder;
  final IconData icon;
}

class DailyVerse {
  const DailyVerse({
    required this.slot,
    required this.reference,
    required this.text,
    required this.reflection,
    required this.translation,
    required this.attribution,
  });

  final DailySlot slot;
  final String reference;
  final String text;
  final String reflection;
  final String translation;
  final String attribution;
}
