import 'package:flutter/material.dart';
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
		final icons = [Icons.star, Icons.favorite, Icons.pets, Icons.emoji_emotions, Icons.beach_access, Icons.catching_pokemon];
		final pairs = [...icons.take(6), ...icons.take(6)];
		pairs.shuffle(Random());
		_cards = List.generate(12, (i) => _CardModel(icon: pairs[i]));
		_first = null;
		_second = null;
		_busy = false;
		setState(() {});
	}

	void _tap(int index) async {
		if (_busy) return;
		final card = _cards[index];
		if (card.matched || card.flipped) return;
		setState(() => card.flipped = true);
		if (_first == null) {
			_first = card;
			return;
		}
		_second = card;
		_busy = true;
		await Future.delayed(const Duration(milliseconds: 700));
		if (_first!.icon == _second!.icon) {
			setState(() {
				_first!.matched = true;
				_second!.matched = true;
			});
		} else {
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
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Great job!')));
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
							padding: const EdgeInsets.all(16),
							gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
							itemCount: _cards.length,
							itemBuilder: (context, i) {
								final c = _cards[i];
								return GestureDetector(
									onTap: () => _tap(i),
									child: AnimatedContainer(
										duration: const Duration(milliseconds: 250),
										decoration: BoxDecoration(
											color: c.matched
												? Colors.green.withOpacity(0.7)
												: (c.flipped ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest),
											borderRadius: BorderRadius.circular(12),
										),
									child: Center(
										child: Icon(c.flipped || c.matched ? c.icon : Icons.help_outline),
									),
								),
							);
						},
						),
					),
					Padding(
						padding: const EdgeInsets.all(12),
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

