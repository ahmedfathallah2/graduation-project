import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GeminiService {
  final String _apiKey = 'AIzaSyAs8ZS7433c10CsR7dNKNo3ohFB8S2J8RI';
  final Dio _dio = Dio();

  String geminiPrompt = """
You are a technical assistant for a mobile application built using Flutter and Firebase Firestore.

Your task is to convert natural language questions into Firestore queries in a structured JSON format that can be parsed and executed easily in Dart code.

Requirements:
- Include the collection name.
- Add filters (like where clauses: isEqualTo, isGreaterThan, etc.).
- Optionally include a limit.
- Optionally include orderBy.

Rules:
- Do not return any Dart or Flutter code.
- Return only a clean JSON object.

Example 1 Question:
suggest me some products with a price greater than 10000
format:
{	
  "collection": "products",
  "filters": [
    {
      "field": "Price_EGP",
      "operator": "isGreaterThan",
      "value": 10000
    }
  ],
  "orderBy": {
    "field": "Price_EGP",
    "descending": true
  },
  "limit": 10
}



Example 2 Question:
	suggest me some products with the brand Dell and with a price greater than 10000
format:
{
  "collection": "products",
  "filters": [
    {
      "field": "Brand",
      "operator": "isEqualTo",
      "value": "Dell"
    },
    {
      "field": "Price_EGP",
      "operator": "isGreaterThan",
      "value": 10000
    }
  ],
  "orderBy": {
    "field": "Price_EGP",
    "descending": true
  },
  "limit": 10
}

Use only Firestore operators supported in Dart SDK such as isEqualTo, isNotEqualTo, isGreaterThan, isLessThan, arrayContains, etc.

Do not add any explanations or descriptions — only return the JSON.
Important return only the json object in the format above
""";

  String collectionMetadata = """
The collection containing the data is called `products`, and each document in that collection has the following fields: 
`Brand` with possible values `Acer`, `Alienware`, `Apple`, `Asus`, `Chuwi`, `Dell`, `Fujitsu`, `Gateway`, `Hp`, `Huawei`, `Lenovo`, `Microsoft`, `Msi`, `Panasonic`, `Razar`, `Samsung`, `Sony`, `Toshiba`;
`Category` with possible values: `Laptop`, `Smartphone`, `Tablet`, `Other`, `Camera`, `Desktop`;
`Subcategory` with possible values: `General Laptop`, `Gaming Laptop`, `Business Laptop`, `Programming Laptop`, `Dual SIM Mobile`, `5G Mobile`, `General Mobile`, `Other`;
 `Link`; `Parsed_Storage`; `Price_EGP`; `Title`.
""";

  String important =

      "return only the json object in the format above don't return any other text in all cases";

  Future<String> getChatbotResponse(String prompt, bool isQuery) async {
    collectionMetadata =
        isQuery
            ? """
The collection containing the data is called `products`, and each document in that collection has the following fields: `Brand`, `Category`, `Link`, `Parsed_Storage`, `Price_EGP`, and `Title`.
"""
            : "";
    geminiPrompt =
        isQuery
            ? """
You are a technical assistant for a mobile application built using Flutter and Firebase Firestore.

Your task is to convert natural language questions into Firestore queries in a structured JSON format that can be parsed and executed easily in Dart code.

Requirements:
- Include the collection name.
- Add filters (like where clauses: isEqualTo, isGreaterThan, etc.).
- Optionally include a limit.
- Optionally include orderBy.

Rules:
- Do not return any Dart or Flutter code.
- Return only a clean JSON object.

Example 1 Question:
suggest me some products with a price greater than 10000
format:
{	
  "collection": "products",
  "filters": [
    {
      "field": "Price_EGP",
      "operator": "isGreaterThan",
      "value": 10000
    }
  ],
  "orderBy": {
    "field": "Price_EGP",
    "descending": true
  },
  "limit": 10
}



Example 2 Question:
	suggest me some products with the brand Dell and with a price greater than 10000
format:
{
  "collection": "products",
  "filters": [
    {
      "field": "Brand",
      "operator": "isEqualTo",
      "value": "Dell"
    },
    {
      "field": "Price_EGP",
      "operator": "isGreaterThan",
      "value": 10000
    }
  ],
  "orderBy": {
    "field": "Price_EGP",
    "descending": true
  },
  "limit": 10
}

Use only Firestore operators supported in Dart SDK such as isEqualTo, isNotEqualTo, isGreaterThan, isLessThan, arrayContains, etc.

Do not add any explanations or descriptions — only return the JSON.
Important return only the json object in the format above
"""
            : "";
    important =
        isQuery
            ? "return only the json object in the format above don't return any other text in all cases"
            : "";

    final String url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey';

    final headers = {'Content-Type': 'application/json'};

    final body = {
      "contents": [
        {
          "parts": [
            {"text": geminiPrompt},
            {"text": collectionMetadata},
            {"text": prompt},
            {"text": important},
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
