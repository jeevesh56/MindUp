import 'package:flutter/material.dart';
import '../../utils/feedback_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BreathingScreen extends StatefulWidget {
	const BreathingScreen({super.key});

	@override
	State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
	late final AnimationController _controller;
	final FeedbackController _fb = FeedbackController();
	bool _wasInhale = true;

	@override
	void initState() {
		super.initState();
		_controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
		_fb.load();
		_fb.hapticLight();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Breathing Circle'),
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
						tooltip: 'How to breathe',
						icon: const Icon(Icons.help_outline),
						onPressed: () => showDialog(context: context, builder: (_) => const AlertDialog(title: Text('Breathing Pacer'), content: Text('Follow the circle: Inhale as it grows, exhale as it shrinks. Try 3–5 minutes.'))),
					),
				],
			),
			body: Center(
				child: AnimatedBuilder(
					animation: _controller,
					builder: (context, _) {
						final isInhale = _controller.value < 0.5;
						final scale = isInhale ? 0.6 + 0.4 * (_controller.value * 2) : 1.0 - 0.4 * ((_controller.value - 0.5) * 2);
						if (_wasInhale != isInhale) {
							_wasInhale = isInhale;
							_fb.hapticLight();
							_fb.soundClick();
						}
						final phase = isInhale ? 'Inhale' : 'Exhale';
						final glow = isInhale ? 6 + 18 * (_controller.value * 2) : 24 - 18 * ((_controller.value - 0.5) * 2);
						return Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								AnimatedContainer(
									duration: const Duration(milliseconds: 600),
									curve: Curves.easeInOut,
									width: 220 * scale,
									height: 220 * scale,
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										gradient: RadialGradient(colors: [
											Theme.of(context).colorScheme.primaryContainer,
											Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
										]),
										boxShadow: [
											BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4), blurRadius: glow, spreadRadius: 2),
										],
									),
								)
									.animate(target: (_controller.value * 10).roundToDouble())
									.scale(duration: 1200.ms),
								const SizedBox(height: 16),
								Text(phase, style: Theme.of(context).textTheme.titleLarge),
							],
						);
					},
				),
			),
		);
	}
}

