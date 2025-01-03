import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';
import 'Common.dart';

class CommonWebView extends StatefulWidget {
  final String webUrl;
  final String title;

  const CommonWebView({Key? key, required this.webUrl, required this.title})
      : super(key: key);

  @override
  _CommonWebViewState createState() => _CommonWebViewState();
}

late WebViewController controllerGlobal;
bool isPageLoad = false;

Future<bool> _exitApp(BuildContext context) async {
  if (await controllerGlobal.canGoBack()) {
    debugPrint("onWillGoBack");
    controllerGlobal.goBack();
  } else {
    // showToast(message: "No back history item");
    return Future.value(false);
  }
  return false;
}

class _CommonWebViewState extends State<CommonWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    isPageLoad = true;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint("onProgress :: $progress");
          },
          onPageStarted: (String url) {
            debugPrint("onPageStarted :: $url");
          },
          onPageFinished: (String url) {
            debugPrint("onPageFinished :: $url");
            isPageLoad = false;
            setState(() { });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("onWebResourceError :: $error");
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint("onNavigationRequest :: ${request.url}");

            if (request.url.contains("status=1")) {
              Navigator.pop(context, true);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.webUrl));

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(navigatorKey.currentState!.context),
      child: SafeArea(
        child: Scaffold(
            body: isPageLoad
                ? const Center(
                  child: CircularProgressIndicator(
              color: colorThemePink,
            ),
                )
                : Builder(builder: (BuildContext context) {
                    return WebViewWidget(
                      controller: controller,
                    );
                  })
            //floatingActionButton: favoriteButton(),
            ),
      ),
    );
  }
}
