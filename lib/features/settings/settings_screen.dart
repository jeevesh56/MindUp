import 'package:flutter/material.dart';
import '../../utils/theme_controller.dart';
import '../../utils/feedback_controller.dart';

class SettingsScreen extends StatelessWidget {
	final AppThemeController controller;
	const SettingsScreen({super.key, required this.controller});

	@override
	Widget build(BuildContext context) {
		final feedback = FeedbackController();
		feedback.load();
		return Scaffold(
			appBar: AppBar(title: const Text('Settings')),
			body: ListView(
				children: [
					const _SectionHeader('Appearance'),
					ValueListenableBuilder<ThemeMode>(
						valueListenable: controller.themeMode,
						builder: (context, mode, _) {
							return Column(
								children: [
									RadioListTile<ThemeMode>(title: const Text('System'), value: ThemeMode.system, groupValue: mode, onChanged: (v) => controller.setThemeMode(v ?? ThemeMode.system)),
									RadioListTile<ThemeMode>(title: const Text('Light'), value: ThemeMode.light, groupValue: mode, onChanged: (v) => controller.setThemeMode(v ?? ThemeMode.system)),
									RadioListTile<ThemeMode>(title: const Text('Dark'), value: ThemeMode.dark, groupValue: mode, onChanged: (v) => controller.setThemeMode(v ?? ThemeMode.system)),
								],
							);
						},
					),
					const Divider(height: 24),
					const _SectionHeader('Feedback'),
					ValueListenableBuilder<bool>(
						valueListenable: feedback.hapticsEnabled,
						builder: (context, enabled, _) => SwitchListTile(
							title: const Text('Haptics'),
							subtitle: const Text('Vibration effects in games and UI'),
							value: enabled,
							onChanged: (v) => feedback.setHaptics(v),
						),
					),
					ValueListenableBuilder<bool>(
						valueListenable: feedback.soundEnabled,
						builder: (context, enabled, _) => SwitchListTile(
							title: const Text('Sound'),
							subtitle: const Text('Subtle clicks and cues (no music)'),
							value: enabled,
							onChanged: (v) => feedback.setSound(v),
						),
					),
					const Divider(height: 24),
					const _SectionHeader('Privacy'),
					SwitchListTile(
						title: const Text('Use anonymous mode'),
						value: true,
						onChanged: (_) {},
						subtitle: const Text('No personally identifiable data is stored.'),
					),
					ListTile(
						title: const Text('Export my data'),
						leading: const Icon(Icons.download),
						onTap: () {},
					),
					const Divider(height: 24),
					const _SectionHeader('Reminders'),
					SwitchListTile(
						title: const Text('Daily mood reminder'),
						value: false,
						onChanged: (_) {},
					),
				],
			),
		);
	}
}

class _SectionHeader extends StatelessWidget {
	final String text;
	const _SectionHeader(this.text);
	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
			child: Text(text, style: Theme.of(context).textTheme.titleSmall),
		);
	}
}


