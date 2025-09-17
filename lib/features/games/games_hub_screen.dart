import 'package:flutter/material.dart';
import 'breathing_screen.dart';
import 'color_drift_screen.dart';
import 'zen_garden_screen.dart';
import '../../utils/feedback_controller.dart';

class GamesHubScreen extends StatelessWidget {
	const GamesHubScreen({super.key});

	void _open(BuildContext context, Widget page) {
		Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
	}

	@override
	Widget build(BuildContext context) {
		final color = Theme.of(context).colorScheme;
		final fb = FeedbackController();
		fb.load();
		return GridView.count(
			padding: const EdgeInsets.all(16),
			crossAxisCount: 2,
			mainAxisSpacing: 12,
			crossAxisSpacing: 12,
			children: [
				_GameCard(
					icon: Icons.palette,
					title: 'Color Drift',
					background: color.secondaryContainer,
					onTap: () { fb.hapticLight(); fb.soundClick(); _open(context, const ColorDriftScreen()); },
				),
				_GameCard(
					icon: Icons.self_improvement,
					title: 'Breathing Circle',
					background: color.tertiaryContainer,
					onTap: () { fb.hapticLight(); fb.soundClick(); _open(context, const BreathingScreen()); },
				),
				_GameCard(
					icon: Icons.yard,
					title: 'Zen Garden',
					background: color.primaryContainer,
					onTap: () { fb.hapticLight(); fb.soundClick(); _open(context, const ZenGardenScreen()); },
				),
			],
		);
	}
}

class _GameCard extends StatelessWidget {
	final IconData icon;
	final String title;
	final Color background;
	final VoidCallback onTap;
	const _GameCard({required this.icon, required this.title, required this.background, required this.onTap});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(16),
			child: Container(
				padding: const EdgeInsets.all(16),
				decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16), boxShadow: [
					BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4)),
				]),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(icon, size: 28),
						const SizedBox(height: 8),
						Text(title, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
					],
				),
			),
		);
	}
}
