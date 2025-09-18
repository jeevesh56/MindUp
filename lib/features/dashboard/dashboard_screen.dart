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
			case 1: return '😢'; // Very Sad
			case 2: return '😔'; // Sad
			case 3: return '😐'; // Neutral
			case 4: return '🙂'; // Okay
			case 5: return '😊'; // Happy
			case 6: return '😄'; // Very Happy
			case 7: return '🤩'; // Excited
			case 8: return '🥳'; // Ecstatic
			default: return '😐';
		}
	}

	@override
	Widget build(BuildContext context) {
		return Stack(
			children: [
				ListView(
					padding: const EdgeInsets.all(16),
					children: [
						Row(
							children: [
								Text('Welcome back 👋', style: Theme.of(context).textTheme.headlineSmall),
								const Spacer(),
								AnimatedBuilder(
									animation: _sparkleController,
									builder: (context, child) {
										return Transform.rotate(
											angle: _sparkleController.value * 2 * 3.14159,
											child: const Icon(Icons.auto_awesome, color: Colors.amber),
										);
									},
								),
							],
						).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
						const SizedBox(height: 12),
						FutureBuilder<int>(
							future: _streaksService.computeCurrentStreak(),
							builder: (context, snap) {
								final streak = snap.data ?? 0;
								return _InteractiveCard(
									onTap: () => HapticFeedback.mediumImpact(),
									color: Theme.of(context).colorScheme.primaryContainer,
									title: 'Daily Wellness Streak',
									subtitle: '$streak day${streak == 1 ? '' : 's'} strong',
									icon: AnimatedBuilder(
										animation: _pulseController,
										builder: (context, child) {
											return Transform.scale(
												scale: 1.0 + (_pulseController.value * 0.1),
												child: const Text('🔥', style: TextStyle(fontSize: 28)),
											);
										},
									),
									child: streak > 0 ? [
										LinearProgressIndicator(
											value: (streak % 7) / 7,
											backgroundColor: Colors.grey.withValues(alpha: 0.3),
										),
										const SizedBox(height: 4),
										Text('${7 - (streak % 7)} days to next milestone', style: Theme.of(context).textTheme.bodySmall),
									] : null,
								);
							},
						).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),
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
											child: _InteractiveCard(
												onTap: () => _quickMoodLog(avg.round()),
												title: 'Mood Avg',
												subtitle: '${avg.toStringAsFixed(1)} / 10',
												icon: Text(_getMoodEmoji(avg.round()), style: const TextStyle(fontSize: 24)),
											),
										),
										const SizedBox(width: 12),
										Expanded(
											child: _InteractiveCard(
												onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const MoodGardenScreen())),
												title: 'Garden',
												subtitle: ['Seed','Sprout','Growing','Budding','Bloom'][stage-1],
												icon: Icon(_iconForStage(stage)),
											),
										),
									],
								);
							},
						).animate().fadeIn(duration: 1000.ms).slideX(begin: -0.1),
						const SizedBox(height: 12),
						Container(
							decoration: BoxDecoration(
								color: Theme.of(context).colorScheme.surface,
								borderRadius: BorderRadius.circular(16),
								border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
								boxShadow: [
									BoxShadow(
										color: Colors.black.withValues(alpha: 0.05),
										blurRadius: 10,
										offset: const Offset(0, 4),
									),
								],
							),
							padding: const EdgeInsets.all(12),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Row(
										children: [
											Text('Last 14 days', style: Theme.of(context).textTheme.titleMedium),
											const Spacer(),
											IconButton(
												onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const MoodTrackerScreen())),
												icon: const Icon(Icons.add_circle_outline),
												tooltip: 'Log mood',
											),
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
						).animate().fadeIn(duration: 1200.ms).slideY(begin: 0.1),
					],
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

class _InteractiveCard extends StatelessWidget {
	final String title;
	final String subtitle;
	final Widget icon;
	final Color? color;
	final VoidCallback? onTap;
	final List<Widget>? child;
	const _InteractiveCard({required this.title, required this.subtitle, required this.icon, this.color, this.onTap, this.child});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(16),
			child: Container(
				padding: const EdgeInsets.all(12),
				decoration: BoxDecoration(
					color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
					borderRadius: BorderRadius.circular(16),
					boxShadow: [
						BoxShadow(
							color: Colors.black.withValues(alpha: 0.05),
							blurRadius: 8,
							offset: const Offset(0, 2),
						),
					],
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								icon,
								const SizedBox(width: 10),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(title, style: Theme.of(context).textTheme.labelLarge),
											Text(subtitle, style: Theme.of(context).textTheme.titleMedium),
										],
									),
								),
							],
						),
						if (child != null) ...child!,
					],
				),
			),
		);
	}
}


