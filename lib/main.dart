import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaggle/Providers/LoadingProvider.dart';
import 'package:kaggle/Screens/Home.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';


void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>LoadingProvider())
      ],
      child: Main()));
} 


class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(443,944),
      builder:()=> MaterialApp(
        title: "Kaggle",
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),

    );
  }
}
