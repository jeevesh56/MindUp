import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mood/mood_service.dart';
import '../mood/models/mood_entry.dart';
import '../streaks/streaks_service.dart';
import '../garden/mood_garden_screen.dart';
import '../mood/mood_tracker_screen.dart';

class DashboardScreen extends StatefulWidget {
	const DashboardScreen({super.key});

	@override
	State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
	final MoodService _moodService = MoodService();
	final StreaksService _streaksService = StreaksService();
	late AnimationController _pulseController;
	late AnimationController _sparkleController;
	bool _showMoodPopup = false;

	@override
	void initState() {
		super.initState();
		_pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
		_sparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
		_checkFirstVisit();
		_refreshStreaks();
	}

	@override
	void dispose() {
		_pulseController.dispose();
		_sparkleController.dispose();
		super.dispose();
	}

	Future<void> _checkFirstVisit() async {
		final prefs = await SharedPreferences.getInstance();
		final hasVisited = prefs.getBool('dashboard_visited') ?? false;
		if (!hasVisited) {
			await prefs.setBool('dashboard_visited', true);
			await Future.delayed(const Duration(milliseconds: 500));
			if (mounted) setState(() => _showMoodPopup = true);
		}
	}

	Future<void> _refreshStreaks() async {
		await _streaksService.computeCurrentStreak();
	}

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

	void _quickMoodLog(int score) async {
		HapticFeedback.lightImpact();
		await _moodService.addMood(score: score);
		await _refreshStreaks();
		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Mood logged: ${_getMoodEmoji(score)}'), duration: const Duration(seconds: 1)),
			);
		}
	}

	String _getMoodEmoji(int score) {
		switch (score) {
			case 1: return '😢';
			case 2: return '😞';
			case 3: return '😐';
			case 4: return '🙁';
			case 5: return '🙂';
			case 6: return '😊';
			case 7: return '😄';
			case 8: return '😁';
			case 9: return '😀';
			case 10: return '🤩';
			default: return '😐';
		}
	}

	@override
	Widget build(BuildContext context) {
		return Stack(
			children: [
				Scaffold(
					body: Container(
						decoration: BoxDecoration(
							gradient: LinearGradient(
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
								colors: [
									Theme.of(context).colorScheme.primary.withOpacity(0.05),
									Theme.of(context).colorScheme.secondary.withOpacity(0.05),
									Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
								],
							),
						),
						child: SafeArea(
							child: ListView(
								padding: const EdgeInsets.all(20),
								children: [
									// Creative Header
									Container(
										padding: const EdgeInsets.all(24),
										decoration: BoxDecoration(
											gradient: LinearGradient(
												colors: [
													Theme.of(context).colorScheme.primary.withOpacity(0.1),
													Theme.of(context).colorScheme.secondary.withOpacity(0.1),
												],
												begin: Alignment.topLeft,
												end: Alignment.bottomRight,
											),
											borderRadius: BorderRadius.circular(24),
											boxShadow: [
												BoxShadow(
													color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
													blurRadius: 20,
													offset: const Offset(0, 8),
												),
											],
										),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Row(
													children: [
														Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text(
																	'Welcome back! 👋',
																	style: Theme.of(context).textTheme.headlineMedium?.copyWith(
																		fontWeight: FontWeight.bold,
																	),
																),
																const SizedBox(height: 4),
																Text(
																	'How are you feeling today?',
																	style: Theme.of(context).textTheme.bodyLarge?.copyWith(
																		color: Colors.grey[600],
																	),
																),
															],
														),
														const Spacer(),
														AnimatedBuilder(
															animation: _sparkleController,
															builder: (context, child) {
																return Transform.rotate(
																	angle: _sparkleController.value * 2 * 3.14159,
																	child: Container(
																		padding: const EdgeInsets.all(12),
																		decoration: BoxDecoration(
																			color: Colors.amber.withOpacity(0.2),
																			borderRadius: BorderRadius.circular(16),
																		),
																		child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
																	),
																);
															},
														),
													],
												),
												const SizedBox(height: 20),
												// Quick Mood Log Button
												SizedBox(
													width: double.infinity,
													child: ElevatedButton.icon(
														onPressed: () => setState(() => _showMoodPopup = true),
														icon: const Icon(Icons.mood, size: 20),
														label: const Text(
															'Log Your Mood',
															style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
														),
														style: ElevatedButton.styleFrom(
															padding: const EdgeInsets.symmetric(vertical: 16),
															shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(16),
															),
														),
													),
												),
											],
										),
									).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
									
									const SizedBox(height: 24),
									
									// Stats Cards Row
									Row(
										children: [
											// Streak Card
											Expanded(
												child: FutureBuilder<int>(
													future: _streaksService.computeCurrentStreak(),
													builder: (context, snap) {
														final streak = snap.data ?? 0;
														return _StatsCard(
															title: 'Streak',
															value: '$streak',
															subtitle: 'days',
															icon: AnimatedBuilder(
																animation: _pulseController,
																builder: (context, child) {
																	return Transform.scale(
																		scale: 1.0 + (_pulseController.value * 0.1),
																		child: const Text('🔥', style: TextStyle(fontSize: 24)),
																	);
																},
															),
															color: Colors.orange,
														);
													},
												),
											),
											const SizedBox(width: 16),
											// Mood Average Card
											Expanded(
												child: StreamBuilder<List<MoodEntry>>(
													stream: _moodService.streamRecent(days: 14),
													builder: (context, snapshot) {
														final data = snapshot.data ?? const <MoodEntry>[];
														final avg = data.isEmpty ? 5.0 : data.map((e) => e.moodScore).reduce((a,b)=>a+b)/data.length;
														return _StatsCard(
															title: 'Mood',
															value: '${avg.toStringAsFixed(1)}',
															subtitle: 'average',
															icon: Text(_getMoodEmoji(avg.round()), style: const TextStyle(fontSize: 24)),
															color: Colors.green,
														);
													},
												),
											),
										],
									).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
									
									const SizedBox(height: 24),
									
									// Garden Status Card
									StreamBuilder<List<MoodEntry>>(
										stream: _moodService.streamRecent(days: 14),
										builder: (context, snapshot) {
											final data = snapshot.data ?? const <MoodEntry>[];
											final avg = data.isEmpty ? 5.0 : data.map((e) => e.moodScore).reduce((a,b)=>a+b)/data.length;
											final stage = _stageFromAverage(avg);
											return _GardenCard(
												stage: stage,
												onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const MoodGardenScreen())),
											);
										},
									).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.2),
									
									const SizedBox(height: 24),
									
									// Mood Chart Card
									_MoodChartCard(
										moodService: _moodService,
										onAddMood: () => Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const MoodTrackerScreen())),
									).animate().fadeIn(duration: 1200.ms).slideY(begin: 0.1),
								],
							),
						),
					),
				),
				if (_showMoodPopup) _MoodPopup(
					onClose: () => setState(() => _showMoodPopup = false),
					onMoodSelected: (score) {
						_quickMoodLog(score);
						setState(() => _showMoodPopup = false);
					},
				),
			],
		);
	}
}