class _MoodPopup extends StatefulWidget {
	final VoidCallback onClose;
	final Function(int) onMoodSelected;
	
	const _MoodPopup({required this.onClose, required this.onMoodSelected});

	@override
	State<_MoodPopup> createState() => _MoodPopupState();
}

class _MoodPopupState extends State<_MoodPopup> with TickerProviderStateMixin {
	late AnimationController _fadeController;
	late AnimationController _scaleController;
	Map<String, dynamic>? _selectedMood;
	
	// Advanced mood options
	final List<Map<String, dynamic>> _moodOptions = [
		{'emoji': '😢', 'label': 'Sad', 'score': 1, 'color': Colors.blue, 'description': 'Feeling down'},
		{'emoji': '😐', 'label': 'Neutral', 'score': 3, 'color': Colors.grey, 'description': 'Feeling okay'},
		{'emoji': '🙂', 'label': 'Okay', 'score': 5, 'color': Colors.orange, 'description': 'Feeling decent'},
		{'emoji': '😊', 'label': 'Happy', 'score': 7, 'color': Colors.green, 'description': 'Feeling good'},
		{'emoji': '😄', 'label': 'Great', 'score': 9, 'color': Colors.purple, 'description': 'Feeling amazing'},
	];

	@override
	void initState() {
		super.initState();
		_fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
		_scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
		_fadeController.forward();
	}

	@override
	void dispose() {
		_fadeController.dispose();
		_scaleController.dispose();
		super.dispose();
	}

	void _selectMood(Map<String, dynamic> mood) {
		setState(() => _selectedMood = mood);
		_scaleController.forward().then((_) => _scaleController.reverse());
		HapticFeedback.mediumImpact();
	}

	void _submitMood() {
		if (_selectedMood != null) {
			widget.onMoodSelected(_selectedMood!['score']);
			widget.onClose();
		}
	}

	@override
	Widget build(BuildContext context) {
		return FadeTransition(
			opacity: _fadeController,
			child: Material(
				color: Colors.black.withOpacity(0.4),
				child: Center(
					child: Container(
						margin: const EdgeInsets.all(12),
						padding: const EdgeInsets.all(14),
						decoration: BoxDecoration(
							color: Theme.of(context).colorScheme.surface,
							borderRadius: BorderRadius.circular(16),
							boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 8))],
						),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								// Title row
								Row(
									children: [
										Icon(Icons.mood, color: Theme.of(context).colorScheme.primary, size: 18),
										const SizedBox(width: 6),
										Text('Choose mood', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 18)),
										const Spacer(),
										IconButton(
											onPressed: widget.onClose,
											icon: const Icon(Icons.close, size: 18),
											style: IconButton.styleFrom(minimumSize: const Size(32,32), padding: const EdgeInsets.all(6)),
										),
									],
								),
								const SizedBox(height: 8),
								// Compact emoji grid
								GridView.builder(
									shrinkWrap: true,
									physics: const NeverScrollableScrollPhysics(),
									gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
										crossAxisCount: 5,
										childAspectRatio: 1,
										crossAxisSpacing: 4,
										mainAxisSpacing: 4,
									),
									itemCount: _moodOptions.length,
									itemBuilder: (context, index) {
										final mood = _moodOptions[index];
										final isSelected = _selectedMood == mood;
										return AnimatedBuilder(
											animation: _scaleController,
											builder: (context, child) {
												return Transform.scale(
													scale: isSelected ? 1.0 + (_scaleController.value * 0.08) : 1.0,
													child: InkWell(
														onTap: () {
															widget.onMoodSelected(mood['score']);
															widget.onClose();
														},
														borderRadius: BorderRadius.circular(12),
														child: Container(
															padding: const EdgeInsets.all(8),
															decoration: BoxDecoration(
																color: mood['color'].withOpacity(0.06),
																borderRadius: BorderRadius.circular(12),
															),
															child: Center(
																child: Text(mood['emoji'], style: const TextStyle(fontSize: 28)),
															),
														),
													),
												);
											},
										);
									},
								),
							],
						),
					),
				),
			),
		);
	}
}
