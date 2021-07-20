import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

navigate(BuildContext context, WebViewController controller,
    {bool goBack: false}) async {
  bool canNavigate =
  goBack ? await controller.canGoBack() : await controller.canGoForward();
  if (canNavigate) {
    goBack ? controller.goBack() : controller.goForward();
  } else {
    Scaffold.of(context).showSnackBar(
      SnackBar(
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
              bottom: kBottomNavigationBarHeight, right: 10, left: 10),
          content: Text("No ${goBack ? 'back' : 'forward'} history item")),
    );
  }
}
