import 'package:flutter/material.dart';
import 'glow_doodle_screen.dart';
import 'bubble_burst_screen.dart';
import 'smash_walls_screen.dart';
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
		return Center(
			child: SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						_GameCard(
							icon: Icons.bubble_chart,
							title: 'Bubble Burst',
							background: color.secondaryContainer,
							onTap: () { fb.hapticLight(); fb.soundClick(); _open(context, const BubbleBurstScreen()); },
						),
						const SizedBox(width: 24),
						_GameCard(
							icon: Icons.brush,
							title: 'Glow Doodle',
							background: color.tertiaryContainer,
							onTap: () { fb.hapticLight(); fb.soundClick(); _open(context, const GlowDoodleScreen()); },
						),
						const SizedBox(width: 24),
						_GameCard(
							icon: Icons.construction,
							title: 'Smash The Walls',
							background: color.primaryContainer,
							onTap: () { fb.hapticLight(); fb.soundClick(); _open(context, const SmashWallsScreen()); },
						),
						const SizedBox(width: 24),
						_GameCard(
							icon: Icons.grid_view,
							title: 'Calm 2048',
							background: color.surfaceContainerHighest,
							onTap: () { fb.hapticLight(); fb.soundClick(); _open(context, const Calm2048Screen()); },
						),
					],
				),
			),
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
								width: 140,
								height: 120,
								padding: const EdgeInsets.all(16),
								decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16), boxShadow: [
									BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
								]),
								child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Icon(icon, size: 36),
										const SizedBox(height: 8),
										Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
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
