import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/constants.dart';

class MessageModel {
  final String message;
  final Timestamp date;
  final String sender;

  MessageModel(this.message, this.date, this.sender);

  factory MessageModel.fromJson(Map jsonData) {
    return MessageModel(jsonData[kMessage], jsonData[kDate], jsonData[kSender]);
  }
}
