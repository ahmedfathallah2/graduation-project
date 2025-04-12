import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GeminiService {
  final String _apiKey = 'AIzaSyAs8ZS7433c10CsR7dNKNo3ohFB8S2J8RI';
  final Dio _dio = Dio();

  Future<String> getChatbotResponse(String prompt) async {
    final String url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey';

    final headers = {'Content-Type': 'application/json'};

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    };

    try {
      final response = await _dio.post(
        url,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final content =
            response.data['candidates'][0]['content']['parts'][0]['text'];
        return content;
      } else {
        debugPrint('Error: ${response.data}'); //NOTE
        return 'Connection error';
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return 'Connection error';
    }
  }
}
