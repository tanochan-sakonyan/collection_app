import 'package:flutter/material.dart';
import 'package:mr_collection/ui/components/dialog/questionnaire_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mr_collection/generated/s.dart';

class SuggestionWebView extends StatefulWidget {
  const SuggestionWebView({super.key});

  @override
  State<SuggestionWebView> createState() => _SuggestionWebViewState();
}

class _SuggestionWebViewState extends State<SuggestionWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(QuestionnaireDialog.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(S.of(context)?.suggestFeature ?? "Suggest features")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
