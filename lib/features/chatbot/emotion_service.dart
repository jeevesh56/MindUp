import 'dart:convert';
import 'package:http/http.dart' as http;

class EmotionService {
	// Provide the key via: flutter run --dart-define=HUGGINGFACE_API_KEY=your_key
	static const String _apiKey = String.fromEnvironment('HUGGINGFACE_API_KEY');
	static const String _modelUrl = 'https://api-inference.huggingface.co/models/j-hartmann/emotion-english-distilroberta-base';

	Future<String?> analyzeEmotion(String text) async {
		if (_apiKey.isEmpty) return null;
		try {
			final response = await http.post(
				Uri.parse(_modelUrl),
				headers: {
					'Authorization': 'Bearer $_apiKey',
					'Content-Type': 'application/json',
				},
				body: jsonEncode({'inputs': text}),
			);
			if (response.statusCode != 200) return null;
			final result = jsonDecode(response.body);
			// Expected: List<List<Map<String,dynamic>>> with label/score
			final first = (result as List).isNotEmpty ? result[0] as List : const [];
			if (first.isEmpty) return null;
			final label = first[0]['label'] as String?;
			return label;
		} catch (_) {
			return null;
		}
	}
}



