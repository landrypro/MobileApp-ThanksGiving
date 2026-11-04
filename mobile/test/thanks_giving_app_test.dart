import 'package:flutter_test/flutter_test.dart';
import 'package:thanksgiving_quote/src/thanks_giving_app.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('affiche les trois rendez-vous quotidiens', (tester) async {
    await tester.pumpWidget(const ThanksGivingApp());

    expect(find.text('Matin'), findsOneWidget);
    expect(find.text('Midi'), findsOneWidget);
    expect(find.text('Soir'), findsOneWidget);
    expect(find.textContaining('VERSET 2 SUR 3'), findsOneWidget);
  });

  testWidgets('permet de garder le verset sélectionné', (tester) async {
    await tester.pumpWidget(const ThanksGivingApp());

    await tester.tap(find.byIcon(Icons.star_outline));
    await tester.pump();

    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
