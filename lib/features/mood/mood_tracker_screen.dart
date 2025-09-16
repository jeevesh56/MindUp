import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../streaks/streaks_service.dart';
import 'mood_service.dart';
import 'models/mood_entry.dart';

class MoodTrackerScreen extends StatefulWidget {
	const MoodTrackerScreen({super.key});

	@override
	State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
	double _score = 5;
	final TextEditingController _noteController = TextEditingController();
	final MoodService _service = MoodService();
	final StreaksService _streaks = StreaksService();
	int? _streak;
	List<String> _rewards = const <String>[];

	@override
	void initState() {
		super.initState();
		_refreshStreaks();
	}

	Future<void> _refreshStreaks() async {
		final s = await _streaks.computeCurrentStreak();
		final r = _streaks.unlockedRewardsForStreak(s);
		await _streaks.saveRewards(rewards: r);
		if (mounted) setState(() { _streak = s; _rewards = r; });
	}

	@override
	void dispose() {
		_noteController.dispose();
		super.dispose();
	}

	Future<void> _save() async {
		final score = _score.round().clamp(1, 10);
		await _service.addMood(score: score, note: _noteController.text.trim());
		await _refreshStreaks();
		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mood logged')));
			_noteController.clear();
		}
	}

	@override
	Widget build(BuildContext context) {
		return ListView(
			padding: const EdgeInsets.all(16),
			children: [
				if (_streak != null)
					Card(
						color: Theme.of(context).colorScheme.secondaryContainer,
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Row(
								children: [
									const Text('🔥', style: TextStyle(fontSize: 28)),
									const SizedBox(width: 12),
									Expanded(child: Text('Streak: $_streak days', style: Theme.of(context).textTheme.titleMedium)),
									if (_rewards.isNotEmpty) Chip(label: Text('Rewards: ${_rewards.length}')),
								],
							),
						),
					),
				Card(
					child: Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										const Icon(Icons.mood, size: 28),
										const SizedBox(width: 8),
										Text('How are you feeling today?', style: Theme.of(context).textTheme.titleMedium),
									],
								),
								const SizedBox(height: 12),
								Row(
									children: [
										const Text('😔 1'),
										Expanded(
											child: Slider(
												value: _score,
												min: 1,
												max: 10,
												divisions: 9,
												label: _score.round().toString(),
												onChanged: (v) => setState(() => _score = v),
											),
										),
										const Text('10 😀'),
									],
								),
								TextField(
									controller: _noteController,
									maxLines: 2,
									decoration: const InputDecoration(hintText: 'Add a note (optional)'),
								),
								const SizedBox(height: 8),
								ElevatedButton.icon(
									icon: const Icon(Icons.save),
									label: const Text('Save'),
									onPressed: _save,
								),
							],
						),
					),
				),
				const SizedBox(height: 16),
				Text('This week', style: Theme.of(context).textTheme.titleMedium),
				SizedBox(
					height: 220,
					child: StreamBuilder<List<MoodEntry>>(
						stream: _service.streamRecent(days: 7),
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
									LineChartBarData(spots: spots, isCurved: true, color: Theme.of(context).colorScheme.primary, dotData: const FlDotData(show: false)),
								],
								gridData: const FlGridData(show: true),
								titlesData: const FlTitlesData(show: false),
							));
						},
					),
				),
				const SizedBox(height: 16),
				Text('This month', style: Theme.of(context).textTheme.titleMedium),
				SizedBox(
					height: 220,
					child: StreamBuilder<List<MoodEntry>>(
						stream: _service.streamRecent(days: 30),
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
									LineChartBarData(spots: spots, isCurved: true, color: Theme.of(context).colorScheme.secondary, dotData: const FlDotData(show: false)),
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
