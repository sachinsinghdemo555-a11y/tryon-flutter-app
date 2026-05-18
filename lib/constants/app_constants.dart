import 'package:flutter/material.dart';

class AppConstants {
  // ── Vertex AI / Gemini API ────────────────────────────────────────────────
  // NOTE: Keep this key private. Do not commit to public repositories.
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  // Vertex AI publisher endpoint (trailing slash intentional — model name appended directly)
  // Final URL: https://aiplatform.googleapis.com/v1/publishers/google/models/{model}:generateContent?key=...
  static const String geminiBaseUrl =
      'https://aiplatform.googleapis.com/v1/publishers/google/models/';

  // Models tried in order — first successful image response wins
  static const List<String> geminiModels = [
    'gemini-2.5-flash-image',
    //'gemini-2.0-flash-exp-image-generation',
    //'gemini-2.0-flash-preview-image-generation',
  ];

  // ── Brand Colours ─────────────────────────────────────────────────────────
  static const Color goldColor      = Color(0xFFD4AF37);
  static const Color darkGold       = Color(0xFFB8860B);
  static const Color lightGold      = Color(0xFFFFF3CD);
  static const Color deepPurple     = Color(0xFF4A1080);
  static const Color backgroundColor = Color(0xFFFAF7FF);
}
