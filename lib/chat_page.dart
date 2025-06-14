import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:ecommerce_app/constants.dart';
import 'package:ecommerce_app/helpers/parser.dart';
import 'package:ecommerce_app/models/message_model.dart';
import 'package:ecommerce_app/services/gemini_service.dart';
import 'package:ecommerce_app/widgets/message_widget.dart';
import 'package:ecommerce_app/widgets/message_widget_for_ai.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.email});
  final String email;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final gemini = GeminiService();
  String? feedback;
  Future<String> getReplyFromAI(String message, bool isQuery) async {
    return await gemini.getChatbotResponse(message, isQuery);
  }

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
    CollectionReference messages = FirebaseFirestore.instance.collection(
      '${widget.email}_messages',
    );
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
              leading: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      double rating = 0;
                      TextEditingController feedbackController =
                          TextEditingController();

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: Text("Feedback"),
                            content: SizedBox(
                              width: 300,
                              height: 150,
                              child: Column(
                                children: [
                                  Text(
                                    "Rate your experience",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return IconButton(
                                        onPressed: () {
                                          setState(() {
                                            rating = index + 1;
                                          });
                                        },
                                        icon: Icon(
                                          index < rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                        ),
                                      );
                                    }),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    cursorColor: Colors.black,
                                    controller: feedbackController,

                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      labelText: 'Feedback',
                                    ),
                                    onChanged: (value) {
                                      feedback = value;
                                      debugPrint(feedback);
                                      debugPrint('$rating');
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Skip',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  CherryToast.info(
                                    disableToastAnimation: true,
                                    title: const Text(
                                      'Your shopping assistant',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    action: const Text(
                                      'Thank you for your feedback❤️',
                                    ),
                                    inheritThemeColors: true,
                                    actionHandler: () {},

                                    onToastClosed: () {},
                                  ).show(context);

                                  final dio = Dio();

                                  String? sentiment;
                                  final inputText = "good service";

                                  final url =
                                      'https://api-inference.huggingface.co/models/tabularisai/multilingual-sentiment-analysis';

                                  final token =
                                      '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';

                                  try {
                                    final response = await dio.post(
                                      url,
                                      options: Options(
                                        headers: {
                                          'Authorization': 'Bearer $token',
                                          'Content-Type': 'application/json',
                                        },
                                      ),
                                      data: {'inputs': inputText},
                                    );

                                    final results =
                                        response.data[0] as List<dynamic>;

                                    sentiment = results.reduce(
                                      (a, b) => a['score'] > b['score'] ? a : b,
                                    );
                                  } catch (e) {}
                                  FirebaseFirestore.instance
                                      .collection('feedback')
                                      .add({
                                        'sentiment':
                                            sentiment ??
                                            'No sentiment analysis',
                                        'feedback': feedback,
                                        'rating': rating,
                                      });

                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
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
                      setState(() {
                        isArabic(value)
                            ? direction = TextDirection.rtl
                            : direction = TextDirection.ltr;
                      });
                    },
                    controller: controller,
                    onSubmitted: (value) async {
                      CollectionReference messages = FirebaseFirestore.instance
                          .collection('${widget.email}_messages');
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

                      await FirebaseFirestore.instance
                          .collection('encoded json')
                          .add({'message': mes});
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
                                .collection('${widget.email}_messages');
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
                          await FirebaseFirestore.instance
                              .collection('encoded json')
                              .add({'message': mes});

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
