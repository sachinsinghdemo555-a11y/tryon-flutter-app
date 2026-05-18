import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class GeminiResult {
  final bool isSuccess;
  final Uint8List? imageData;
  final String? textResponse;
  final String? errorMessage;
  final bool isTextOnly;

  const GeminiResult._({
    required this.isSuccess,
    this.imageData,
    this.textResponse,
    this.errorMessage,
    this.isTextOnly = false,
  });

  factory GeminiResult.success(Uint8List imageData, [String? text]) =>
      GeminiResult._(isSuccess: true, imageData: imageData, textResponse: text);

  factory GeminiResult.textOnly(String text) =>
      GeminiResult._(isSuccess: true, textResponse: text, isTextOnly: true);

  factory GeminiResult.error(String message) =>
      GeminiResult._(isSuccess: false, errorMessage: message);
}

class GeminiService {
  /// Tries each model in [AppConstants.geminiModels] in order.
  /// Returns the first successful image result, or the last error.
  Future<GeminiResult> generateTryOnImage({
    required Uint8List userImage,
    required String productName,
    required String productType,
    required String productDescription,
    Uint8List? productImage,
  }) async {
    final String promptText = productImage != null
        ? '''
You are a professional virtual jewellery try-on AI.
I have provided TWO images:
  Image 1 - a photo of a person (the customer)
  Image 2 - a jewellery product: "$productName" ($productType)

Task: Generate a single photorealistic image showing the SAME person from Image 1
naturally wearing the jewellery from Image 2.

Guidelines:
- Preserve the person's face, skin tone, hair, and overall appearance exactly.
- Position the jewellery correctly (neck for necklaces, ears for earrings, wrist for bracelets, fingers for rings).
- Ensure realistic lighting, shadows, and reflections on the jewellery.
- The jewellery must be clearly visible and look premium.
- Keep the original background or use a soft elegant studio backdrop.
'''
        : '''
You are a professional virtual jewellery try-on AI.
I have provided ONE image: a photo of a person (the customer).

Task: Generate a single photorealistic image showing the SAME person from the photo
naturally wearing the following jewellery:
  Product : $productName
  Type    : $productType
  Details : $productDescription

Guidelines:
- Preserve the person's face, skin tone, hair, and overall appearance exactly.
- Position the jewellery correctly and naturally on the body.
- The jewellery should look high-quality with realistic lighting and reflections.
- Keep the original background or use a soft elegant studio backdrop.
''';

    final List<Map<String, dynamic>> parts = [
      {'text': promptText},
      {
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(userImage),
        }
      },
    ];

    if (productImage != null) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(productImage),
        }
      });
    }

    final requestBody = {
      'contents': [
        {'role': 'user', 'parts': parts}
      ],
      'generationConfig': {
        'responseModalities': ['IMAGE', 'TEXT'],
      },
    };

    GeminiResult lastError = GeminiResult.error('No models available.');

    for (final model in AppConstants.geminiModels) {
      try {
        // Vertex AI endpoint:
        // https://aiplatform.googleapis.com/v1/publishers/google/models/{model}:generateContent?key=...
        // geminiBaseUrl already ends with '/', so no extra '/' before model name.
        final url = Uri.parse(
          //'${AppConstants.geminiBaseUrl}$model:generateContent?key=${AppConstants.geminiApiKey}',
          '${AppConstants.geminiBaseUrl}$model:generateContent?key=${dotenv.env['GEMINI_API_KEY']}',
        );

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 90));

        if (response.statusCode == 200) {
          final result = _parseResponse(jsonDecode(response.body));
          if (result.isSuccess) return result;
          lastError = result;
        } else {
          final err = jsonDecode(response.body);
          final msg = err['error']?['message'] ?? 'HTTP ${response.statusCode}';
          lastError = GeminiResult.error('[$model] $msg');
          if (response.statusCode != 404 && response.statusCode != 400) {
            return lastError;
          }
        }
      } on Exception catch (e) {
        lastError = GeminiResult.error('[$model] Network error: $e');
      }
    }

    return lastError;
  }

  GeminiResult _parseResponse(Map<String, dynamic> data) {
    try {
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        return GeminiResult.error('No candidates in API response.');
      }
      final parts = candidates[0]['content']['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        return GeminiResult.error('Empty parts in API response.');
      }

      Uint8List? imageBytes;
      String? textResponse;

      for (final part in parts) {
        final inlineData = (part['inlineData'] ?? part['inline_data']) as Map?;
        if (inlineData != null) {
          final b64 = inlineData['data'] as String?;
          if (b64 != null) imageBytes = base64Decode(b64);
        } else if (part['text'] != null) {
          textResponse = part['text'] as String;
        }
      }

      if (imageBytes != null) return GeminiResult.success(imageBytes, textResponse);
      if (textResponse != null) return GeminiResult.textOnly(textResponse);
      return GeminiResult.error('Gemini did not return an image. Try again with a clearer photo.');
    } on Exception catch (e) {
      return GeminiResult.error('Failed to parse response: $e');
    }
  }
}
