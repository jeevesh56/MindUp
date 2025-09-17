import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../utils/feedback_controller.dart';

class ZenGardenScreen extends StatefulWidget {
	const ZenGardenScreen({super.key});

	@override
	State<ZenGardenScreen> createState() => _ZenGardenScreenState();
}

class _ZenGardenScreenState extends State<ZenGardenScreen> with SingleTickerProviderStateMixin {
	late final Ticker _ticker;
	final List<_Ripple> _ripples = <_Ripple>[];
	final List<List<Offset>> _rakePaths = <List<Offset>>[];
	final List<Offset> _stones = <Offset>[];
	List<Offset>? _currentPath;

	@override
	void initState() {
		super.initState();
		_ticker = createTicker((_) {
			setState(() {
				final now = DateTime.now();
				_ripples.removeWhere((r) => now.difference(r.start).inMilliseconds > 1200);
			});
		})..start();
	}

	@override
	void dispose() {
		_ticker.dispose();
		super.dispose();
	}

	void _addRipple(Offset p) {
		_ripples.add(_Ripple(center: p, start: DateTime.now()));
	}

	void _onPanStart(DragStartDetails d, Size size) {
		_currentPath = <Offset>[d.localPosition];
		_rakePaths.add(_currentPath!);
	}

	void _onPanUpdate(DragUpdateDetails d, Size size) {
		_currentPath?.add(d.localPosition);
		if (_currentPath != null && _currentPath!.length > 600) {
			_currentPath = <Offset>[_currentPath!.last];
			_rakePaths.add(_currentPath!);
		}
	}

	void _onPanEnd(DragEndDetails d) {
		_currentPath = null;
	}

	@override
	Widget build(BuildContext context) {
		final fb = FeedbackController();
		fb.load();
		return Scaffold(
			appBar: AppBar(
				title: const Text('Zen Garden'),
				actions: [
					ValueListenableBuilder<bool?>(
						valueListenable: fb.soundOverride,
						builder: (context, override, _) {
							final isMuted = (override ?? fb.soundEnabled.value) == false;
							return IconButton(
								tooltip: isMuted ? 'Unmute' : 'Mute',
								icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
								onPressed: () {
									final current = fb.soundOverride.value;
									fb.setSoundOverride(!(current ?? fb.soundEnabled.value));
								},
							);
						},
					),
					IconButton(
						tooltip: 'How to play',
						icon: const Icon(Icons.help_outline),
						onPressed: () => showDialog(context: context, builder: (_) => const AlertDialog(title: Text('Zen Garden'), content: Text('Drag to rake the sand, tap for ripples, double-tap to place stones.'))),
					),
				],
			),
			body: LayoutBuilder(
				builder: (context, constraints) {
					return GestureDetector(
						onTapDown: (d) {
							fb.hapticLight();
							fb.soundClick();
							setState(() => _addRipple(d.localPosition));
						},
						onDoubleTapDown: (d) {
							fb.hapticMedium();
							fb.soundClick();
							setState(() => _stones.add(d.localPosition));
						},
						onPanStart: (e) => setState(() => _onPanStart(e, constraints.biggest)),
						onPanUpdate: (e) => setState(() => _onPanUpdate(e, constraints.biggest)),
						onPanEnd: (e) => setState(() => _onPanEnd(e)),
						child: CustomPaint(
							size: constraints.biggest,
							painter: _ZenGardenPainter(
								colorScheme: Theme.of(context).colorScheme,
								ripples: _ripples,
								rakePaths: _rakePaths,
								stones: _stones,
							),
						),
					);
				},
			),
			bottomNavigationBar: Padding(
				padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
				child: Row(
					children: [
						Expanded(
							child: OutlinedButton.icon(
								icon: const Icon(Icons.refresh),
								label: const Text('Clear garden'),
								onPressed: () => setState(() { _ripples.clear(); _rakePaths.clear(); _stones.clear(); }),
							),
						),
						const SizedBox(width: 8),
						Expanded(
							child: FilledButton.icon(
								icon: const Icon(Icons.emoji_nature),
								label: const Text('Add stone: double-tap'),
								onPressed: () {},
							),
						),
					],
				),
			),
		);
	}
}

class _ZenGardenPainter extends CustomPainter {
	final ColorScheme colorScheme;
	final List<_Ripple> ripples;
	final List<List<Offset>> rakePaths;
	final List<Offset> stones;

	_ZenGardenPainter({required this.colorScheme, required this.ripples, required this.rakePaths, required this.stones});

	@override
	void paint(Canvas canvas, Size size) {
		final sand = Paint()..color = colorScheme.surfaceContainerHighest;
		final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20));
		canvas.drawRRect(rect, sand);

		// Draw gentle gradient lines as base texture
		final texture = Paint()
			..shader = LinearGradient(colors: [colorScheme.surface, colorScheme.surfaceContainerHigh], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Offset.zero & size)
			..blendMode = BlendMode.softLight;
		canvas.drawRRect(rect, texture);

		// Rake paths
		final rakePaint = Paint()
			..color = colorScheme.outline
			..style = PaintingStyle.stroke
			..strokeWidth = 2.0
			..strokeCap = StrokeCap.round
			..strokeJoin = StrokeJoin.round;
		for (final path in rakePaths) {
			final p = Path();
			for (int i = 0; i < path.length; i++) {
				if (i == 0) {
					p.moveTo(path[i].dx, path[i].dy);
				} else {
					p.lineTo(path[i].dx, path[i].dy);
				}
			}
			canvas.drawPath(p, rakePaint);
		}

		// Stones
		final stonePaint = Paint()..color = colorScheme.secondaryContainer;
		for (final s in stones) {
			final r = RRect.fromRectAndRadius(Rect.fromCenter(center: s, width: 36, height: 28), const Radius.circular(12));
			canvas.drawRRect(r, stonePaint);
			final top = Paint()
				..shader = LinearGradient(colors: [colorScheme.onSecondaryContainer.withOpacity(0.15), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Rect.fromCenter(center: s, width: 36, height: 28));
			canvas.drawRRect(r, top);
		}

		// Ripples
		for (final r in ripples) {
			final t = (DateTime.now().difference(r.start).inMilliseconds / 1200).clamp(0.0, 1.0);
			final radius = 10 + t * 80;
			final opacity = (1.0 - t);
			final ripplePaint = Paint()
				..color = colorScheme.primary.withOpacity(0.15 * opacity)
				..style = PaintingStyle.stroke
				..strokeWidth = 2.0;
			canvas.drawCircle(r.center, radius, ripplePaint);
			canvas.drawCircle(r.center, radius * 0.6, ripplePaint..color = ripplePaint.color.withOpacity(0.12 * opacity));
		}

		// Subtle corner ornament
		final petal = Paint()..color = colorScheme.primary.withOpacity(0.10);
		for (int i = 0; i < 6; i++) {
			final angle = i * (math.pi / 3);
			final center = Offset(size.width - 40, 40);
			final p1 = center + Offset(math.cos(angle), math.sin(angle)) * 20;
			canvas.drawCircle(p1, 6, petal);
		}
	}

	@override
	bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Ripple {
	final Offset center;
	final DateTime start;
	_Ripple({required this.center, required this.start});
}


