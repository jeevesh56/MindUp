import 'package:flutter/material.dart';
import 'breathing_screen.dart';
import 'color_drift_screen.dart';
import 'zen_garden_screen.dart';
import 'game_2048_screen.dart';
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
			mainAxisSpacing: 6,
			crossAxisSpacing: 6,
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
				_GameCard(
					icon: Icons.grid_view,
					title: 'Calm 2048',
					background: color.surfaceContainerHighest,
					onTap: () { fb.hapticLight(); fb.soundClick(); _open(context, const Calm2048Screen()); },
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
		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(16),
				child: TweenAnimationBuilder<double>(
					duration: const Duration(milliseconds: 320),
					tween: Tween(begin: 0.9, end: 1.0),
					curve: Curves.easeOutBack,
					builder: (context, scale, _) {
						return Transform.scale(
							scale: scale,
							child: Container(
								height: 78,
								padding: const EdgeInsets.all(10),
								decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14), boxShadow: [
									BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
								]),
								child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Icon(icon, size: 20),
										const SizedBox(height: 4),
										Text(title, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
									],
								),
							),
						);
					},
				),
			),
		);
	}
}
