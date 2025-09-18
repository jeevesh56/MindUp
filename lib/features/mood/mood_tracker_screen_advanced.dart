import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../streaks/streaks_service.dart';
import 'mood_service.dart';
import 'models/mood_entry.dart';

class MoodTrackerScreen extends StatefulWidget {
	const MoodTrackerScreen({super.key});

	@override
	State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> with TickerProviderStateMixin {
	final TextEditingController _noteController = TextEditingController();
	final MoodService _service = MoodService();
	final StreaksService _streaks = StreaksService();
	int? _streak;
	late AnimationController _pulseController;
	late AnimationController _sparkleController;
	
	// Advanced mood options with more emotions
	final List<Map<String, dynamic>> _moodOptions = [
		{'emoji': '😢', 'label': 'Very Sad', 'score': 1, 'color': Colors.indigo, 'description': 'Feeling down and hopeless'},
		{'emoji': '😔', 'label': 'Sad', 'score': 2, 'color': Colors.blue, 'description': 'Feeling low and disappointed'},
		{'emoji': '😐', 'label': 'Neutral', 'score': 3, 'color': Colors.grey, 'description': 'Feeling okay, nothing special'},
		{'emoji': '🙂', 'label': 'Okay', 'score': 4, 'color': Colors.orange, 'description': 'Feeling decent and stable'},
		{'emoji': '😊', 'label': 'Happy', 'score': 5, 'color': Colors.green, 'description': 'Feeling good and positive'},
		{'emoji': '😄', 'label': 'Very Happy', 'score': 6, 'color': Colors.lightGreen, 'description': 'Feeling great and joyful'},
		{'emoji': '🤩', 'label': 'Excited', 'score': 7, 'color': Colors.purple, 'description': 'Feeling excited and energetic'},
		{'emoji': '🥳', 'label': 'Ecstatic', 'score': 8, 'color': Colors.pink, 'description': 'Feeling amazing and thrilled'},
	];

	@override
	void initState() {
		super.initState();
		_pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
		_sparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
		_refreshStreaks();
	}

	@override
	void dispose() {
		_pulseController.dispose();
		_sparkleController.dispose();
		_noteController.dispose();
		super.dispose();
	}

	Future<void> _refreshStreaks() async {
		final s = await _streaks.computeCurrentStreak();
		final r = _streaks.unlockedRewardsForStreak(s);
		await _streaks.saveRewards(rewards: r);
		if (mounted) setState(() { _streak = s; });
	}

	Future<void> _saveMood(Map<String, dynamic> mood) async {
		HapticFeedback.lightImpact();
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
					behavior: SnackBarBehavior.floating,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
				),
			);
			_noteController.clear();
		}
	}

	void _showAdvancedMoodDialog() {
		showDialog(
			context: context,
			barrierDismissible: false,
			builder: (context) => _AdvancedMoodDialog(
				moodOptions: _moodOptions,
				onMoodSelected: _saveMood,
				onClose: () => Navigator.of(context).pop(),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Container(
				decoration: BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
						colors: [
							Theme.of(context).colorScheme.primary.withOpacity(0.1),
							Theme.of(context).colorScheme.secondary.withOpacity(0.1),
							Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
						],
					),
				),
				child: SafeArea(
					child: Column(
						children: [
							// Advanced Header
							Container(
								padding: const EdgeInsets.all(24),
								decoration: BoxDecoration(
									gradient: LinearGradient(
										colors: [
											Theme.of(context).colorScheme.primary.withOpacity(0.2),
											Theme.of(context).colorScheme.secondary.withOpacity(0.2),
										],
										begin: Alignment.topLeft,
										end: Alignment.bottomRight,
									),
									borderRadius: const BorderRadius.only(
										bottomLeft: Radius.circular(32),
										bottomRight: Radius.circular(32),
									),
									boxShadow: [
										BoxShadow(
											color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
											blurRadius: 20,
											offset: const Offset(0, 8),
										),
									],
								),
								child: Column(
									children: [
										Row(
											children: [
												Container(
													padding: const EdgeInsets.all(12),
													decoration: BoxDecoration(
														color: Theme.of(context).colorScheme.primary,
														borderRadius: BorderRadius.circular(16),
													),
													child: const Icon(
														Icons.mood,
														color: Colors.white,
														size: 28,
													),
												),
												const SizedBox(width: 16),
												Expanded(
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(
																'Mood Tracker',
																style: Theme.of(context).textTheme.headlineMedium?.copyWith(
																	fontWeight: FontWeight.bold,
																	color: Colors.white,
																),
															),
															Text(
																'Track your emotional journey',
																style: Theme.of(context).textTheme.bodyLarge?.copyWith(
																	color: Colors.white.withOpacity(0.8),
																),
															),
														],
													),
												),
												if (_streak != null)
													Container(
														padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
														decoration: BoxDecoration(
															color: Colors.white.withOpacity(0.2),
															borderRadius: BorderRadius.circular(20),
														),
														child: Row(
															mainAxisSize: MainAxisSize.min,
															children: [
																AnimatedBuilder(
																	animation: _pulseController,
																	builder: (context, child) {
																		return Transform.scale(
																			scale: 1.0 + (_pulseController.value * 0.1),
																			child: const Text('🔥', style: TextStyle(fontSize: 20)),
																		);
																	},
																),
																const SizedBox(width: 4),
																Text(
																	'$_streak',
																	style: const TextStyle(
																		color: Colors.white,
																		fontWeight: FontWeight.bold,
																		fontSize: 16,
																	),
																),
															],
														),
													),
											],
										),
										const SizedBox(height: 24),
										// Quick Stats Row
										Row(
											children: [
												Expanded(
													child: _QuickStatCard(
														icon: Icons.trending_up,
														title: 'This Week',
														value: '7.2',
														color: Colors.green,
													),
												),
												const SizedBox(width: 12),
												Expanded(
													child: _QuickStatCard(
														icon: Icons.calendar_today,
														title: 'This Month',
														value: '6.8',
														color: Colors.blue,
													),
												),
												const SizedBox(width: 12),
												Expanded(
													child: _QuickStatCard(
														icon: Icons.emoji_events,
														title: 'Best Day',
														value: '9.0',
														color: Colors.orange,
													),
												),
											],
										),
									],
								),
							).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
							
							// Main Content
							Expanded(
								child: Padding(
									padding: const EdgeInsets.all(20),
									child: Column(
										children: [
											// Log Mood Button
											SizedBox(
												width: double.infinity,
												child: ElevatedButton.icon(
													onPressed: _showAdvancedMoodDialog,
													icon: AnimatedBuilder(
														animation: _sparkleController,
														builder: (context, child) {
															return Transform.rotate(
																angle: _sparkleController.value * 2 * 3.14159,
																child: const Icon(Icons.auto_awesome, size: 20),
															);
														},
													),
													label: const Text(
														'Log Your Mood',
														style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
													),
													style: ElevatedButton.styleFrom(
														padding: const EdgeInsets.symmetric(vertical: 18),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(20),
														),
														elevation: 8,
													),
												),
											).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),
											
											const SizedBox(height: 24),
											
											// Mood Chart
											Expanded(
												child: _MoodChartCard(
													moodService: _service,
													onAddMood: _showAdvancedMoodDialog,
												).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.1),
											),
										],
									),
								),
							),
						],
					),
				),
			),
		);
	}
}

