import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SosHelpScreen extends StatelessWidget {
	const SosHelpScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('SOS Help')),
			body: ListView(
				padding: const EdgeInsets.all(16),
				children: [
					Card(
						color: Theme.of(context).colorScheme.errorContainer,
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text('If you are in immediate danger, contact local emergency services.', style: Theme.of(context).textTheme.bodyMedium),
									const SizedBox(height: 12),
									Wrap(
										spacing: 12,
										runSpacing: 12,
										children: [
											ElevatedButton.icon(onPressed: () => _dial('112'), icon: const Icon(Icons.call), label: const Text('Call 112')),
											ElevatedButton.icon(onPressed: () => _open('https://www.aasra.info/helpline.html'), icon: const Icon(Icons.support_agent), label: const Text('India Helplines')),
										],
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Text('Safety Plan', style: Theme.of(context).textTheme.titleMedium),
					const SizedBox(height: 8),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: const [
									_TextBullet('Warning signs I notice'),
									_TextBullet('Coping strategies I can try'),
									_TextBullet('People and places that can help'),
									_TextBullet('Professionals I can contact'),
								],
							),
						),
					),
				],
			),
		);
	}

	static Future<void> _dial(String number) async {
		final uri = Uri(scheme: 'tel', path: number);
		await launchUrl(uri);
	}

	static Future<void> _open(String url) async {
		await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
	}
}

class _TextBullet extends StatelessWidget {
	final String text;
	const _TextBullet(this.text);
	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text('• '),
					Expanded(child: Text(text)),
				],
			),
		);
	}
}






