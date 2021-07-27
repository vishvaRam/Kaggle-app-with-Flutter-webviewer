import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaggle/Providers/BookmarkProvider.dart';
import 'package:kaggle/Screens/BookMarkViewer.dart';
import 'package:kaggle/Widgets/ErrorWidget.dart';
import 'package:provider/provider.dart';
import "package:flutter_link_preview/flutter_link_preview.dart";
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class Bookmarks extends StatefulWidget {
  const Bookmarks({Key? key}) : super(key: key);

  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      getList() async {
        var bookMarkProvider =
            Provider.of<BookMarkProvider>(context, listen: false);
        await bookMarkProvider.getList();
      }
      getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<BookMarkProvider>(
          builder:(context,p,_)=> CustomScrollView(
            slivers: [
              SliverAppBar(
                  elevation: 12,
                  floating: true,
                  iconTheme: IconThemeData(color: Colors.black),
                  expandedHeight: 200.h,
                  backgroundColor: Colors.white,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.white,
                    ),
                    title: Text(
                      "Bookmarks",
                      style: TextStyle(color: Colors.black),
                    ),
                  )),
              p.bookmarksList == null
                  ? SliverFillRemaining(child: EmptyWidget())
                  : Consumer<BookMarkProvider>(builder:(context,p,_)=> ListOfLinks(bookMarkProvider: p))
            ],
          ),
        ),
      ),
    );
  }
}

class ListOfLinks extends StatelessWidget {
  const ListOfLinks({
    Key? key,
    required this.bookMarkProvider,
  }) : super(key: key);

  final BookMarkProvider bookMarkProvider;
  final ContainerTransitionType _containerTransitionType =
      ContainerTransitionType.fadeThrough;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => FlutterLinkPreview(
          key: Key(bookMarkProvider.bookmarksList![index].link.toString()),
          url: bookMarkProvider.bookmarksList![index].link,
          bodyStyle: TextStyle(
            fontSize: 16.sp,
          ),
          titleStyle: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          showMultimedia: true,
          builder: (info) {
            if (info is WebInfo) {
              return OpenContainer(
                tappable: false,
                openElevation: 20,
                closedElevation: 0,
                transitionType: _containerTransitionType,
                transitionDuration: Duration(milliseconds: 400),
                closedBuilder: (context, VoidCallback openContainer) =>
                    BookmarkCard(
                  openContainer: openContainer,
                  url: bookMarkProvider.bookmarksList![index].link.toString(),
                  info: info,
                ),
                openBuilder: (context, _) => BookmarkViewer(
                    url:
                        bookMarkProvider.bookmarksList![index].link.toString()),
              );
            }
            return SizedBox();
          },
        ),
        childCount: bookMarkProvider.bookmarksList!.length,
      ),
    );
  }
}

class BookmarkCard extends StatelessWidget {
  const BookmarkCard({
    Key? key,
    required this.info,
    required this.openContainer,
    required this.url,
  }) : super(key: key);

  final String url;
  final WebInfo info;
  final VoidCallback openContainer;
  @override
  Widget build(BuildContext context) {
    var bookmarkProvider = Provider.of<BookMarkProvider>(context,listen: false);
    return SizedBox(
      height: info.image != null ? 300.h : 170.h,
      child: GestureDetector(
        onTap: () {
          openContainer();
        },
        child: Card(
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info.image != null)
                Expanded(
                    child: Image.network(
                  info.image,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                )),
              Padding(
                padding: EdgeInsets.fromLTRB(16.sp, 16.0.sp, 10.0.sp, 0.sp),
                child: Text(
                  info.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: info.image != null ? 1 : 2,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (info.description != null)
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 16.0.sp,
                            top: 10.sp,
                            bottom: 10.sp,
                            right: 8.sp),
                        child: Text(info.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            softWrap: true),
                      ),
                    ),
                    PopupMenuButton(
                        onSelected: (value) async {
                          switch (value) {
                            case 1:
                              if (await canLaunch(url)) {
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
                            case 2 :
                              Share.share('check out this kaggle blog! $url');

                              break;
                            case 3 :  bookmarkProvider.deleteListItem(url);
                            break;
                          }
                        },
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                child: ListTile(
                                  title: Text("Open in browser"),
                                  trailing: Icon(
                                    Icons.open_in_new,
                                  ),
                                ),
                                value: 1,
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  title: Text("Share"),
                                  trailing: Icon(
                                    Icons.share,
                                  ),
                                ),
                                value: 2,
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  title: Text("Delete"),
                                  trailing: Icon(
                                    Icons.delete,
                                  ),
                                ),
                                value: 3,
                              ),
                            ])
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
