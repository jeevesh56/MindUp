import 'package:flutter/material.dart';
import 'breathing_screen.dart';
import 'memory_match_screen.dart';
import 'bubble_pop_screen.dart';

class GamesHubScreen extends StatelessWidget {
	const GamesHubScreen({super.key});

	void _open(BuildContext context, Widget page) {
		Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
	}

	@override
	Widget build(BuildContext context) {
		return ListView(
			padding: const EdgeInsets.all(16),
			children: [
				ListTile(
					leading: const Icon(Icons.bubble_chart),
					title: const Text('Bubble Pop'),
					onTap: () => _open(context, const BubblePopScreen()),
				),
				ListTile(
					leading: const Icon(Icons.self_improvement),
					title: const Text('Breathing Circle'),
					onTap: () => _open(context, const BreathingScreen()),
				),
				ListTile(
					leading: const Icon(Icons.grid_view),
					title: const Text('Memory Match'),
					onTap: () => _open(context, const MemoryMatchScreen()),
				),
			],
		);
	}
}
