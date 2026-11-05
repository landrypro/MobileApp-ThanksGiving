import 'package:flutter/material.dart';

import 'src/config/app_config.dart';
import 'src/thanks_giving_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromCompileTimeEnvironment();
  runApp(ThanksGivingApp(config: config));
}
