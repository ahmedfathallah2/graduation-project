import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

Query parseFirestoreQuery(String jsonString) {
  final Map<String, dynamic> queryMap = json.decode(jsonString);

  String collection = queryMap['collection'];
  List<dynamic>? filters = queryMap['filters'];
  Map<String, dynamic>? orderBy = queryMap['orderBy'];
  int? limit = queryMap['limit'];

  CollectionReference ref = FirebaseFirestore.instance.collection(collection);
  Query query = ref;

  final List<String> rangeOperators = [
    'isGreaterThan',
    'isGreaterThanOrEqualTo',
    'isLessThan',
    'isLessThanOrEqualTo',
  ];

  String? rangeField;

  dynamic parseValue(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      // Try to parse as DateTime (ISO format)
      final isoDateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}');
      if (isoDateRegex.hasMatch(value)) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }

      // Try to parse as bool
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;

      // Try to parse as number
      final numVal = num.tryParse(value);
      if (numVal != null) return numVal;
    }

    // Already supported types: int, double, bool, list, map
    return value;
  }

  // Apply filters
  if (filters != null) {
    for (var filter in filters) {
      String field = filter['field'];
      String operator = filter['operator'];
      dynamic value = parseValue(filter['value']);

      if (rangeOperators.contains(operator)) {
        rangeField = field;
      }

      switch (operator) {
        case 'isEqualTo':
          query = query.where(field, isEqualTo: value);
          break;
        case 'isNotEqualTo':
          query = query.where(field, isNotEqualTo: value);
          break;
        case 'isGreaterThan':
          query = query.where(field, isGreaterThan: value);
          break;
        case 'isGreaterThanOrEqualTo':
          query = query.where(field, isGreaterThanOrEqualTo: value);
          break;
        case 'isLessThan':
          query = query.where(field, isLessThan: value);
          break;
        case 'isLessThanOrEqualTo':
          query = query.where(field, isLessThanOrEqualTo: value);
          break;
        case 'arrayContains':
          query = query.where(field, arrayContains: value);
          break;
        case 'arrayContainsAny':
          query = query.where(field, arrayContainsAny: List.from(value));
          break;
        case 'whereIn':
          query = query.where(field, whereIn: List.from(value));
          break;
        case 'whereNotIn':
          query = query.where(field, whereNotIn: List.from(value));
          break;
        default:
          throw Exception('Unsupported operator: $operator');
      }
    }
  }

  // Check index conflict
  if (orderBy != null && rangeField != null && orderBy['field'] != rangeField) {
    throw Exception(
      '❌ Composite index required. Please use orderBy on the same field as the range filter.',
    );
  }

  // Apply orderBy
  if (orderBy != null) {
    query = query.orderBy(
      orderBy['field'],
      descending: orderBy['descending'] ?? false,
    );
  }

  // Apply limit
  if (limit != null) {
    query = query.limit(limit);
  }

  return query;
}
