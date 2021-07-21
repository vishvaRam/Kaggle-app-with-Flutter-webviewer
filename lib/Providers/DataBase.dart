import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


final String columnId = '_id';
final String tableName = 'links';
final String columnLink = 'link';
final String dbName = 'link';
final int dbVersion = 1;

class Data{
  int? id;
  String? link;

  Data({this.id,this.link});

  Map<String , dynamic> toMap (){
    return{
      "id":id,
      "link":columnLink,
    };
  }


  Data.fromMap(Map<dynamic,dynamic> map){
    id = map[columnId];
    id = map[columnLink];
  }
}

class TodoProvider {

  // make this a singleton class
  TodoProvider._privateConstructor();
  static final TodoProvider instance = TodoProvider._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "db");
    return await openDatabase(path,
        version: dbVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableName (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $columnLink TEXT NOT NULL
          )
          ''');
  }


  Future<int?> insert(String data) async {
    try{
      final db = await instance.database;
      print("Trying to insert");
      Map<String, dynamic> values = {
        "link": data,
      };
       var res = await db.insert(tableName, values,conflictAlgorithm: ConflictAlgorithm.replace,);
       print("From db: "+res.toString());
      return res;
    }
    catch (e){
      print(e);
    }
  }


  // ignore: missing_return
  Future<List<Data>?> queryAll() async {
    try{
      final db = await instance.database;
      final List<Map<String,dynamic>> result = await db.query(tableName,orderBy: "_id DESC");
      if(result.length>0){
        print("Queried");
        return List.generate(
            result.length,
                (i){
              return Data(
                  id: result[i]['id'],
                  link: result[i]['link'],
              );
            }
        );
      }else{
        return null;
      }
    }catch(e){print(e);}

  }

  Future<int?> delete(int id) async {
    try{
      final db = await instance.database;
      return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
    }catch(e){
      print(e);
    }
  }


  Future close() async{
    final db = await instance.database;
    await db.close();
  }
}
