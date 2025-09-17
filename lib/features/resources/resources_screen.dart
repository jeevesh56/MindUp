import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesScreen extends StatelessWidget {
	const ResourcesScreen({super.key});

	@override
	Widget build(BuildContext context) {
		final links = <_LinkItem>[
			_LinkItem('NIMHANS (Bengaluru) - Emergency', 'https://nimhans.ac.in/emergency-services/'),
			_LinkItem('AASRA Suicide Prevention', 'https://www.aasra.info/helpline.html'),
			_LinkItem('Your College Counseling Center', 'https://example.edu/counseling'),
			_LinkItem('WHO: Mental Health Resources', 'https://www.who.int/health-topics/mental-health'),
		];
		return Scaffold(
			appBar: AppBar(title: const Text('Resources')),
			body: ListView.builder(
				itemCount: links.length,
				itemBuilder: (context, i) {
					final item = links[i];
					return ListTile(
						title: Text(item.title),
						subtitle: Text(item.url),
						leading: const Icon(Icons.link),
						onTap: () => launchUrl(Uri.parse(item.url), mode: LaunchMode.externalApplication),
					);
				},
			),
		);
	}
}

class _LinkItem {
	final String title;
	final String url;
	const _LinkItem(this.title, this.url);
}