// New Creative Components
class _StatsCard extends StatelessWidget {
	final String title;
	final String value;
	final String subtitle;
	final Widget icon;
	final Color color;
	
	const _StatsCard({
		required this.title,
		required this.value,
		required this.subtitle,
		required this.icon,
		required this.color,
	});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(20),
			decoration: BoxDecoration(
				color: color.withOpacity(0.1),
				borderRadius: BorderRadius.circular(20),
				border: Border.all(color: color.withOpacity(0.2)),
				boxShadow: [
					BoxShadow(
						color: color.withOpacity(0.1),
						blurRadius: 10,
						offset: const Offset(0, 4),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							icon,
							const SizedBox(width: 8),
							Text(
								title,
								style: Theme.of(context).textTheme.titleSmall?.copyWith(
									color: color,
									fontWeight: FontWeight.w600,
								),
							),
						],
					),
					const SizedBox(height: 12),
					Text(
						value,
						style: Theme.of(context).textTheme.headlineMedium?.copyWith(
							fontWeight: FontWeight.bold,
							color: color,
						),
					),
					Text(
						subtitle,
						style: Theme.of(context).textTheme.bodySmall?.copyWith(
							color: Colors.grey[600],
						),
					),
				],
			),
		);
	}
}

class _GardenCard extends StatelessWidget {
	final int stage;
	final VoidCallback onTap;
	
	const _GardenCard({required this.stage, required this.onTap});

