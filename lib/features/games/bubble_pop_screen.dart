import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class BubblePopScreen extends StatefulWidget {
	const BubblePopScreen({super.key});

	@override
	State<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen> with TickerProviderStateMixin {
	final Random _rand = Random();
	int _score = 0;
	List<Offset> _bubbles = <Offset>[];
	late final AnimationController _floatController;
	final List<_Particle> _particles = <_Particle>[];

	@override
	void initState() {
		super.initState();
		_floatController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
		_spawn();
	}

	void _spawn() {
		_bubbles = List.generate(10, (_) => Offset(_rand.nextDouble(), _rand.nextDouble()));
		setState(() {});
	}

	void _emitBurst(Offset center) {
		for (int i = 0; i < 12; i++) {
			final angle = _rand.nextDouble() * pi * 2;
			final speed = 40 + _rand.nextDouble() * 80;
			final vx = cos(angle) * speed;
			final vy = sin(angle) * speed;
			_particles.add(_Particle(
				start: center,
				velocity: Offset(vx, vy),
				spawn: DateTime.now(),
				durationMs: 500 + _rand.nextInt(400),
				size: 4 + _rand.nextDouble() * 6,
				color: Colors.blueAccent,
			));
		}
	}

	void _tap(Size size, TapDownDetails details) {
		final tapPos = details.localPosition;
		final toRemove = <Offset>[];
		for (final b in _bubbles) {
			final pos = Offset(b.dx * size.width, b.dy * size.height);
			if ((pos - tapPos).distance < 36) {
				toRemove.add(b);
				_emitBurst(pos);
			}
		}
		if (toRemove.isNotEmpty) {
			HapticFeedback.lightImpact();
			_bubbles.removeWhere((e) => toRemove.contains(e));
			_score += toRemove.length;
			if (_bubbles.isEmpty) {
				HapticFeedback.mediumImpact();
				_spawn();
			}
			setState(() {});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Bubble Pop')),
			body: LayoutBuilder(
				builder: (context, constraints) {
					final size = Size(constraints.maxWidth, constraints.maxHeight);
					return GestureDetector(
						onTapDown: (d) => _tap(size, d),
						child: AnimatedBuilder(
							animation: _floatController,
							builder: (context, _) {
								return Stack(
									children: [
										Positioned(
											top: 12,
											left: 12,
											child: Chip(label: Text('Score: $_score')),
										),
										// Particles
										..._particles.where((p) => !p.isDead).map((p) {
											final age = DateTime.now().difference(p.spawn).inMilliseconds.toDouble();
											final t = (age / p.durationMs).clamp(0.0, 1.0);
											final pos = p.start + p.velocity * t * 0.02; // scale velocity per ms
											final opacity = (1.0 - t);
											if (t >= 1.0) p.isDead = true;
											return Positioned(
												left: pos.dx - p.size / 2,
												top: pos.dy - p.size / 2,
												child: Opacity(
													opacity: opacity,
													child: Container(
														width: p.size,
														height: p.size,
														decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
													),
												),
											);
										}),
										// Bubbles
										..._bubbles.map((o) {
											final base = Offset(o.dx * size.width, o.dy * size.height);
											final floatY = sin((_floatController.value * 2 * 3.14159) + (o.dx * 10)) * 8;
											return Positioned(
												left: base.dx - 24,
												top: base.dy - 24 + floatY,
												child: AnimatedScale(
													duration: const Duration(milliseconds: 300),
													scale: 1.0 + (floatY.abs() / 40),
													child: Container(
														width: 48,
														height: 48,
														decoration: const BoxDecoration(
															shape: BoxShape.circle,
															gradient: LinearGradient(colors: [Colors.lightBlueAccent, Colors.blueAccent]),
															boxShadow: [BoxShadow(color: Colors.blue, blurRadius: 8)],
														),
													),
												),
											);
										}),
									],
								);
							},
						),
					);
				},
			),
		);
	}
}

class _Particle {
	final Offset start;
	final Offset velocity;
	final DateTime spawn;
	final int durationMs;
	final double size;
	final Color color;
	bool isDead = false;
	_Particle({required this.start, required this.velocity, required this.spawn, required this.durationMs, required this.size, required this.color});
}

