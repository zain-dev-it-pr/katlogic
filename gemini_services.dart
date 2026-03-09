import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = "API KEY";

  static Future<String> sendMessage(String prompt) async {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    final response = await model.generateContent(
      [Content.text(prompt)],
    );

    return response.text ?? "No response";
  }
}
