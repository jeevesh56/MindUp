import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/feedback_controller.dart';

class ColorDriftScreen extends StatefulWidget {
	const ColorDriftScreen({super.key});

	@override
	State<ColorDriftScreen> createState() => _ColorDriftScreenState();
}

class _ColorDriftScreenState extends State<ColorDriftScreen> with SingleTickerProviderStateMixin {
	late final AnimationController _controller;
	final FeedbackController _fb = FeedbackController();
	final math.Random _rand = math.Random();
	
	Color _targetColor = Colors.blue;
	Color _currentColor = Colors.blue;
	int _score = 0;
	int _streak = 0;
	bool _isPlaying = false;
	
	@override
	void initState() {
		super.initState();
		_controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
		_fb.load();
		_generateNewTarget();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	void _generateNewTarget() {
		final colors = [
			Colors.red, Colors.blue, Colors.green, Colors.orange,
			Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
			Colors.amber, Colors.cyan, Colors.lime, Colors.deepOrange,
		];
		_targetColor = colors[_rand.nextInt(colors.length)];
		_currentColor = _targetColor;
	}

	void _adjustColor(double delta) {
		if (!_isPlaying) return;
		
		final hsl = HSLColor.fromColor(_currentColor);
		final newLightness = (hsl.lightness + delta * 0.1).clamp(0.0, 1.0);
		_currentColor = HSLColor.fromAHSL(hsl.alpha, hsl.hue, hsl.saturation, newLightness).toColor();
		
		_fb.hapticLight();
		setState(() {});
	}

	void _checkMatch() {
		if (!_isPlaying) return;
		
		final targetHsl = HSLColor.fromColor(_targetColor);
		final currentHsl = HSLColor.fromColor(_currentColor);
		final lightnessDiff = (targetHsl.lightness - currentHsl.lightness).abs();
		final tolerance = 0.15;
		
		if (lightnessDiff <= tolerance) {
			_score += 10 + (_streak * 5);
			_streak++;
			_fb.hapticMedium();
			_fb.soundClick();
			_generateNewTarget();
		} else {
			_streak = 0;
		}
		setState(() {});
	}

	void _startGame() {
		_isPlaying = true;
		_score = 0;
		_streak = 0;
		_generateNewTarget();
		_fb.hapticLight();
		setState(() {});
	}

	void _pauseGame() {
		_isPlaying = false;
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Color Drift'),
				actions: [
					ValueListenableBuilder<bool?>(
						valueListenable: _fb.soundOverride,
						builder: (context, override, _) {
							final isMuted = (override ?? _fb.soundEnabled.value) == false;
							return IconButton(
								tooltip: isMuted ? 'Unmute' : 'Mute',
								icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
								onPressed: () {
									final current = _fb.soundOverride.value;
									_fb.setSoundOverride(!(current ?? _fb.soundEnabled.value));
								},
							);
						},
					),
					IconButton(
						tooltip: 'How to play',
						icon: const Icon(Icons.help_outline),
						onPressed: () => showDialog(
							context: context, 
							builder: (_) => const AlertDialog(
								title: Text('Color Drift'),
								content: Text('🎯 Match the TOP color with the BOTTOM color\n\n➕ Tap + to make color brighter\n➖ Tap - to make color darker\n\n✅ Tap your color circle to check if it matches!\n\n🎨 Focus on colors to relax your mind')
							)
						),
					),
				],
			),
			body: Padding(
				padding: const EdgeInsets.all(24),
				child: Column(
					children: [
						if (_isPlaying) ...[
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceEvenly,
								children: [
									Column(
										children: [
											Text('Score', style: Theme.of(context).textTheme.titleMedium),
											Text('$_score', style: Theme.of(context).textTheme.headlineMedium),
										],
									),
									Column(
										children: [
											Text('Streak', style: Theme.of(context).textTheme.titleMedium),
											Text('$_streak', style: Theme.of(context).textTheme.headlineMedium),
										],
									),
								],
							),
							const SizedBox(height: 32),
						],
						Expanded(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									if (_isPlaying) ...[
										Text('Target Color', style: Theme.of(context).textTheme.titleLarge),
										const SizedBox(height: 16),
										Container(
											width: 120,
											height: 120,
											decoration: BoxDecoration(
												color: _targetColor,
												shape: BoxShape.circle,
												boxShadow: [
													BoxShadow(
														color: _targetColor.withOpacity(0.3),
														blurRadius: 20,
														spreadRadius: 5,
													),
												],
											),
										),
										const SizedBox(height: 32),
										Text('Your Color', style: Theme.of(context).textTheme.titleLarge),
										const SizedBox(height: 16),
										GestureDetector(
											onTap: _checkMatch,
											child: AnimatedBuilder(
												animation: _controller,
												builder: (context, child) {
													return Container(
														width: 120,
														height: 120,
														decoration: BoxDecoration(
															color: _currentColor,
															shape: BoxShape.circle,
															boxShadow: [
																BoxShadow(
																	color: _currentColor.withOpacity(0.3),
																	blurRadius: 20,
																	spreadRadius: 5,
																),
															],
														),
													);
												},
											),
										),
										const SizedBox(height: 32),
										Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												IconButton(
													onPressed: () => _adjustColor(-1),
													icon: const Icon(Icons.remove_circle_outline),
													iconSize: 48,
												),
												const SizedBox(width: 32),
												IconButton(
													onPressed: () => _adjustColor(1),
													icon: const Icon(Icons.add_circle_outline),
													iconSize: 48,
												),
											],
										),
									] else ...[
										Icon(
											Icons.palette,
											size: 120,
											color: Theme.of(context).colorScheme.primary,
										),
										const SizedBox(height: 24),
										Text(
											'Color Drift',
											style: Theme.of(context).textTheme.headlineMedium,
										),
										const SizedBox(height: 16),
										Text(
											'A calming color-matching meditation game',
											style: Theme.of(context).textTheme.bodyLarge,
											textAlign: TextAlign.center,
										),
									],
								],
							),
						),
						const SizedBox(height: 24),
						if (_isPlaying)
							FilledButton.icon(
								icon: const Icon(Icons.pause),
								label: const Text('Pause'),
								onPressed: _pauseGame,
							)
						else
							FilledButton.icon(
								icon: const Icon(Icons.play_arrow),
								label: const Text('Start'),
								onPressed: _startGame,
							),
					],
				),
			),
		);
	}
}
