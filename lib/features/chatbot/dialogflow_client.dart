import 'dart:convert';
import 'package:http/http.dart' as http;

class DialogflowClient {
	// Configure via --dart-define=DF_PROJECT_ID=... --dart-define=DF_ACCESS_TOKEN=...
	static const String _projectId = String.fromEnvironment('DF_PROJECT_ID', defaultValue: '');
	static const String _accessToken = String.fromEnvironment('DF_ACCESS_TOKEN', defaultValue: '');

	Future<String?> detectIntent({required String sessionId, required String text, String languageCode = 'en'}) async {
		if (_projectId.isEmpty || _accessToken.isEmpty) return null;
		try {
			final uri = Uri.parse('https://dialogflow.googleapis.com/v2/projects/$_projectId/agent/sessions/$sessionId:detectIntent');
			final body = {
				'queryInput': {
					'text': {'text': text, 'languageCode': languageCode}
				}
			};
			final res = await http.post(
				uri,
				headers: {
					'Authorization': 'Bearer $_accessToken',
					'Content-Type': 'application/json',
				},
				body: jsonEncode(body),
			).timeout(const Duration(seconds: 12));
			if (res.statusCode < 200 || res.statusCode >= 300) return null;
			final data = jsonDecode(res.body) as Map<String, dynamic>;
			final fulfillment = (data['queryResult'] as Map?)?['fulfillmentText'] as String?;
			return fulfillment?.trim().isEmpty == true ? null : fulfillment;
		} catch (_) {
			return null;
		}
	}
}



