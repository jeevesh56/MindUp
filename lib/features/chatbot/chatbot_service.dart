import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
	final String id;
	final String role; // 'user' or 'bot'
	final String text;
	final DateTime timestamp;
	final String? emotionLabel;
	final String? sourceLabel; // Rasa, Dialogflow, Assistant

	ChatMessage({required this.id, required this.role, required this.text, required this.timestamp, this.emotionLabel, this.sourceLabel});

	ChatMessage copyWith({String? id, String? role, String? text, DateTime? timestamp, String? emotionLabel, String? sourceLabel}) {
		return ChatMessage(
			id: id ?? this.id,
			role: role ?? this.role,
			text: text ?? this.text,
			timestamp: timestamp ?? this.timestamp,
			emotionLabel: emotionLabel ?? this.emotionLabel,
			sourceLabel: sourceLabel ?? this.sourceLabel,
		);
	}
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
				final candidate = (data['reply'] as String?)?.trim();
				if (candidate != null && candidate.isNotEmpty) return candidate;
				return _rotatingFallback();
			}
			return _rotatingFallback();
		} catch (_) {
			return _rotatingFallback();
		}
	}

	int _fallbackIndex = 0;
	static const List<String> _fallbacks = [
		"I'm here for you. Tell me more about what's on your mind.",
		"That sounds tough. Would you like to try a breathing exercise?",
		"Thanks for sharing. What would help you feel 1% better right now?",
		"I hear you. Would you like to see campus resources or SOS options?",
	];

	String _rotatingFallback() {
		final reply = _fallbacks[_fallbackIndex % _fallbacks.length];
		_fallbackIndex++;
		return reply;
	}
}



