import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController {
	static final AppThemeController _instance = AppThemeController._internal();
	factory AppThemeController() => _instance;
	AppThemeController._internal();

	final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
	static const String _prefKey = 'app_theme_mode';

	Future<void> load() async {
		final prefs = await SharedPreferences.getInstance();
		final value = prefs.getString(_prefKey);
		switch (value) {
			case 'light':
				themeMode.value = ThemeMode.light;
				break;
			case 'dark':
				themeMode.value = ThemeMode.dark;
				break;
			default:
				themeMode.value = ThemeMode.light;
		}
	}

	Future<void> setThemeMode(ThemeMode mode) async {
		themeMode.value = mode;
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString(_prefKey, switch (mode) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', _ => 'system' });
	}

	Future<void> toggleTheme() async {
		final newMode = themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
		await setThemeMode(newMode);
	}
}



