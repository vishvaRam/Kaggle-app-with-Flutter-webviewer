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
  }

  Future<List<Data>?> getList() async{
    var res = await dbHelper.queryAll();
    return res;
  }

   insertList(String link) async{
    var res = await dbHelper.insert(link);
  }

  deleteListItem(int id) async{
    var res = await dbHelper.delete(id);
  }

}