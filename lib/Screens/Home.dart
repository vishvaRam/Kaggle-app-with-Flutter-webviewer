import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaggle/Providers/BookmarkProvider.dart';
import 'package:kaggle/Providers/DataBase.dart';
import 'package:kaggle/Providers/LoadingProvider.dart';
import 'package:kaggle/Widgets/BottomAppBar.dart';
import 'package:kaggle/Widgets/WebPager.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

final Completer<WebViewController> _controller = Completer<WebViewController>();
WebViewController? controllerGlobal;


class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var loadingProvider = Provider.of<LoadingProvider>(context, listen: false);
    print(loadingProvider.isLoading);
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: SafeArea(
          child: Scaffold(
        body: Stack(
          children: [
            WebPager(
              size: size,
              controller: _controller,
            ),
            Positioned(
              bottom: 0,
              child: FutureBuilder(
                  future: _controller.future,
                  builder: (BuildContext context,
                      AsyncSnapshot<WebViewController> snapshot) {
                    if (!snapshot.hasData) return Container();
                    final bool webViewReady =
                        snapshot.connectionState == ConnectionState.done;
                    controllerGlobal = snapshot.data;
                    print(snapshot.data!);
                    return BottomNavBarR(webViewReady: webViewReady,snapshot: snapshot,);
                  }),
            )
          ],
        ),
      )),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    print("Called");
    print(controllerGlobal);
    if (await controllerGlobal!.canGoBack()) {
      controllerGlobal!.goBack();
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Do you want to exit'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text('Yes'),
              ),
            ],
          ));
      return Future.value(false);
    }
    return Future.value(false);
  }
}

class BottomNavBarR extends StatelessWidget {
  const BottomNavBarR({
    Key? key,
    required this.webViewReady,required this.snapshot,
  }) : super(key: key);
  final AsyncSnapshot<WebViewController> snapshot;
  final bool webViewReady;

  @override
  Widget build(BuildContext context) {
    var bookMarkProvider = Provider.of<BookMarkProvider>(context,listen: false);

    return Material(
      elevation: 50,
      child: Container(
        height: kBottomNavigationBarHeight,
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () =>
                  navigate(context, snapshot.data!, goBack: true),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () =>
                  navigate(context, snapshot.data!, goBack: false),
            ),
            IconButton(
                onPressed: !webViewReady ? null : () async {
                  var res = await snapshot.data!.currentUrl();
                  bookMarkProvider.insertList(res!);
                },
                icon: Icon(Icons.bookmark_border)),
            IconButton(
                onPressed: !webViewReady ? null : () async{
                  // bookMarkProvider.deleteListItem(0);
                  bookMarkProvider.getList();
                  // Share.share('check out this kaggle blog! ${ await snapshot.data!.currentUrl()}');
                },
                icon: Icon(Icons.share)),
            PopMenu(snapshot: snapshot,),
          ],
        ),
      ),
    );
  }
}

class PopMenu extends StatelessWidget {
  const PopMenu({
    Key? key,required this.snapshot,
  }) : super(key: key);

  final AsyncSnapshot<WebViewController> snapshot;

  @override
  Widget build(BuildContext context) {
    var bookMarkProvider = Provider.of<BookMarkProvider>(context,listen: false);

    return PopupMenuButton(
      elevation: 12,
      onSelected: (keyWord) async{
        String? url =await snapshot.data!.currentUrl();
        switch(keyWord){
          case "RL": snapshot.data!.reload();
          break;
          case 'SB':
            var res = await bookMarkProvider.getList();
            if(res != null){
              for(var i in res){
                print(i.id);
                print(i.link);
              }
            }
            break;
          case "OWB": if (await canLaunch(url!)) {
            await launch(
              url,
              forceSafariVC: false,
              forceWebView: false,
            );
          } else {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                      bottom: kBottomNavigationBarHeight, right: 10, left: 10),
                  content: Text("URL can't be opened!")),
            );
          }
          break;
        }
      },
      itemBuilder: (context) => <PopupMenuItem<String>>[
        PopupMenuItem<String>(
          value: 'RL',
          child: ListTile(title: Text("Refresh"),trailing: Icon(Icons.refresh),),
        ),
        PopupMenuItem<String>(
          value: 'OWB',
          child: ListTile(title: Text("Open in Browser"),trailing: Icon(Icons.open_in_new),),
        ),
        PopupMenuItem<String>(
          value: 'SB',
          child: ListTile(title: Text("See Bookmarks"),),
        ),
      ],
    );
  }
}
