import 'package:flutter/material.dart';
import 'dart:math';

class BubblePopScreen extends StatefulWidget {
	const BubblePopScreen({super.key});

	@override
	State<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen> {
	final Random _rand = Random();
	int _score = 0;
	List<Offset> _bubbles = <Offset>[];

	@override
	void initState() {
		super.initState();
		_spawn();
	}

	void _spawn() {
		_bubbles = List.generate(6, (_) => Offset(_rand.nextDouble(), _rand.nextDouble()));
		setState(() {});
	}

	void _tap(Size size, TapDownDetails details) {
		final tapPos = details.localPosition;
		final toRemove = <Offset>[];
		for (final b in _bubbles) {
			final pos = Offset(b.dx * size.width, b.dy * size.height);
			if ((pos - tapPos).distance < 36) {
				toRemove.add(b);
			}
		}
		if (toRemove.isNotEmpty) {
			_bubbles.removeWhere((e) => toRemove.contains(e));
			_score += toRemove.length;
			if (_bubbles.isEmpty) _spawn();
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
						child: Stack(
							children: [
								Positioned(
									top: 12,
									left: 12,
									child: Chip(label: Text('Score: $_score')),
								),
								..._bubbles.map((o) {
									final pos = Offset(o.dx * size.width, o.dy * size.height);
									return Positioned(
										left: pos.dx - 24,
										top: pos.dy - 24,
										child: Container(
											width: 48,
											height: 48,
											decoration: BoxDecoration(
												shape: BoxShape.circle,
												color: Colors.lightBlueAccent.withOpacity(0.6),
												boxShadow: const [BoxShadow(color: Colors.blue, blurRadius: 8)],
											),
										),
									);
								}),
							],
						),
					);
				},
			),
		);
	}
}

