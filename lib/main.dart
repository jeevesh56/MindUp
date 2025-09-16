import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	try {
		if (Firebase.apps.isEmpty) {
			await Firebase.initializeApp();
		}
	} catch (_) {
		// Ignore init errors so the app can run without Firebase configured.
	}
	runApp(const StressApp());
}
