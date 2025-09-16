import 'package:flutter/material.dart';
import 'chatbot_service.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatbotScreen extends StatefulWidget {
	const ChatbotScreen({super.key});

	@override
	State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
	final List<ChatMessage> _messages = <ChatMessage>[];
	final TextEditingController _controller = TextEditingController();
	final ChatbotService _service = ChatbotService(
		endpoint: Uri.parse('https://example.com/chatbot'),
	);
	final Uuid _uuid = const Uuid();
	bool _sending = false;

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	Future<void> _send() async {
		final text = _controller.text.trim();
		if (text.isEmpty || _sending) return;
		setState(() => _sending = true);
		_controller.clear();

		final userMsg = ChatMessage(id: _uuid.v4(), role: 'user', text: text, timestamp: DateTime.now());
		setState(() => _messages.add(userMsg));

		if (_service.containsTriggerWords(text)) {
			_showHelplinePopup();
		}

		final reply = await _service.sendMessage(text);
		final botMsg = ChatMessage(id: _uuid.v4(), role: 'bot', text: reply, timestamp: DateTime.now());
		if (mounted) {
			setState(() {
				_messages.add(botMsg);
				_sending = false;
			});
		}
	}

	void _showHelplinePopup() {
		showDialog(
			context: context,
			builder: (ctx) => AlertDialog(
				title: const Text('You are not alone'),
				content: const Text('If you are in immediate danger, please contact your local emergency services. You can also reach out to a helpline for support.'),
				actions: [
					TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
					TextButton(
						onPressed: () {
							launchUrl(Uri.parse('tel:9152987821'));
						},
						child: const Text('Call Helpline'),
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Expanded(
					child: ListView.builder(
						padding: const EdgeInsets.all(12),
						itemCount: _messages.length,
						itemBuilder: (context, index) {
							final m = _messages[index];
							final isUser = m.role == 'user';
							return Align(
								alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
								child: Container(
									margin: const EdgeInsets.symmetric(vertical: 6),
									padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
									decoration: BoxDecoration(
										color: isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
										borderRadius: BorderRadius.circular(12),
									),
									child: Text(
										m.text,
										style: TextStyle(color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant),
									),
								),
							);
						},
					),
				),
				SafeArea(
					child: Padding(
						padding: const EdgeInsets.all(8),
						child: Row(
							children: [
								Expanded(
									child: TextField(
										controller: _controller,
										decoration: const InputDecoration(
											hintText: 'Type your message…',
											border: OutlineInputBorder(),
										),
										onSubmitted: (_) => _send(),
									),
								),
								const SizedBox(width: 8),
								IconButton(
									icon: _sending ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
									onPressed: _sending ? null : _send,
								),
							],
						),
					),
				),
			],
		);
	}
}
