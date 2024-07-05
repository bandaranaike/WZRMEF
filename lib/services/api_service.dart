import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<String> getSuggestions(Map<String, String> additionalData) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return 'API key is missing or invalid.';
    }

    const url = 'https://api.openai.com/v1/chat/completions';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'You are a career development adviser. You will search the web and find good courses or jobs or both by considering the following user details.'
        },
        {
          'role': 'user',
          'content': 'Please suggest good courses or jobs or both by considering the following user details: ${additionalData.toString()}'
        }
      ],
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 429) {
        return 'Quota exceeded. Please check your plan and billing details.';
      } else {
        return 'Failed to get suggestions. Please try again later.';
      }
    } catch (e) {
      return 'Failed to get suggestions. Please try again later.';
    }
  }
}
