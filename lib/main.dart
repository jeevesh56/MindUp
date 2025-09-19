import 'package:flutter/material.dart';
import 'app.dart';
import 'utils/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved theme mode before launching the app
  await AppThemeController().load();
  runApp(const StressApp());
}