	@override
	Widget build(BuildContext context) {
		final stages = ['Seed', 'Sprout', 'Growing', 'Budding', 'Bloom'];
		final icons = [
			Icons.spa_outlined,
			Icons.eco_outlined,
			Icons.park_outlined,
			Icons.local_florist_outlined,
			Icons.local_florist,
		];
		
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(20),
			child: Container(
				padding: const EdgeInsets.all(24),
				decoration: BoxDecoration(
					gradient: LinearGradient(
						colors: [
							Colors.green.withOpacity(0.1),
							Colors.lightGreen.withOpacity(0.1),
						],
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
					),
					borderRadius: BorderRadius.circular(20),
					border: Border.all(color: Colors.green.withOpacity(0.2)),
					boxShadow: [
						BoxShadow(
							color: Colors.green.withOpacity(0.1),
							blurRadius: 15,
							offset: const Offset(0, 6),
						),
					],
				),
				child: Row(
					children: [
						Container(
							padding: const EdgeInsets.all(16),
							decoration: BoxDecoration(
								color: Colors.green.withOpacity(0.2),
								borderRadius: BorderRadius.circular(16),
							),
							child: Icon(
								icons[stage - 1],
								color: Colors.green,
								size: 32,
							),
						),
						const SizedBox(width: 16),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Your Garden',
										style: Theme.of(context).textTheme.titleLarge?.copyWith(
											fontWeight: FontWeight.bold,
											color: Colors.green[700],
										),
									),
									const SizedBox(height: 4),
									Text(
										stages[stage - 1],
										style: Theme.of(context).textTheme.titleMedium?.copyWith(
											color: Colors.green[600],
										),
									),
									const SizedBox(height: 8),
									Text(
										'Keep logging your mood to help your garden grow!',
										style: Theme.of(context).textTheme.bodyMedium?.copyWith(
											color: Colors.grey[600],
										),
									),
								],
							),
						),
						Icon(
							Icons.arrow_forward_ios,
							color: Colors.green[400],
							size: 20,
						),
					],
				),
			),
		);
	}
}

class _MoodChartCard extends StatelessWidget {
	final MoodService moodService;
	final VoidCallback onAddMood;
	
	const _MoodChartCard({required this.moodService, required this.onAddMood});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(24),
			decoration: BoxDecoration(
				color: Theme.of(context).colorScheme.surface,
				borderRadius: BorderRadius.circular(20),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withOpacity(0.05),
						blurRadius: 15,
						offset: const Offset(0, 6),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Container(
								padding: const EdgeInsets.all(8),
								decoration: BoxDecoration(
									color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
									borderRadius: BorderRadius.circular(12),
								),
								child: Icon(
									Icons.show_chart,
									color: Theme.of(context).colorScheme.primary,
									size: 24,
								),
							),
							const SizedBox(width: 12),
							Text(
								'Mood Journey',
								style: Theme.of(context).textTheme.titleLarge?.copyWith(
									fontWeight: FontWeight.bold,
								),
							),
							const Spacer(),
							IconButton(
								onPressed: onAddMood,
								icon: Container(
									padding: const EdgeInsets.all(8),
									decoration: BoxDecoration(
										color: Theme.of(context).colorScheme.primary,
										borderRadius: BorderRadius.circular(12),
									),
									child: const Icon(
										Icons.add,
										color: Colors.white,
										size: 20,
									),
								),
								tooltip: 'Log mood',
							),
						],
					),
					const SizedBox(height: 20),
					SizedBox(
						height: 180,
						child: StreamBuilder<List<MoodEntry>>(
							stream: moodService.streamRecent(days: 14),
							builder: (context, snapshot) {
								final moods = snapshot.data ?? const <MoodEntry>[];
								if (moods.isEmpty) {
									return Center(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												Icon(
													Icons.mood_outlined,
													size: 48,
													color: Colors.grey[400],
												),
												const SizedBox(height: 12),
												Text(
													'No mood data yet',
													style: TextStyle(
														color: Colors.grey[600],
														fontSize: 16,
													),
												),
												const SizedBox(height: 4),
												Text(
													'Start logging to see your journey',
													style: TextStyle(
														color: Colors.grey[500],
														fontSize: 14,
													),
												),
											],
										),
									);
								}
								final spots = moods.asMap().entries.map((e)=>FlSpot(e.key.toDouble(), e.value.moodScore.toDouble())).toList();
								return LineChart(LineChartData(
									minY: 1, maxY: 10,
									lineBarsData: [
										LineChartBarData(
											spots: spots,
											isCurved: true,
											color: Theme.of(context).colorScheme.primary,
											barWidth: 3,
											dotData: FlDotData(
												show: true,
												getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
													radius: 4,
													color: Theme.of(context).colorScheme.primary,
													strokeWidth: 2,
													strokeColor: Colors.white,
												),
											),
											belowBarData: BarAreaData(
												show: true,
												color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
											),
										),
									],
									gridData: FlGridData(
										show: true,
										horizontalInterval: 1,
										getDrawingHorizontalLine: (value) => FlLine(
											color: Colors.grey[200]!,
											strokeWidth: 1,
										),
									),
									titlesData: FlTitlesData(
										leftTitles: AxisTitles(
											sideTitles: SideTitles(
												showTitles: true,
												interval: 2,
												getTitlesWidget: (value, meta) => Text(
													value.toInt().toString(),
													style: TextStyle(
														color: Colors.grey[600],
														fontSize: 12,
													),
												),
											),
										),
										bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
										topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
										rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
									),
								));
							},
						),
					),
				],
			),
		);
	}
}

