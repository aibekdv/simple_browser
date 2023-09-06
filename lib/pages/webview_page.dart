import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  String initialUrl = 'https://google.com/';
  double progress = 0;
  final urlController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshController = PullToRefreshController(
      onRefresh: () => webViewController!.reload(),
      options: PullToRefreshOptions(
        backgroundColor: Colors.blue,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            var isGoBack = await webViewController!.canGoBack();
            if (isGoBack) {
              webViewController!.canGoBack();
            }
          },
          splashRadius: 23,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: TextField(
          controller: urlController,
          onSubmitted: (value) {
            url = Uri.parse(value);
            if (url.scheme.isEmpty) {
              url = Uri.parse("${Uri.parse(initialUrl)}search?q=$value");
            }
            webViewController!.loadUrl(urlRequest: URLRequest(url: url));
          },
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: "Search...",
            prefixIcon: Icon(Icons.search),
            constraints: BoxConstraints(maxHeight: 48),
            contentPadding: EdgeInsets.fromLTRB(6, 3, 8, 3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              webViewController!.reload();
            },
            splashRadius: 23,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                InAppWebView(
                  onWebViewCreated: (controller) =>
                      webViewController = controller,
                  onLoadStart: (controller, url) {
                    setState(() {
                      urlController.text = url.toString();
                      isLoading = true;
                    });
                  },
                  pullToRefreshController: refreshController,
                  onLoadStop: (controller, url) {
                    refreshController!.endRefreshing();
                    setState(() {
                      isLoading = false;
                    });
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      refreshController!.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(initialUrl),
                  ),
                ),
                Visibility(
                  visible: isLoading,
                  child: const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
