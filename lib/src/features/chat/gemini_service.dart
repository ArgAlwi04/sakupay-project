// lib/src/features/chat/gemini_service.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash', // atau model lain yang sesuai
          apiKey: dotenv.env['GEMINI_API_KEY']!,
        );

  Future<String> sendMessage(String text) async {
    try {
      final content = [Content.text(text)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Maaf, saya tidak bisa merespons saat ini.';
    } catch (e) {
      print('Error sending message: $e');
      return 'Terjadi kesalahan. Coba lagi nanti.';
    }
  }
}
