import 'package:flutter_test/flutter_test.dart';
import 'package:thanksgiving_quote/src/config/app_config.dart';
import 'package:thanksgiving_quote/src/thanks_giving_app.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('affiche les trois rendez-vous quotidiens', (tester) async {
    await tester.pumpWidget(
      ThanksGivingApp(config: AppConfig.development()),
    );

    expect(find.text('Matin'), findsOneWidget);
    expect(find.text('Midi'), findsOneWidget);
    expect(find.text('Soir'), findsOneWidget);
    expect(find.textContaining('VERSET 2 SUR 3'), findsOneWidget);
  });

  testWidgets('permet de garder le verset sélectionné', (tester) async {
    await tester.pumpWidget(
      ThanksGivingApp(config: AppConfig.development()),
    );

    await tester.tap(find.byIcon(Icons.star_outline));
    await tester.pump();

    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
