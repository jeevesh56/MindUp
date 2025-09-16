import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../mood/mood_service.dart';
import '../mood/models/mood_entry.dart';
import '../streaks/streaks_service.dart';
import '../garden/mood_garden_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../games/games_hub_screen.dart';
import '../forum/forum_screen.dart';
import '../mood/mood_tracker_screen.dart';

class DashboardScreen extends StatelessWidget {
	DashboardScreen({super.key});

	final MoodService _moodService = MoodService();
	final StreaksService _streaksService = StreaksService();

	int _stageFromAverage(double avg) {
		if (avg < 3) return 1; if (avg < 5) return 2; if (avg < 7) return 3; if (avg < 9) return 4; return 5;
	}

	IconData _iconForStage(int stage) {
		switch (stage) {
			case 1: return Icons.spa_outlined; 
			case 2: return Icons.eco_outlined;
			case 3: return Icons.park_outlined;
			case 4: return Icons.local_florist_outlined;
			default: return Icons.local_florist;
		}
	}

	@override
	Widget build(BuildContext context) {
		return ListView(
			padding: const EdgeInsets.all(16),
			children: [
				Text('Welcome back 👋', style: Theme.of(context).textTheme.headlineSmall),
				const SizedBox(height: 12),
				FutureBuilder<int>(
					future: _streaksService.computeCurrentStreak(),
					builder: (context, snap) {
						final streak = snap.data ?? 0;
						return _InfoCard(
							color: Theme.of(context).colorScheme.primaryContainer,
							title: 'Daily Wellness Streak',
							subtitle: '$streak day${streak == 1 ? '' : 's'} strong',
							icon: const Text('🔥', style: TextStyle(fontSize: 28)),
						);
					},
				),
				const SizedBox(height: 12),
				StreamBuilder<List<MoodEntry>>(
					stream: _moodService.streamRecent(days: 14),
					builder: (context, snapshot) {
						final data = snapshot.data ?? const <MoodEntry>[];
						final avg = data.isEmpty ? 5.0 : data.map((e) => e.moodScore).reduce((a,b)=>a+b)/data.length;
						final stage = _stageFromAverage(avg);
						return Row(
							children: [
								Expanded(
									child: _InfoCard(
										title: 'Mood Avg',
										subtitle: '${avg.toStringAsFixed(1)} / 10',
										icon: const Icon(Icons.mood),
									),
								),
								const SizedBox(width: 12),
								Expanded(
									child: _InfoCard(
										title: 'Garden',
										subtitle: ['Seed','Sprout','Growing','Budding','Bloom'][stage-1],
										icon: Icon(_iconForStage(stage)),
									),
								),
							],
						);
					},
				),
				const SizedBox(height: 12),
				Container(
					decoration: BoxDecoration(
						color: Theme.of(context).colorScheme.surface,
						borderRadius: BorderRadius.circular(16),
						border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
					),
					padding: const EdgeInsets.all(12),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									Text('Last 14 days', style: Theme.of(context).textTheme.titleMedium),
									const Spacer(),
									TextButton.icon(onPressed: (){
										Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const MoodTrackerScreen()));
									}, icon: const Icon(Icons.add), label: const Text('Log mood')),
								],
							),
							SizedBox(
								height: 160,
								child: StreamBuilder<List<MoodEntry>>(
									stream: _moodService.streamRecent(days: 14),
									builder: (context, snapshot) {
										final moods = snapshot.data ?? const <MoodEntry>[];
										final spots = moods.asMap().entries.map((e)=>FlSpot(e.key.toDouble(), e.value.moodScore.toDouble())).toList();
										return LineChart(LineChartData(
											minY: 1, maxY: 10,
											lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: Theme.of(context).colorScheme.primary, dotData: const FlDotData(show:false))],
											gridData: const FlGridData(show: true),
											titlesData: const FlTitlesData(show: false),
										));
									},
								),
							),
					],
					),
				),
				const SizedBox(height: 12),
				Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
				const SizedBox(height: 8),
				Wrap(
					spacing: 12,
					runSpacing: 12,
					children: [
						_ActionButton(icon: Icons.smart_toy, label: 'Chatbot', onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const ChatbotScreen()))),
						_ActionButton(icon: Icons.mood, label: 'Mood', onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const MoodTrackerScreen()))),
						_ActionButton(icon: Icons.local_florist, label: 'Garden', onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const MoodGardenScreen()))),
						_ActionButton(icon: Icons.videogame_asset, label: 'Games', onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const GamesHubScreen()))),
						_ActionButton(icon: Icons.forum, label: 'Forum', onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const ForumScreen()))),
					],
				),
			],
		);
	}
}

class _InfoCard extends StatelessWidget {
	final String title;
	final String subtitle;
	final Widget icon;
	final Color? color;
	const _InfoCard({required this.title, required this.subtitle, required this.icon, this.color});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
				borderRadius: BorderRadius.circular(16),
			),
			child: Row(
				children: [
					icon,
					const SizedBox(width: 10),
					Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(title, style: Theme.of(context).textTheme.labelLarge),
							Text(subtitle, style: Theme.of(context).textTheme.titleMedium),
						],
					),
				],
			),
		);
	}
}

class _ActionButton extends StatelessWidget {
	final IconData icon; final String label; final VoidCallback onTap;
	const _ActionButton({required this.icon, required this.label, required this.onTap});
	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(14),
			child: Container(
				width: 160,
				padding: const EdgeInsets.all(12),
				decoration: BoxDecoration(
					color: Theme.of(context).colorScheme.secondaryContainer,
					borderRadius: BorderRadius.circular(14),
				),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [Icon(icon), const SizedBox(width: 8), Text(label)],
				),
			),
		);
	}
}

