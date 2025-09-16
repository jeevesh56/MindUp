import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class MemoryMatchScreen extends StatefulWidget {
	const MemoryMatchScreen({super.key});

	@override
	State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
	late List<_CardModel> _cards;
	_CardModel? _first;
	_CardModel? _second;
	bool _busy = false;

	@override
	void initState() {
		super.initState();
		_reset();
	}

	void _reset() {
		final icons = [
			Icons.star, Icons.favorite, Icons.pets, Icons.emoji_emotions, Icons.beach_access, Icons.catching_pokemon, Icons.coffee, Icons.music_note
		];
		final pairs = [...icons.take(8), ...icons.take(8)];
		pairs.shuffle(Random());
		_cards = List.generate(16, (i) => _CardModel(icon: pairs[i]));
		_first = null;
		_second = null;
		_busy = false;
		setState(() {});
	}

	void _tap(int index) async {
		if (_busy) return;
		final card = _cards[index];
		if (card.matched || card.flipped) return;
		
		HapticFeedback.lightImpact();
		setState(() => card.flipped = true);
		
		if (_first == null) {
			_first = card;
			return;
		}
		_second = card;
		_busy = true;
		await Future.delayed(const Duration(milliseconds: 500));
		
		if (_first!.icon == _second!.icon) {
			HapticFeedback.mediumImpact();
			setState(() {
				_first!.matched = true;
				_second!.matched = true;
			});
		} else {
			HapticFeedback.heavyImpact();
			setState(() {
				_first!.flipped = false;
				_second!.flipped = false;
			});
		}
		_first = null;
		_second = null;
		_busy = false;
		if (_cards.every((c) => c.matched)) {
			if (!mounted) return;
			HapticFeedback.heavyImpact();
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Great job! 🎉')));
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Memory Match')),
			body: Column(
				children: [
					Expanded(
						child: GridView.builder(
							padding: const EdgeInsets.all(12),
							gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
								crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10,
								childAspectRatio: 0.8,
							),
							itemCount: _cards.length,
							itemBuilder: (context, i) {
								final c = _cards[i];
								return GestureDetector(
									onTap: () => _tap(i),
									child: AnimatedContainer(
										duration: const Duration(milliseconds: 220),
										decoration: BoxDecoration(
											color: c.matched
												? Colors.green.withValues(alpha: 0.7)
												: (c.flipped ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest),
											borderRadius: BorderRadius.circular(10),
											boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
										),
									child: Center(
										child: Icon(c.flipped || c.matched ? c.icon : Icons.help_outline, size: 26),
									),
								),
							);
						},
						),
					),
					Padding(
						padding: const EdgeInsets.all(8),
						child: ElevatedButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('Reset')),
					),
				],
			),
		);
	}
}

class _CardModel {
	final IconData icon;
	bool flipped = false;
	bool matched = false;
	_CardModel({required this.icon});
}

