import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
	final String id;
	final String role; // 'user' or 'bot'
	final String text;
	final DateTime timestamp;

	ChatMessage({required this.id, required this.role, required this.text, required this.timestamp});
}

class ChatbotService {
	final Uri endpoint;
	final Map<String, String> headers;

	ChatbotService({required this.endpoint, Map<String, String>? headers}) : headers = headers ?? const {'Content-Type': 'application/json'};

	static const List<String> triggerWords = [
		'suicide', 'self harm', 'self-harm', 'kill myself', 'end my life', 'hurt myself',
	];

	bool containsTriggerWords(String text) {
		final lower = text.toLowerCase();
		return triggerWords.any((w) => lower.contains(w));
	}

	Future<String> sendMessage(String userText) async {
		// Placeholder payload; adapt for Dialogflow/Rasa/HuggingFace as needed.
		final body = jsonEncode({'message': userText});
		try {
			final res = await http.post(endpoint, headers: headers, body: body).timeout(const Duration(seconds: 20));
			if (res.statusCode >= 200 && res.statusCode < 300) {
				final data = jsonDecode(res.body);
				// Expecting { reply: "..." }
				return (data['reply'] as String?)?.trim().isNotEmpty == true ? data['reply'] : 'I am here for you. Tell me more.';
			}
			return 'I am here for you. Tell me more.';
		} catch (_) {
			return 'I am here for you. Tell me more.';
		}
	}
}

