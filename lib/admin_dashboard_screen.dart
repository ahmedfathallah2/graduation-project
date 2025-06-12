import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final WebViewController _controller;

  // Replace this with your actual Power BI embed URL
  final String powerBiEmbedUrl = "https://app.powerbi.com/view?r=eyJrIjoiOGVhMzkwZDYtOTUzMy00ZmQ4LTkzMDAtZjY0OGY5Yjc3YzY5IiwidCI6ImVhZjYyNGM4LWEwYzQtNDE5NS04N2QyLTQ0M2U1ZDc1MTZjZCIsImMiOjh9";
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(powerBiEmbedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
