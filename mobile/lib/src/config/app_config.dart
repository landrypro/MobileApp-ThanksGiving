enum AppEnvironment {
  development('development'),
  test('test'),
  production('production');

  const AppEnvironment(this.wireName);

  final String wireName;

  static AppEnvironment parse(String value) {
    return AppEnvironment.values.firstWhere(
      (environment) => environment.wireName == value.trim().toLowerCase(),
      orElse: () => throw ArgumentError.value(
        value,
        'APP_ENV',
        'Valeur attendue : development, test ou production.',
      ),
    );
  }
}

/// Configuration publique de l'application mobile.
///
/// Cette classe ne contient volontairement aucune clé API.Bible, clé Supabase
/// secrète ou information d'administration. Les valeurs compilées dans une
/// application mobile doivent toujours être considérées comme publiques.
class AppConfig {
  AppConfig({
    required this.environment,
    required Uri contentApiBaseUrl,
    required this.demoContentEnabled,
  }) : contentApiBaseUrl = _validateApiBaseUrl(
          environment,
          contentApiBaseUrl,
        ) {
    if (environment != AppEnvironment.development && demoContentEnabled) {
      throw ArgumentError(
        'Le contenu de démonstration est interdit hors de development.',
      );
    }
  }

  static const appEnvironmentDefine = 'APP_ENV';
  static const contentApiBaseUrlDefine = 'CONTENT_API_BASE_URL';
  static const demoContentDefine = 'ENABLE_DEMO_CONTENT';

  final AppEnvironment environment;
  final Uri contentApiBaseUrl;
  final bool demoContentEnabled;

  factory AppConfig.fromCompileTimeEnvironment() {
    const environmentValue = String.fromEnvironment(
      appEnvironmentDefine,
      defaultValue: 'development',
    );
    final environment = AppEnvironment.parse(environmentValue);

    const configuredApiUrl = String.fromEnvironment(
      contentApiBaseUrlDefine,
      defaultValue: 'http://10.0.2.2:54321/functions/v1',
    );
    const hasDemoContentDefine = bool.hasEnvironment(demoContentDefine);
    const configuredDemoContent = bool.fromEnvironment(
      demoContentDefine,
      defaultValue: false,
    );

    return AppConfig(
      environment: environment,
      contentApiBaseUrl: Uri.parse(configuredApiUrl),
      demoContentEnabled: hasDemoContentDefine
          ? configuredDemoContent
          : environment == AppEnvironment.development,
    );
  }

  factory AppConfig.development() {
    return AppConfig(
      environment: AppEnvironment.development,
      contentApiBaseUrl: Uri.parse(
        'http://10.0.2.2:54321/functions/v1',
      ),
      demoContentEnabled: true,
    );
  }

  static Uri _validateApiBaseUrl(
    AppEnvironment environment,
    Uri value,
  ) {
    if (!value.hasScheme || value.host.isEmpty) {
      throw ArgumentError.value(
        value,
        contentApiBaseUrlDefine,
        'Une URL absolue est requise.',
      );
    }
    if (value.userInfo.isNotEmpty ||
        value.hasQuery ||
        value.hasFragment ||
        value.host.endsWith('.invalid')) {
      throw ArgumentError.value(
        value,
        contentApiBaseUrlDefine,
        'L’URL ne doit contenir ni identifiants, ni paramètres, ni valeur fictive.',
      );
    }
    if (environment != AppEnvironment.development && value.scheme != 'https') {
      throw ArgumentError.value(
        value,
        contentApiBaseUrlDefine,
        'HTTPS est obligatoire pour test et production.',
      );
    }
    if (value.scheme != 'http' && value.scheme != 'https') {
      throw ArgumentError.value(
        value,
        contentApiBaseUrlDefine,
        'Seuls HTTP et HTTPS sont acceptés.',
      );
    }
    return value;
  }
}
