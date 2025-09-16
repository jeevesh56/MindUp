import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
		HapticFeedback.lightImpact();
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
						final glow = 6 + 18 * _controller.value;
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

