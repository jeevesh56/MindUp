import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackController {
	static final FeedbackController _instance = FeedbackController._internal();
	factory FeedbackController() => _instance;
	FeedbackController._internal();

	static const String _prefHaptics = 'pref_haptics_enabled';
	static const String _prefSound = 'pref_sound_enabled';

	final ValueNotifier<bool> hapticsEnabled = ValueNotifier<bool>(true);
	final ValueNotifier<bool> soundEnabled = ValueNotifier<bool>(true);
	final ValueNotifier<bool?> soundOverride = ValueNotifier<bool?>(null); // null => use persisted setting

	Future<void> load() async {
		final prefs = await SharedPreferences.getInstance();
		hapticsEnabled.value = prefs.getBool(_prefHaptics) ?? true;
		soundEnabled.value = prefs.getBool(_prefSound) ?? true;
	}

	Future<void> setHaptics(bool enabled) async {
		hapticsEnabled.value = enabled;
		final prefs = await SharedPreferences.getInstance();
		await prefs.setBool(_prefHaptics, enabled);
	}

	Future<void> setSound(bool enabled) async {
		soundEnabled.value = enabled;
		final prefs = await SharedPreferences.getInstance();
		await prefs.setBool(_prefSound, enabled);
	}

	Future<void> hapticLight() async {
		if (!hapticsEnabled.value) return;
		await HapticFeedback.lightImpact();
	}

	Future<void> hapticMedium() async {
		if (!hapticsEnabled.value) return;
		await HapticFeedback.mediumImpact();
	}

	Future<void> soundClick() async {
		final enabled = soundOverride.value ?? soundEnabled.value;
		if (!enabled) return;
		// Lightweight system click usable across platforms without bundling assets.
		await SystemSound.play(SystemSoundType.click);
	}

	void setSoundOverride(bool? enabled) {
		soundOverride.value = enabled; // set false to mute, true to force on, null to follow preference
	}
}


