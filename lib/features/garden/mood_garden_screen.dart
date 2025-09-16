import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../mood/mood_service.dart';
import '../mood/models/mood_entry.dart';

class MoodGardenScreen extends StatelessWidget {
	const MoodGardenScreen({super.key});

	int _stageFromAverage(double avg) {
		if (avg < 3) return 1; // seed
		if (avg < 5) return 2; // sprout
		if (avg < 7) return 3; // small plant
		if (avg < 9) return 4; // budding
		return 5; // bloom
	}

	IconData _iconForStage(int stage) {
		switch (stage) {
			case 1:
				return Icons.spa_outlined; // seed
			case 2:
				return Icons.eco_outlined; // sprout
			case 3:
				return Icons.park_outlined; // plant
			case 4:
				return Icons.local_florist_outlined; // budding
			case 5:
			default:
				return Icons.local_florist; // bloom
		}
	}

	@override
	Widget build(BuildContext context) {
		final service = MoodService();
		return ListView(
			padding: const EdgeInsets.all(16),
			children: [
				Card(
					child: Padding(
						padding: const EdgeInsets.all(20),
						child: StreamBuilder<List<MoodEntry>>(
							stream: service.streamRecent(days: 7),
							builder: (context, snapshot) {
								final entries = snapshot.data ?? const <MoodEntry>[];
								final avg = entries.isEmpty ? 5.0 : entries.map((e) => e.moodScore).reduce((a, b) => a + b) / entries.length;
								final stage = _stageFromAverage(avg);
								final icon = _iconForStage(stage);
								final label = switch (stage) {
									1 => 'Seed',
									2 => 'Sprout',
									3 => 'Growing',
									4 => 'Budding',
									_ => 'Bloom',
								};

								return Column(
									children: [
										Icon(icon, size: 140, color: Theme.of(context).colorScheme.primary)
											.animate(target: stage.toDouble())
											.scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 500.ms)
											.fadeIn(duration: 600.ms),
										const SizedBox(height: 12),
										Text('$label garden • Avg mood ${(avg).toStringAsFixed(1)} / 10', style: Theme.of(context).textTheme.titleMedium),
										const SizedBox(height: 8),
										LinearProgressIndicator(value: (avg / 10).clamp(0.0, 1.0)),
									],
								);
							},
						),
					),
				),
				const SizedBox(height: 16),
				Text('Recent mood', style: Theme.of(context).textTheme.titleMedium),
				SizedBox(
					height: 220,
					child: StreamBuilder<List<MoodEntry>>(
						stream: service.streamRecent(days: 14),
						builder: (context, snapshot) {
							final data = snapshot.data ?? const <MoodEntry>[];
							final spots = data
									.asMap()
									.entries
									.map((e) => FlSpot(e.key.toDouble(), e.value.moodScore.toDouble()))
									.toList();
							return LineChart(LineChartData(
								minY: 1,
								maxY: 10,
								lineBarsData: [
									LineChartBarData(spots: spots, isCurved: true, color: Theme.of(context).colorScheme.tertiary, dotData: const FlDotData(show: false)),
								],
								gridData: const FlGridData(show: true),
								titlesData: const FlTitlesData(show: false),
							));
						},
					),
				),
			],
		);
	}
}
