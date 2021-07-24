import 'package:flutter/material.dart';
import 'DataBase.dart';


class BookMarkProvider extends ChangeNotifier{
  List<Data>? _bookmarksList;
  bool _isBookmarked = false;
  final dbHelper = TodoProvider.instance;

  bool get isBookmarked => _isBookmarked;

  List<Data>? get bookmarksList{
    return _bookmarksList;
  }

  toggleIsBookmark(bool value){
    _isBookmarked = value;
    notifyListeners();
    print("Is Bookmarked : "+ _isBookmarked.toString());
  }

  Future<List<Data>?> getList() async{
    var res = await dbHelper.queryAll();
    _bookmarksList = res;
    notifyListeners();
    return res;
  }

  insertList(String link) async{
      await dbHelper.insert(link);
      await getList();
  }

  deleteListItem(String link) async{
    await dbHelper.delete(link);
    await getList();
    print("Deleted!");
  }

}