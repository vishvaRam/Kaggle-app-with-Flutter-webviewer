import 'dart:async';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:kaggle/Providers/BookmarkProvider.dart';
import 'package:kaggle/Providers/LoadingProvider.dart';
import 'package:kaggle/Screens/Bookmarks.dart';
import 'package:kaggle/Widgets/BottomAppBar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BookmarkViewer extends StatefulWidget {
  const BookmarkViewer({Key? key,required this.url}) : super(key: key);
  final String url;
  @override
  _BookmarkViewerState createState() => _BookmarkViewerState();
}


class _BookmarkViewerState extends State<BookmarkViewer> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController? controllerGlobal;


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
    var loadingProvider = Provider.of<LoadingProvider>(context,listen: false);
    var bookMarkProvider = Provider.of<BookMarkProvider>(context,listen: false);
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  child: Builder(
                    builder:(BuildContext context)=> Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: WebView(
                            key: Key("Bookmarks"),
                            userAgent:  Platform.isIOS ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_2 like Mac OS X) AppleWebKit/605.1.15' +
                                ' (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1' :
                            'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) ' +
                                'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36',
                            javascriptMode: JavascriptMode.unrestricted,
                            initialUrl: widget.url,
                            allowsInlineMediaPlayback: true,
                            onWebViewCreated: (WebViewController webViewController) {
                              _controller.complete(webViewController);
                            },
                            onPageStarted: (va){
                              loadingProvider.setLoading(true);
                              print("Loading New page");
                            },
                            onPageFinished: (link){
                              loadingProvider.setLoading(false);
                              getList() async{
                                var res = await bookMarkProvider.getList();
                                print("Link : "+ link);
                                if(res != null){
                                  for(int i =0;i<res.length;i++){
                                    if (res[i].link == link) {
                                      bookMarkProvider.toggleIsBookmark(true);
                                    } else {
                                      bookMarkProvider.toggleIsBookmark(false);
                                    }
                                  }
                                }
                              }
                              getList();
                            },
                            onProgress: (value) {
                              loadingProvider.setLoading(true);
                              loadingProvider.setProgress(value);
                              if(loadingProvider.progress == 100){
                                loadingProvider.reSetProgress();
                                loadingProvider.setLoading(false);
                                getList() async{
                                  await bookMarkProvider.getList();
                                  var controller = await _controller.future ;
                                  var link = await controller.currentUrl();
                                  print("Link : "+ link!);
                                  if(bookMarkProvider.bookmarksList != null){
                                    for(int i =0;i<bookMarkProvider.bookmarksList!.length;i++){
                                      if (bookMarkProvider.bookmarksList![i].link == link) {
                                        bookMarkProvider.toggleIsBookmark(true);
                                      } else {
                                        bookMarkProvider.toggleIsBookmark(false);
                                      }
                                    }
                                  }
                                }
                                getList();
                              }
                            },
                          ),
                        ),
                        Consumer<LoadingProvider>(
                          builder:(context, isLoading,child)=> Container(
                            height: MediaQuery.of(context).size.height,
                            width:MediaQuery.of(context).size.width,
                            child: Center(
                              child: isLoading.isLoading ? CircularProgressIndicator():Container(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
          )),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    var loadingProvider = Provider.of<LoadingProvider>(context,listen: false);
    if (await controllerGlobal!.canGoBack()) {
      controllerGlobal!.goBack();
    } else {
      loadingProvider.setLoading(false);
      Navigator.of(context).pop();
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
  @override
  Widget build(BuildContext context) {
    var bookMarkProvider =
    Provider.of<BookMarkProvider>(context, listen: false);

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
                      if(p.isBookmarked == false){
                        p.insertList(res!);
                        print("Inserted");
                      }else{
                        p.deleteListItem(res!);
                        print("Deleted");
                      }
                      p.toggleIsBookmark(!p.isBookmarked);
                    },
                    icon: p.isBookmarked
                        ? Icon(Icons.bookmark)
                        : Icon(Icons.bookmark_border))),
            IconButton(
                onPressed: !widget.webViewReady
                    ? null
                    : () async {
                  if(bookMarkProvider.bookmarksList != null){
                    bookMarkProvider.bookmarksList!.forEach((element) {
                      print(element.id.toString()+" : "+element.link.toString());
                    });
                  }else{
                    print("Empty");
                  }
                  // Share.share('check out this kaggle blog! ${ await snapshot.data!.currentUrl()}');
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
      ContainerTransitionType.fade;

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
              Scaffold.of(context).showSnackBar(
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
            onTap: (){},
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
            openBuilder: (context,_)=> Bookmarks(),
            closedBuilder: (context,VoidCallback openContainer)=>ListTile(
              onTap: (){
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
