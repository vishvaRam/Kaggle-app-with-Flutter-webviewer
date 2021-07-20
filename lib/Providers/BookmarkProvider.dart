import 'package:flutter/material.dart';
import 'DataBase.dart';


class BookMarkProvider extends ChangeNotifier{
  List<Data>? _bookmarksList;
  final dbHelper = TodoProvider.instance;

  List<Data>? get bookmarksList{
    return _bookmarksList;
  }

  Future<List<Data>?> getList() async{
    var res = await dbHelper.queryAll();
    print(res);
    return res;
  }

   insertList(String link) async{
    print(link);
    var res = await dbHelper.insert(link);
    print(res);
  }

  deleteListItem(int id) async{
    var res = await dbHelper.delete(id);
    print(res);
  }

}