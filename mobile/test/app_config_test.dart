import 'package:flutter_test/flutter_test.dart';
import 'package:thanksgiving_quote/src/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('autorise HTTP local et les données de démonstration en développement',
        () {
      final config = AppConfig(
        environment: AppEnvironment.development,
        contentApiBaseUrl: Uri.parse('http://10.0.2.2:54321/functions/v1'),
        demoContentEnabled: true,
      );

      expect(config.environment, AppEnvironment.development);
      expect(config.demoContentEnabled, isTrue);
    });

    test('exige HTTPS dans l’environnement de test', () {
      expect(
        () => AppConfig(
          environment: AppEnvironment.test,
          contentApiBaseUrl: Uri.parse('http://api.test.example/functions/v1'),
          demoContentEnabled: false,
        ),
        throwsArgumentError,
      );
    });

    test('interdit le contenu de démonstration en production', () {
      expect(
        () => AppConfig(
          environment: AppEnvironment.production,
          contentApiBaseUrl: Uri.parse('https://api.example/functions/v1'),
          demoContentEnabled: true,
        ),
        throwsArgumentError,
      );
    });

    test('accepte une URL HTTPS publique sans secret en production', () {
      final config = AppConfig(
        environment: AppEnvironment.production,
        contentApiBaseUrl: Uri.parse('https://api.example/functions/v1'),
        demoContentEnabled: false,
      );

      expect(config.contentApiBaseUrl.scheme, 'https');
      expect(config.demoContentEnabled, isFalse);
    });
  });
}
