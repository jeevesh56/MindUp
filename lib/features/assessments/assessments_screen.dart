import 'package:flutter/material.dart';

class AssessmentsScreen extends StatefulWidget {
	const AssessmentsScreen({super.key});

	@override
	State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> with SingleTickerProviderStateMixin {
	late final TabController _tabController = TabController(length: 2, vsync: this);
	final Map<int, int> _phq = <int, int>{};
	final Map<int, int> _gad = <int, int>{};

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Assessments'),
				bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'PHQ-9'), Tab(text: 'GAD-7')]),
			),
			body: TabBarView(
				controller: _tabController,
				children: [
					_buildForm(context, _phq, _phq9, _showPhq),
					_buildForm(context, _gad, _gad7, _showGad),
				],
			),
		);
	}

	Widget _buildForm(BuildContext context, Map<int, int> answers, List<String> questions, void Function(int) onShow) {
		return ListView.builder(
			padding: const EdgeInsets.all(16),
			itemCount: questions.length + 1,
			itemBuilder: (context, index) {
				if (index == questions.length) {
					final total = answers.values.fold<int>(0, (a, b) => a + b);
					return Column(
						children: [
							const SizedBox(height: 12),
							Text('Score: $total', style: Theme.of(context).textTheme.titleMedium),
							const SizedBox(height: 8),
							FilledButton.icon(onPressed: () => onShow(total), icon: const Icon(Icons.check_circle), label: const Text('View result')),
						],
					);
				}
				final selected = answers[index] ?? -1;
				return Card(
					child: Padding(
						padding: const EdgeInsets.all(12),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text('${index + 1}. ${questions[index]}', style: Theme.of(context).textTheme.titleMedium),
								for (final e in _options.entries)
									RadioListTile<int>(
										value: e.key,
										groupValue: selected,
										title: Text(e.value),
										onChanged: (v) => setState(() => answers[index] = v ?? 0),
									),
							],
						),
					),
				);
			},
		);
	}

	void _showPhq(int score) {
		final s = _phqSeverity(score);
		_showResult(title: 'PHQ-9 Result', score: score, severity: s, recommendation: _phqRecommendation(s));
	}

	void _showGad(int score) {
		final s = _gadSeverity(score);
		_showResult(title: 'GAD-7 Result', score: score, severity: s, recommendation: _gadRecommendation(s));
	}

	void _showResult({required String title, required int score, required String severity, required String recommendation}) {
		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: Text(title),
				content: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Text('Score: $score'),
						const SizedBox(height: 8),
						Text('Severity: $severity', style: Theme.of(context).textTheme.titleMedium),
						const SizedBox(height: 8),
						Text(recommendation),
					],
				),
				actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
			),
		);
	}
}

const List<String> _phq9 = <String>[
	'Little interest or pleasure in doing things',
	'Feeling down, depressed, or hopeless',
	'Trouble falling or staying asleep, or sleeping too much',
	'Feeling tired or having little energy',
	'Poor appetite or overeating',
	'Feeling bad about yourself — or that you are a failure',
	'Trouble concentrating on things',
	'Moving or speaking so slowly; or being fidgety or restless',
	'Thoughts that you would be better off dead, or of hurting yourself',
];

const List<String> _gad7 = <String>[
	'Feeling nervous, anxious, or on edge',
	'Not being able to stop or control worrying',
	'Worrying too much about different things',
	'Trouble relaxing',
	'Being so restless that it is hard to sit still',
	'Becoming easily annoyed or irritable',
	'Feeling afraid as if something awful might happen',
];

const Map<int, String> _options = <int, String>{
	0: 'Not at all (0)',
	1: 'Several days (1)',
	2: 'More than half the days (2)',
	3: 'Nearly every day (3)',
};

String _phqSeverity(int score) {
	if (score <= 4) return 'Minimal';
	if (score <= 9) return 'Mild';
	if (score <= 14) return 'Moderate';
	if (score <= 19) return 'Moderately severe';
	return 'Severe';
}

String _gadSeverity(int score) {
	if (score <= 4) return 'Minimal';
	if (score <= 9) return 'Mild';
	if (score <= 14) return 'Moderate';
	return 'Severe';
}

String _phqRecommendation(String severity) {
	switch (severity) {
		case 'Minimal':
			return 'Maintain healthy habits and monitor your mood.';
		case 'Mild':
			return 'Consider self-help strategies and check-in weekly.';
		case 'Moderate':
			return 'Consider counseling; reach out to campus support.';
		case 'Moderately severe':
			return 'Seek professional support soon; talk to a counselor.';
		default:
			return 'Seek professional help immediately. If in crisis, use SOS.';
	}
}

String _gadRecommendation(String severity) {
	switch (severity) {
		case 'Minimal':
			return 'Great! Maintain routines and resilience skills.';
		case 'Mild':
			return 'Try breathing exercises and sleep hygiene.';
		case 'Moderate':
			return 'Counseling or peer support recommended.';
		default:
			return 'Please connect with professional support. Consider SOS resources.';
	}
}
