import 'package:flutter/material.dart';
import 'chatbot_service.dart';
import 'emotion_service.dart';
import 'rasa_client.dart';
import 'dialogflow_client.dart';
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
	final ScrollController _scroll = ScrollController();
	final ChatbotService _service = ChatbotService(
		endpoint: Uri.parse('https://example.com/chatbot'),
	);
	final EmotionService _emotion = EmotionService();
	final RasaClient _rasa = RasaClient();
	final DialogflowClient _df = DialogflowClient();
	final Uuid _uuid = const Uuid();
	bool _sending = false;
	bool _showEmotion = true;

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

		final emotion = await _emotion.analyzeEmotion(text);
		String? reply;
		String via = '';
		// Try Rasa first
		reply = await _rasa.sendMessage(senderId: _uuid.v4(), message: text);
		if (reply != null) via = 'via Rasa';
		// Fallback to Dialogflow
		if (reply == null) {
			reply = await _df.detectIntent(sessionId: _uuid.v4(), text: text);
			if (reply != null) via = 'via Dialogflow';
		}
		// Fallback to custom backend if both absent
		reply ??= await _service.sendMessage(text);
		if (via.isEmpty) via = 'via Assistant';
		final botMsg = ChatMessage(
			id: _uuid.v4(),
			role: 'bot',
			text: reply,
			timestamp: DateTime.now(),
			emotionLabel: emotion,
			sourceLabel: via,
		);
		if (mounted) {
			setState(() {
				_messages.add(botMsg);
				_sending = false;
			});
			await Future.delayed(const Duration(milliseconds: 50));
			if (mounted && _scroll.hasClients) {
				_scroll.animateTo(_scroll.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
			}
		}
	}

	void _showHelplinePopup() {
		showDialog(
			context: context,
			builder: (ctx) {
				return AlertDialog(
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
				);
			},
		);
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Expanded(
					child: Container(
						margin: const EdgeInsets.all(12),
						decoration: BoxDecoration(
							borderRadius: BorderRadius.circular(16),
							border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
						),
						child: ListView.builder(
							controller: _scroll,
							padding: const EdgeInsets.all(12),
							itemCount: _messages.length,
							itemBuilder: (context, index) {
								final m = _messages[index];
								final isUser = m.role == 'user';
								return Align(
									alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
									child: Column(
										crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
										children: [
											Container(
												margin: const EdgeInsets.symmetric(vertical: 6),
												padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
												decoration: BoxDecoration(
													color: isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
													borderRadius: BorderRadius.circular(12),
													boxShadow: [
														BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
													],
												),
												child: Text(
													m.text,
													style: TextStyle(color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant),
												),
											),
											if (!isUser && (m.sourceLabel != null || (_showEmotion && m.emotionLabel != null)))
												Padding(
													padding: const EdgeInsets.only(top: 2, left: 6, right: 6),
													child: Wrap(
														spacing: 6,
														runSpacing: 4,
														children: [
															if (m.sourceLabel != null) Chip(label: Text(m.sourceLabel!, style: const TextStyle(fontSize: 11))),
															if (_showEmotion && m.emotionLabel != null) Chip(label: Text(m.emotionLabel!, style: const TextStyle(fontSize: 11))),
														],
													),
												),
										],
									),
								);
							},
						),
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
										decoration: InputDecoration(
											hintText: 'Type your message…',
											filled: true,
											fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
											border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
										),
										onSubmitted: (_) => _send(),
								textInputAction: TextInputAction.send,
								autofocus: true,
									),
								),
								const SizedBox(width: 8),
								IconButton(
									tooltip: _showEmotion ? 'Hide emotion labels' : 'Show emotion labels',
									icon: Icon(_showEmotion ? Icons.visibility : Icons.visibility_off),
									onPressed: () => setState(() => _showEmotion = !_showEmotion),
								),
								const SizedBox(width: 4),
								FilledButton.icon(
									icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
									label: const Text('Send'),
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
