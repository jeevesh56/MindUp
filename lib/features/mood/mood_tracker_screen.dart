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
	final TextEditingController _noteController = TextEditingController();
	final MoodService _service = MoodService();
	final StreaksService _streaks = StreaksService();
	int? _streak;

	// 5 key emotions covering the full spectrum
	final List<Map<String, dynamic>> _moodOptions = [
		{'emoji': '😢', 'label': 'Sad', 'score': 1, 'color': Colors.blue},
		{'emoji': '😐', 'label': 'Neutral', 'score': 3, 'color': Colors.grey},
		{'emoji': '🙂', 'label': 'Okay', 'score': 5, 'color': Colors.orange},
		{'emoji': '😊', 'label': 'Happy', 'score': 7, 'color': Colors.green},
		{'emoji': '😄', 'label': 'Great', 'score': 9, 'color': Colors.purple},
	];

	@override
	void initState() {
		super.initState();
		_refreshStreaks();
	}

	Future<void> _refreshStreaks() async {
		final s = await _streaks.computeCurrentStreak();
		final r = _streaks.unlockedRewardsForStreak(s);
		await _streaks.saveRewards(rewards: r);
		if (mounted) setState(() { _streak = s; });
	}

	@override
	void dispose() {
		_noteController.dispose();
		super.dispose();
	}

	Future<void> _saveMood(Map<String, dynamic> mood) async {
		await _service.addMood(score: mood['score'], note: _noteController.text.trim());
		await _refreshStreaks();
		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Row(
						mainAxisSize: MainAxisSize.min,
						children: [
							Text(mood['emoji'], style: const TextStyle(fontSize: 20)),
							const SizedBox(width: 8),
							Text('Mood logged: ${mood['label']}'),
						],
					),
					duration: const Duration(seconds: 2),
				),
			);
			_noteController.clear();
		}
	}

	void _showMoodDialog() {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				titlePadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
				contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
				title: Row(
					children: [
						Icon(Icons.mood, color: Theme.of(context).colorScheme.primary, size: 20),
						const SizedBox(width: 8),
						const Text('Log mood', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
					],
				),
				content: ConstrainedBox(
					constraints: const BoxConstraints(maxWidth: 420),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							TextField(
								controller: _noteController,
								maxLines: 1,
								decoration: const InputDecoration(
									hintText: 'What happened? (optional)',
									border: OutlineInputBorder(),
									contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
									isDense: true,
								),
							),
							const SizedBox(height: 12),
							Wrap(
								spacing: 8,
								runSpacing: 8,
								children: _moodOptions.map((mood) => _buildMoodOption(mood)).toList(),
							),
						],
					),
				),
			),
		);
	}

	Widget _buildMoodOption(Map<String, dynamic> mood) {
		return InkWell(
			onTap: () {
				Navigator.of(context).pop();
				_saveMood(mood);
			},
			borderRadius: BorderRadius.circular(12),
			child: Container(
				padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
				decoration: BoxDecoration(
					color: mood['color'].withOpacity(0.08),
					borderRadius: BorderRadius.circular(12),
					border: Border.all(color: mood['color'].withOpacity(0.25)),
				),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						Text(mood['emoji'], style: const TextStyle(fontSize: 22)),
						const SizedBox(width: 6),
						Text(
							mood['label'],
							style: TextStyle(
								fontWeight: FontWeight.w600,
								color: mood['color'],
								fontSize: 13,
							),
						),
					],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: Column(
					children: [
						// Header with streak
						Container(
							padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
							decoration: BoxDecoration(
								gradient: LinearGradient(
									colors: [
										Theme.of(context).colorScheme.primary.withOpacity(0.08),
										Theme.of(context).colorScheme.secondary.withOpacity(0.08),
									],
									begin: Alignment.topLeft,
									end: Alignment.bottomRight,
								),
							),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												'Mood Tracker',
												style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
											),
											Text(
												'Track your daily emotions',
												style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
											),
										],
									),
									if (_streak != null)
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
											decoration: BoxDecoration(
												color: Theme.of(context).colorScheme.primary,
												borderRadius: BorderRadius.circular(16),
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													const Text('🔥', style: TextStyle(fontSize: 18, color: Colors.white)),
													const SizedBox(width: 6),
													Text('$_streak', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
												],
											),
										),
								],
							),
						),
						// Quick mood log button
						Padding(
							padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
							child: SizedBox(
								width: double.infinity,
								child: ElevatedButton.icon(
									onPressed: _showMoodDialog,
									icon: const Icon(Icons.add, size: 20),
									label: const Text('Log Your Mood', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
									style: ElevatedButton.styleFrom(
										padding: const EdgeInsets.symmetric(vertical: 12),
										shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
									),
								),
							),
						),
						// Mood chart
						Expanded(
							child: Padding(
								padding: const EdgeInsets.all(16),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text('Your Mood Journey', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
										const SizedBox(height: 12),
										Expanded(
											child: Container(
												padding: const EdgeInsets.all(12),
												decoration: BoxDecoration(
													color: Theme.of(context).colorScheme.surface,
													borderRadius: BorderRadius.circular(14),
													boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
												),
												child: StreamBuilder<List<MoodEntry>>(
													stream: _service.streamRecent(days: 7),
													builder: (context, snapshot) {
														final data = snapshot.data ?? const <MoodEntry>[];
														if (data.isEmpty) {
															return Center(
																child: Column(
																	mainAxisAlignment: MainAxisAlignment.center,
																	children: [
																		Icon(Icons.mood_outlined, size: 56, color: Colors.grey[400]),
																		const SizedBox(height: 12),
																		Text('No mood data yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
																		const SizedBox(height: 6),
																		Text('Start logging to see your journey', style: TextStyle(color: Colors.grey[500])),
																	],
																),
															);
														}
														final spots = data.asMap().entries.map((e)=>FlSpot(e.key.toDouble(), e.value.moodScore.toDouble())).toList();
														return LineChart(LineChartData(
															minY: 1,
															maxY: 10,
															lineBarsData: [
																LineChartBarData(spots: spots, isCurved: true, color: Theme.of(context).colorScheme.primary, barWidth: 3, dotData: const FlDotData(show: true)),
															],
															gridData: FlGridData(show: true, horizontalInterval: 1, getDrawingHorizontalLine: (v)=> FlLine(color: Colors.grey[200]!, strokeWidth: 1)),
															titlesData: FlTitlesData(
																leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 2, getTitlesWidget: (v, m)=> Text(v.toInt().toString(), style: TextStyle(color: Colors.grey[600])))),
																bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
																topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
																rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
															),
														));
													},
												),
											),
										),
									],
								),
							),
						),
					],
				),
			),
		);
	}
}
