import 'package:error_notifier_for_provider/error_notifier_for_provider.dart';
import 'package:flutter/material.dart';
import 'DataBase.dart';


class BookMarkProvider extends ChangeNotifier with ErrorNotifierMixin {
  List<Data>? _bookmarksList;
  final dbHelper = TodoProvider.instance;

  List<Data>? get bookmarksList{
    return _bookmarksList;
  }


  Future<List<Data>?> getList() async{
    var res = await dbHelper.queryAll();
    _bookmarksList = res;
    notifyListeners();
    return res;
  }

  insertList(String link) async{
      await getList();
      if(_bookmarksList != null){
        for(var i in _bookmarksList!){
          if(i.link == link){
            print("Already There!");
            notifyError("Already Bookmarked!");
            return;
          }
        }
      }
      await dbHelper.insert(link);
      print("Inserted!");
      notifyError("Added to bookmarked");
      await getList();
  }

  deleteListItem(String link) async{
    await dbHelper.delete(link);
    await getList();
    print("Deleted!");
  }

}