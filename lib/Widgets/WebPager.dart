import 'dart:async';
import 'dart:io';
import 'package:kaggle/Providers/LoadingProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPager extends StatefulWidget {
   WebPager({
    Key? key,
    required this.size,
    required this.controller
  }) : super(key: key);
  Completer<WebViewController> controller =
  Completer<WebViewController>();
  final Size size;

  @override
  _WebPagerState createState() => _WebPagerState();
}

class _WebPagerState extends State<WebPager> {
  final String url = "https://www.kaggle.com/";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var loadingProvider = Provider.of<LoadingProvider>(context,listen: false);
    print("Loading : "+ isLoading.toString());
    return Positioned(
      top: 0,
      child: Builder(
        builder:(BuildContext context)=> Stack(
          children: [
            Container(
              height: widget.size.height,
              width: widget.size.width,
              child: WebView(
                userAgent:  Platform.isIOS ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_2 like Mac OS X) AppleWebKit/605.1.15' +
                    ' (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1' :
                'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) ' +
                    'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36',
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: url,
                allowsInlineMediaPlayback: true,
                onWebViewCreated: (WebViewController webViewController) {
                  widget.controller.complete(webViewController);
                },
                onPageStarted: (va){
                 loadingProvider.setLoading(true);
                },
                onPageFinished: (va){
                  loadingProvider.setLoading(false);
                },
                onProgress: (value) {
                  loadingProvider.setLoading(true);
                  print("From Provider :"+loadingProvider.progress.toString());
                  loadingProvider.setProgress(value);
                  if(loadingProvider.progress == 100){
                    loadingProvider.reSetProgress();
                    loadingProvider.setLoading(false);
                  }
                  print(loadingProvider.progress);
                },
              ),
            ),
            Consumer<LoadingProvider>(
              builder:(context, isLoading,child)=> Container(
                height: widget.size.height,
                width: widget.size.width,
                child: Center(
                  child: isLoading.isLoading ? CircularProgressIndicator():Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
