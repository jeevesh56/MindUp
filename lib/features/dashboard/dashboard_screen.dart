import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mood/mood_service.dart';
import '../mood/models/mood_entry.dart';
import '../streaks/streaks_service.dart';
import '../garden/mood_garden_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../games/games_hub_screen.dart';
import '../forum/forum_screen.dart';
import '../mood/mood_tracker_screen.dart';
import 'mental_health_dashboard.dart';
import '../assessments/assessments_screen.dart';

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
	static const String _prefsPopupLastShown = 'dashboard_popup_last_shown';
	static const String _prefsLowMoodDate = 'low_mood_date';
	static const String _prefsLowMoodCount = 'low_mood_count';

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
		final todayKey = DateTime.now();
		final todayStr = '${todayKey.year}-${todayKey.month}-${todayKey.day}';
		final lastShown = prefs.getString(_prefsPopupLastShown);
		if (lastShown != todayStr) {
			await prefs.setString(_prefsPopupLastShown, todayStr);
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
		await _maybeTriggerSos(score);
		if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Mood logged: ${_getMoodEmoji(score)}'), duration: const Duration(seconds: 1)),
			);
		}
	}

	Future<void> _maybeTriggerSos(int score) async {
		if (score > 2) return;
		final prefs = await SharedPreferences.getInstance();
		final now = DateTime.now();
		final todayStr = '${now.year}-${now.month}-${now.day}';
		final lastDate = prefs.getString(_prefsLowMoodDate);
		int count = prefs.getInt(_prefsLowMoodCount) ?? 0;
		if (lastDate != todayStr) {
			count = 0;
		}
		count += 1;
		await prefs.setString(_prefsLowMoodDate, todayStr);
		await prefs.setInt(_prefsLowMoodCount, count);
		if (count >= 2 && mounted) {
			await Future.delayed(const Duration(milliseconds: 300));
			if (!mounted) return;
			// Soft prompt to open SOS resources
			final proceed = await showDialog<bool>(
				context: context,
				builder: (ctx) => AlertDialog(
					title: const Text('Support available'),
					content: const Text('We noticed you logged a very low mood multiple times today. Would you like quick access to support resources?'),
					actions: [
						TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Not now')),
						FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Open SOS')),
					],
				),
			);
			if (proceed == true && mounted) {
				Navigator.of(context).pushNamed('/sos');
			}
		}
	}

	String _getMoodEmoji(int score) {
		if (score <= 2) return '😢';
		if (score <= 4) return '😔';
		if (score <= 6) return '😐';
		if (score <= 8) return '😊';
		return '😄';
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
						_ActionButton(icon: Icons.assignment_turned_in, label: 'Assessments', onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const AssessmentsScreen()))),
							_ActionButton(icon: Icons.dashboard_customize, label: 'New Dashboard', onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const ExperimentalMentalHealthDashboard()))),
							],
						).animate().fadeIn(duration: 1400.ms).slideY(begin: 0.2),
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

class _ActionButton extends StatelessWidget {
	final IconData icon; final String label; final VoidCallback onTap;
	const _ActionButton({required this.icon, required this.label, required this.onTap});
	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () {
				HapticFeedback.lightImpact();
				onTap();
			},
			borderRadius: BorderRadius.circular(14),
			child: Container(
				width: 160,
				padding: const EdgeInsets.all(12),
				decoration: BoxDecoration(
					color: Theme.of(context).colorScheme.secondaryContainer,
					borderRadius: BorderRadius.circular(14),
					boxShadow: [
						BoxShadow(
							color: Colors.black.withValues(alpha: 0.05),
							blurRadius: 6,
							offset: const Offset(0, 2),
						),
					],
				),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [Icon(icon), const SizedBox(width: 8), Text(label)],
				),
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
						width: 280,
						height: 280,
						padding: const EdgeInsets.all(16),
						decoration: BoxDecoration(
							color: Theme.of(context).colorScheme.surface,
							borderRadius: BorderRadius.circular(16),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.14),
									blurRadius: 16,
									offset: const Offset(0, 8),
								),
							],
						),
						child: Column(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Text('How are you feeling?', style: Theme.of(context).textTheme.titleMedium),
								Wrap(
									spacing: 8,
									runSpacing: 8,
									children: [
										_MoodEmoji(emoji: '😢', score: 1, onTap: () => onMoodSelected(1)),
										_MoodEmoji(emoji: '😔', score: 2, onTap: () => onMoodSelected(2)),
										_MoodEmoji(emoji: '😐', score: 3, onTap: () => onMoodSelected(3)),
										_MoodEmoji(emoji: '😊', score: 4, onTap: () => onMoodSelected(4)),
										_MoodEmoji(emoji: '😄', score: 5, onTap: () => onMoodSelected(5)),
									],
								),
								Align(alignment: Alignment.centerRight, child: TextButton(onPressed: onClose, child: const Text('Skip'))),
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
	final VoidCallback onTap;
	
	const _MoodEmoji({required this.emoji, required this.score, required this.onTap});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () {
				HapticFeedback.mediumImpact();
				onTap();
			},
			borderRadius: BorderRadius.circular(12),
			child: Container(
				width: 54,
				height: 54,
				decoration: BoxDecoration(
					color: Theme.of(context).colorScheme.primaryContainer,
					borderRadius: BorderRadius.circular(12),
				),
				child: Center(
					child: Text(emoji, style: const TextStyle(fontSize: 28)),
				),
			),
		);
	}
}