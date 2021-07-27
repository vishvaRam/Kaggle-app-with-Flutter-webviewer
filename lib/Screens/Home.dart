import 'dart:async';
import 'package:animations/animations.dart';
import 'package:error_notifier_for_provider/error_notifier_for_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaggle/Providers/BookmarkProvider.dart';
import 'package:kaggle/Screens/Bookmarks.dart';
import 'package:kaggle/Widgets/BottomAppBar.dart';
import 'package:kaggle/Widgets/WebPager.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final home = new GlobalKey<ScaffoldState>();
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController? controllerGlobal;

  showSnack(context, message) {
    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
          bottom: kBottomNavigationBarHeight, right: 10, left: 10),
      duration: Duration(seconds: 2),
    ));
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      getList() async {
        var bookMarkProvider =
            Provider.of<BookMarkProvider>(context, listen: false);
        await bookMarkProvider.getList();
        if (bookMarkProvider.bookmarksList != null) {
          bookMarkProvider.bookmarksList!.forEach((element) {
            print(element.link);
          });
        } else {
          print("Empty");
        }
      }

      getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: SafeArea(
          child: Scaffold(
            key: home,
        body: ErrorListener<BookMarkProvider>(
          onNotify: (context, message) {
           showSnack(context, message);
          },
            child: Stack(
              children: [
                WebPager( url: widget.url,controller: _controller,),
                Positioned(
                  bottom: 0,
                  child: FutureBuilder(
                      future: _controller.future,
                      builder: (BuildContext context,
                          AsyncSnapshot<WebViewController> snapshot) {
                        if (!snapshot.hasData) return SizedBox();
                        final bool webViewReady =
                            snapshot.connectionState == ConnectionState.done;
                        controllerGlobal = snapshot.data;
                        return BottomNavBarR(
                          webViewReady: webViewReady,
                          snapshot: snapshot,
                        );
                      }),
                )
              ],
            ),
        ),
      )),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controllerGlobal!.canGoBack()) {
      controllerGlobal!.goBack();
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                  'Finished already?',
                  style: TextStyle(fontSize: 24),
                ),
                content: Text("Are you sure you want to quit?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: Text(
                      'Quit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ));
      return Future.value(false);
    }
    return Future.value(false);
  }
}

class BottomNavBarR extends StatefulWidget {
  const BottomNavBarR({
    Key? key,
    required this.webViewReady,
    required this.snapshot,
  }) : super(key: key);
  final AsyncSnapshot<WebViewController> snapshot;
  final bool webViewReady;

  @override
  _BottomNavBarRState createState() => _BottomNavBarRState();
}

class _BottomNavBarRState extends State<BottomNavBarR> {
  bool isBook = false;

  @override
  Widget build(BuildContext context) {
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
              onPressed: !widget.webViewReady
                  ? null
                  : () =>
                      navigate(context, widget.snapshot.data!, goBack: true),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !widget.webViewReady
                  ? null
                  : () =>
                      navigate(context, widget.snapshot.data!, goBack: false),
            ),
            Consumer<BookMarkProvider>(
              builder: (context, p, _) => IconButton(
                  onPressed: () async {
                    var res = await widget.snapshot.data!.currentUrl();
                    p.insertList(res!);
                  },
                  icon: Icon(
                    Icons.bookmark_border,
                    size: 26,
                  )),
            ),
            IconButton(
                onPressed: !widget.webViewReady
                    ? null
                    : () async {
                        Share.share('check out this kaggle blog! ${ await widget.snapshot.data!.currentUrl()}');
                      },
                icon: Icon(Icons.share)),
            PopMenu(
              snapshot: widget.snapshot,
            ),
          ],
        ),
      ),
    );
  }
}

class PopMenu extends StatelessWidget {
  const PopMenu({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  final AsyncSnapshot<WebViewController> snapshot;

  final ContainerTransitionType _containerTransitionType =
      ContainerTransitionType.fadeThrough;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      elevation: 12,
      onSelected: (keyWord) async {
        String? url = await snapshot.data!.currentUrl();
        switch (keyWord) {
          case "RL":
            snapshot.data!.reload();
            break;
          case "OWB":
            if (await canLaunch(url!)) {
              await launch(
                url,
                forceSafariVC: false,
                forceWebView: false,
              );
            } else {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(
                        bottom: kBottomNavigationBarHeight,
                        right: 10,
                        left: 10),
                    content: Text("URL can't be opened!")),
              );
            }
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuItem<String>>[
        PopupMenuItem<String>(
          value: 'RL',
          child: ListTile(
            title: Text("Refresh"),
            trailing: Icon(Icons.refresh),
          ),
        ),
        PopupMenuItem<String>(
          value: 'OWB',
          child: ListTile(
            onTap: () {},
            title: Text("Open in Browser"),
            trailing: Icon(Icons.open_in_new),
          ),
        ),
        PopupMenuItem<String>(
          child: OpenContainer(
            tappable: false,
            openElevation: 20,
            closedElevation: 0,
            transitionType: _containerTransitionType,
            transitionDuration: Duration(milliseconds: 400),
            openBuilder: (context, _) => Bookmarks(),
            closedBuilder: (context, VoidCallback openContainer) => ListTile(
              onTap: () {
                openContainer();
              },
              title: Text("See Bookmarks"),
            ),
          ),
        ),
      ],
    );
  }
}
