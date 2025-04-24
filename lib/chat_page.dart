import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/constants.dart';
import 'package:ecommerce_app/helpers/parser.dart';
import 'package:ecommerce_app/models/message_model.dart';
import 'package:ecommerce_app/services/gemini_service.dart';
import 'package:ecommerce_app/widgets/message_widget.dart';
import 'package:ecommerce_app/widgets/message_widget_for_ai.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final gemini = GeminiService();

  Future<String> getReplyFromAI(String message, bool isQuery) async {
    return await gemini.getChatbotResponse(message, isQuery);
  }

  CollectionReference messages = FirebaseFirestore.instance.collection(
    kMessagesCollection,
  );

  final _controller = ScrollController();
  String? message;
  FocusNode focusNode = FocusNode();

  TextDirection direction = TextDirection.ltr;

  TextEditingController controller = TextEditingController();

  bool isArabic(String text) {
    final RegExp arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  Future<String> runQuery(String jsonQuery) async {
    try {
      final query = parseFirestoreQuery(jsonQuery);
      final snapshot = await query.get();

      final data =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      if (data.isEmpty) return 'No results found.';

      // Format results as a readable string
      String formatted = data
          .map((doc) {
            return doc.entries.map((e) => '${e.key}: ${e.value}').join(', ');
          })
          .join('\n');

      return formatted;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: messages.orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<MessageModel> messageList = [];

          for (var i = 0; i < snapshot.data!.docs.length; i++) {
            messageList.add(
              MessageModel(
                snapshot.data!.docs[i].get(kMessage),
                snapshot.data!.docs[i].get(kDate),
                snapshot.data!.docs[i].get(kSender),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Your Shopping Assistant",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: kPrimaryColor,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    reverse: true,

                    itemBuilder: (context, index) {
                      return messageList[index].sender == 'me'
                          ? MessageWidget(message: messageList[index].message)
                          : Directionality(
                            textDirection:
                                isArabic(messageList[index].message)
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                            child: MessageWidgetForAI(
                              message: messageList[index].message,
                            ),
                          );
                    },
                    itemCount: snapshot.data!.size,
                  ),
                ),
                SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                    left: 10,
                    bottom: 5,
                    top: 5,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 20,
                    textDirection: direction,
                    focusNode: focusNode,
                    showCursor: true,
                    onChanged: (value) {
                      message = value;
                      debugPrint('message: $message');
                      setState(() {
                        isArabic(value)
                            ? direction = TextDirection.rtl
                            : direction = TextDirection.ltr;
                      });
                    },
                    controller: controller,
                    onSubmitted: (value) async {
                      CollectionReference messages = FirebaseFirestore.instance
                          .collection(kMessagesCollection);
                      messages.add({
                        'message': value,
                        'date': DateTime.now(),
                        'sender': 'me',
                      });

                      controller.clear();
                      FocusScope.of(context).requestFocus(focusNode);

                      _controller.animateTo(
                        _controller.position.minScrollExtent,
                        duration: Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                      );
                      String mes = await getReplyFromAI(value, true);
                      mes = mes.substring(7);
                      mes = mes.replaceFirst('```', '');

                      mes = await runQuery(mes);

                      mes = await getReplyFromAI(
                        'Summarize this in a professional way without tables and without any other text in bullet points +\n $mes',
                        false,
                      );

                      messages.add({
                        'message': mes,
                        'date': DateTime.now(),
                        'sender': 'AI',
                      });
                      _controller.animateTo(
                        _controller.position.minScrollExtent,
                        duration: Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                      );
                    },
                    decoration: InputDecoration(
                      hintText: "Send a Message",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () async {
                          if (message != null || message!.isNotEmpty) {
                            CollectionReference messages = FirebaseFirestore
                                .instance
                                .collection(kMessagesCollection);
                            messages.add({
                              'message': message,
                              'date': DateTime.now(),
                              'sender': 'me',
                            });
                            _controller.animateTo(
                              _controller.position.minScrollExtent,
                              duration: Duration(seconds: 1),
                              curve: Curves.fastOutSlowIn,
                            );
                          }

                          controller.clear();
                          FocusScope.of(context).requestFocus(focusNode);

                          String mes = await getReplyFromAI(message!, true);

                          mes = mes.substring(7);
                          mes = mes.replaceFirst('```', '');
                          // mes = mes.replaceAll(RegExp(r'\s'), '');

                          mes = await runQuery(mes);
                          mes = await getReplyFromAI(
                            '$mes, Summarize this in a professional way without tables in bullet points and but the Link in bold format ',
                            false,
                          );

                          messages.add({
                            'message': mes,
                            'date': DateTime.now(),
                            'sender': 'AI',
                          });
                          _controller.animateTo(
                            _controller.position.minScrollExtent,
                            duration: Duration(seconds: 1),
                            curve: Curves.fastOutSlowIn,
                          );
                        },
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
