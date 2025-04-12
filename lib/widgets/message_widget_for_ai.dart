import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageWidgetForAI extends StatelessWidget {
  const MessageWidgetForAI({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: MarkdownBody(
          onTapLink: (text, href, title) async {
            Uri url = Uri.parse(href!);
            await launchUrl(
              url,
              mode: LaunchMode.platformDefault,
              webOnlyWindowName: '_blank',
            );
          },
          selectable: true,
          data: message,
          styleSheet: MarkdownStyleSheet.fromTheme(
            Theme.of(context),
          ).copyWith(p: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
