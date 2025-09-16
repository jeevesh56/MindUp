import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BreathingScreen extends StatefulWidget {
	const BreathingScreen({super.key});

	@override
	State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
	late final AnimationController _controller;

	@override
	void initState() {
		super.initState();
		_controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Breathing Circle')),
			body: Center(
				child: AnimatedBuilder(
					animation: _controller,
					builder: (context, _) {
						final scale = 0.6 + 0.4 * (_controller.value);
						final phase = _controller.value < 0.5 ? 'Inhale' : 'Exhale';
						return Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Container(
									width: 220 * scale,
									height: 220 * scale,
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										color: Theme.of(context).colorScheme.primaryContainer,
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