class _QuickStatCard extends StatelessWidget {
	final IconData icon;
	final String title;
	final String value;
	final Color color;
	
	const _QuickStatCard({
		required this.icon,
		required this.title,
		required this.value,
		required this.color,
	});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.white.withOpacity(0.2),
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: Colors.white.withOpacity(0.3)),
			),
			child: Column(
				children: [
					Icon(icon, color: Colors.white, size: 20),
					const SizedBox(height: 8),
					Text(
						value,
						style: const TextStyle(
							color: Colors.white,
							fontSize: 18,
							fontWeight: FontWeight.bold,
						),
					),
					Text(
						title,
						style: TextStyle(
							color: Colors.white.withOpacity(0.8),
							fontSize: 12,
						),
					),
				],
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
				borderRadius: BorderRadius.circular(24),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withOpacity(0.05),
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
							Container(
								padding: const EdgeInsets.all(12),
								decoration: BoxDecoration(
									color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
									borderRadius: BorderRadius.circular(16),
								),
								child: Icon(
									Icons.show_chart,
									color: Theme.of(context).colorScheme.primary,
									size: 24,
								),
							),
							const SizedBox(width: 16),
							Text(
								'Your Mood Journey',
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
					const SizedBox(height: 24),
					Expanded(
						child: StreamBuilder<List<MoodEntry>>(
							stream: moodService.streamRecent(days: 7),
							builder: (context, snapshot) {
								final moods = snapshot.data ?? const <MoodEntry>[];
								if (moods.isEmpty) {
									return Center(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												Container(
													padding: const EdgeInsets.all(24),
													decoration: BoxDecoration(
														color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
														borderRadius: BorderRadius.circular(20),
													),
													child: Icon(
														Icons.mood_outlined,
														size: 64,
														color: Theme.of(context).colorScheme.primary,
													),
												),
												const SizedBox(height: 16),
												Text(
													'No mood data yet',
													style: Theme.of(context).textTheme.titleLarge?.copyWith(
														fontWeight: FontWeight.bold,
													),
												),
												const SizedBox(height: 8),
												Text(
													'Start logging your mood to see your journey',
													style: Theme.of(context).textTheme.bodyLarge?.copyWith(
														color: Colors.grey[600],
													),
												),
												const SizedBox(height: 24),
												ElevatedButton.icon(
													onPressed: onAddMood,
													icon: const Icon(Icons.add),
													label: const Text('Log First Mood'),
													style: ElevatedButton.styleFrom(
														padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(16),
														),
													),
												),
											],
										),
									);
								}
								final spots = moods.asMap().entries.map((e)=>FlSpot(e.key.toDouble(), e.value.moodScore.toDouble())).toList();
								return LineChart(LineChartData(
									minY: 1, maxY: 8,
									lineBarsData: [
										LineChartBarData(
											spots: spots,
											isCurved: true,
											color: Theme.of(context).colorScheme.primary,
											barWidth: 4,
											dotData: FlDotData(
												show: true,
												getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
													radius: 6,
													color: Theme.of(context).colorScheme.primary,
													strokeWidth: 3,
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
												interval: 1,
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

class _AdvancedMoodDialog extends StatefulWidget {
	final List<Map<String, dynamic>> moodOptions;
	final Function(Map<String, dynamic>) onMoodSelected;
	final VoidCallback onClose;
	
	const _AdvancedMoodDialog({
		required this.moodOptions,
		required this.onMoodSelected,
		required this.onClose,
	});

	@override
	State<_AdvancedMoodDialog> createState() => _AdvancedMoodDialogState();
}

class _AdvancedMoodDialogState extends State<_AdvancedMoodDialog> with TickerProviderStateMixin {
	final TextEditingController _noteController = TextEditingController();
	late AnimationController _fadeController;
	late AnimationController _scaleController;
	Map<String, dynamic>? _selectedMood;

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
		_noteController.dispose();
		super.dispose();
	}

	void _selectMood(Map<String, dynamic> mood) {
		setState(() => _selectedMood = mood);
		_scaleController.forward().then((_) => _scaleController.reverse());
		HapticFeedback.mediumImpact();
	}

	void _submitMood() {
		if (_selectedMood != null) {
			widget.onMoodSelected(_selectedMood!);
			Navigator.of(context).pop();
		}
	}

	@override
	Widget build(BuildContext context) {
		return FadeTransition(
			opacity: _fadeController,
			child: Material(
				color: Colors.black.withOpacity(0.5),
				child: Center(
					child: Container(
						margin: const EdgeInsets.all(20),
						padding: const EdgeInsets.all(32),
						decoration: BoxDecoration(
							color: Theme.of(context).colorScheme.surface,
							borderRadius: BorderRadius.circular(28),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withOpacity(0.2),
									blurRadius: 30,
									offset: const Offset(0, 15),
								),
							],
						),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								// Header
								Row(
									children: [
										Container(
											padding: const EdgeInsets.all(12),
											decoration: BoxDecoration(
												color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
												borderRadius: BorderRadius.circular(16),
											),
											child: Icon(
												Icons.mood,
												color: Theme.of(context).colorScheme.primary,
												size: 28,
											),
										),
										const SizedBox(width: 16),
										Expanded(
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text(
														'How are you feeling?',
														style: Theme.of(context).textTheme.headlineSmall?.copyWith(
															fontWeight: FontWeight.bold,
														),
													),
													Text(
														'Select your current emotional state',
														style: Theme.of(context).textTheme.bodyMedium?.copyWith(
															color: Colors.grey[600],
														),
													),
												],
											),
										),
										IconButton(
											onPressed: widget.onClose,
											icon: const Icon(Icons.close),
											style: IconButton.styleFrom(
												backgroundColor: Colors.grey[100],
												foregroundColor: Colors.grey[600],
											),
										),
									],
								),
								const SizedBox(height: 32),
								
								// Mood Selection Grid
								GridView.builder(
									shrinkWrap: true,
									physics: const NeverScrollableScrollPhysics(),
									gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
										crossAxisCount: 4,
										childAspectRatio: 0.8,
										crossAxisSpacing: 12,
										mainAxisSpacing: 12,
									),
									itemCount: widget.moodOptions.length,
									itemBuilder: (context, index) {
										final mood = widget.moodOptions[index];
										final isSelected = _selectedMood == mood;
										
										return AnimatedBuilder(
											animation: _scaleController,
											builder: (context, child) {
												return Transform.scale(
													scale: isSelected ? 1.0 + (_scaleController.value * 0.1) : 1.0,
													child: InkWell(
														onTap: () => _selectMood(mood),
														borderRadius: BorderRadius.circular(20),
														child: Container(
															padding: const EdgeInsets.all(16),
															decoration: BoxDecoration(
																color: isSelected 
																	? mood['color'].withOpacity(0.2)
																	: mood['color'].withOpacity(0.05),
																borderRadius: BorderRadius.circular(20),
																border: Border.all(
																	color: isSelected 
																		? mood['color']
																		: mood['color'].withOpacity(0.3),
																	width: isSelected ? 2 : 1,
																),
																boxShadow: isSelected ? [
																	BoxShadow(
																		color: mood['color'].withOpacity(0.3),
																		blurRadius: 12,
																		offset: const Offset(0, 4),
																	),
																] : null,
															),
															child: Column(
																mainAxisAlignment: MainAxisAlignment.center,
																children: [
																	Text(
																		mood['emoji'],
																		style: const TextStyle(fontSize: 32),
																	),
																	const SizedBox(height: 8),
																	Text(
																		mood['label'],
																		style: TextStyle(
																			fontSize: 12,
																			fontWeight: FontWeight.w600,
																			color: isSelected 
																				? mood['color']
																				: Colors.grey[700],
																		),
																		textAlign: TextAlign.center,
																	),
																],
															),
														),
													),
												);
											},
										);
									},
								),
								
								const SizedBox(height: 24),
								
								// Description
								if (_selectedMood != null)
									Container(
										padding: const EdgeInsets.all(16),
										decoration: BoxDecoration(
											color: _selectedMood!['color'].withOpacity(0.1),
											borderRadius: BorderRadius.circular(16),
											border: Border.all(
												color: _selectedMood!['color'].withOpacity(0.3),
											),
										),
										child: Row(
											children: [
												Icon(
													Icons.info_outline,
													color: _selectedMood!['color'],
													size: 20,
												),
												const SizedBox(width: 12),
												Expanded(
													child: Text(
														_selectedMood!['description'],
														style: TextStyle(
															color: _selectedMood!['color'],
															fontWeight: FontWeight.w500,
														),
													),
												),
											],
										),
									).animate().fadeIn(duration: 300.ms),
								
								const SizedBox(height: 24),
								
								// Note Input
								TextField(
									controller: _noteController,
									maxLines: 2,
									decoration: InputDecoration(
										hintText: 'What happened today? (optional)',
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(16),
										),
										contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
										prefixIcon: const Icon(Icons.edit_note),
									),
								),
								
								const SizedBox(height: 24),
								
								// Submit Button
								SizedBox(
									width: double.infinity,
									child: ElevatedButton.icon(
										onPressed: _selectedMood != null ? _submitMood : null,
										icon: const Icon(Icons.check),
										label: const Text(
											'Log Mood',
											style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
										),
										style: ElevatedButton.styleFrom(
											padding: const EdgeInsets.symmetric(vertical: 16),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(16),
											),
											backgroundColor: _selectedMood?['color'] ?? Colors.grey,
											foregroundColor: Colors.white,
										),
									),
								),
							],
						),
					),
				),
			),
		);
	}
}