class _MoodPopup extends StatelessWidget {
	final VoidCallback onClose;
	final Function(int) onMoodSelected;
	
	const _MoodPopup({required this.onClose, required this.onMoodSelected});

	@override
	Widget build(BuildContext context) {
		return Material(
			color: Colors.black.withValues(alpha: 0.5),
			child: Center(
				child: Container(
					margin: const EdgeInsets.all(24),
					padding: const EdgeInsets.all(32),
					decoration: BoxDecoration(
						color: Theme.of(context).colorScheme.surface,
						borderRadius: BorderRadius.circular(24),
						boxShadow: [
							BoxShadow(
								color: Colors.black.withValues(alpha: 0.2),
								blurRadius: 20,
								offset: const Offset(0, 10),
							),
						],
					),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							Row(
								children: [
									Icon(Icons.mood, color: Theme.of(context).colorScheme.primary, size: 28),
									const SizedBox(width: 12),
									Text(
										'How are you feeling?',
										style: Theme.of(context).textTheme.headlineSmall?.copyWith(
											fontWeight: FontWeight.bold,
										),
									),
								],
							),
							const SizedBox(height: 24),
							// Only 5 key emotions
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
								children: [
									_MoodEmoji(emoji: '😢', score: 1, label: 'Sad', onTap: () => onMoodSelected(1)),
									_MoodEmoji(emoji: '😐', score: 3, label: 'Neutral', onTap: () => onMoodSelected(3)),
									_MoodEmoji(emoji: '🙂', score: 5, label: 'Okay', onTap: () => onMoodSelected(5)),
									_MoodEmoji(emoji: '😊', score: 7, label: 'Happy', onTap: () => onMoodSelected(7)),
									_MoodEmoji(emoji: '😄', score: 9, label: 'Great', onTap: () => onMoodSelected(9)),
								],
							),
							const SizedBox(height: 24),
							TextButton(
								onPressed: onClose,
								child: Text(
									'Skip for now',
									style: TextStyle(color: Colors.grey[600]),
								),
							),
						],
					),
				),
			),
		);
	}
}

class _MoodEmoji extends StatelessWidget {
	final String emoji;
	final int score;
	final String label;
	final VoidCallback onTap;
	
	const _MoodEmoji({required this.emoji, required this.score, required this.label, required this.onTap});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () {
				HapticFeedback.mediumImpact();
				onTap();
			},
			borderRadius: BorderRadius.circular(16),
			child: Container(
				padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
				decoration: BoxDecoration(
					color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
					borderRadius: BorderRadius.circular(16),
					border: Border.all(
						color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
						width: 1,
					),
				),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Text(emoji, style: const TextStyle(fontSize: 28)),
						const SizedBox(height: 4),
						Text(
							label,
							style: TextStyle(
								fontSize: 12,
								fontWeight: FontWeight.w600,
								color: Theme.of(context).colorScheme.primary,
							),
						),
					],
				),
			),
		);
	}
}

