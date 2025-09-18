import 'dart:convert';
import 'package:http/http.dart' as http;

class RasaClient {
	// Configure via --dart-define=RASA_URL=http://localhost:5005
	static const String _baseUrl = String.fromEnvironment('RASA_URL', defaultValue: '');

	Future<String?> sendMessage({required String senderId, required String message}) async {
		if (_baseUrl.isEmpty) return null;
		try {
			final uri = Uri.parse('$_baseUrl/webhooks/rest/webhook');
			final res = await http.post(
				uri,
				headers: const {'Content-Type': 'application/json'},
				body: jsonEncode({'sender': senderId, 'message': message}),
			).timeout(const Duration(seconds: 12));
			if (res.statusCode < 200 || res.statusCode >= 300) return null;
			final data = jsonDecode(res.body);
			if (data is List && data.isNotEmpty) {
				final first = data[0];
				if (first is Map && first['text'] is String) return (first['text'] as String).trim();
			}
			return null;
		} catch (_) {
			return null;
		}
	}
}






