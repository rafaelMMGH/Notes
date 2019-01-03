import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:notes/Model/Note.dart';

class DBHelper{

  static DBHelper _databaseHelper;  // Singleton DBHelper
  static Database _database;        // Singleton Database

  String tableName = 'Note_table';
  String colId = 'id';
  String coldAccount = 'account';
  String colDescription = 'description';
  String colPassword = 'password';
  String colDate = 'date';

  DBHelper._createInstance();      // Named constructor to create instance of DBHelper

  factory DBHelper(){
    if(_databaseHelper == null) {
      _databaseHelper = DBHelper._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database == null)
      _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async{

    // Get the directory path for both android an iOS to store database
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = documentDirectory.path + 'Note.db';

    // Open/Create the database at a given path
    var db = await openDatabase(path,version: 1, onCreate: _onCreateDB);
    return db;
  }

  //Create table
  void _onCreateDB(Database db, int version) async {
    await db.execute('CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $coldAccount TEXT, $colDescription TEXT,$colPassword TEXT,$colDate TEXT);');
  }


  // CRUD Functions

  //Query
  Future<List<Map<String,dynamic>>> getMapNotesList() async {
    Database dbConnection = await this.database;

    var result = await dbConnection.query(tableName, orderBy: '$colDate DESC');
    return result;
  }

  //Create new Notes
  Future<int> addNote(Note notes) async{
    var dbConnection = await this.database;

    var result = await dbConnection.insert(tableName, notes.toMap());
    return result;

    /*
    String query = 'INSERT INTO $TABLE_NAME (account,password) VALUES (\'${card.account}\', \'${card.password}\')';
    await db_connection.transaction((transaction) async{
      return await transaction.rawInsert(query);
    });
    */
  }

  //Update Notes
  Future<int> updateNote(Note notes) async{
    var dbConnection = await this.database;

    var result = await dbConnection.update(tableName, notes.toMap(),where: '$colId = ?',whereArgs: [notes.id]);
    return result;

    /*
    String query = 'UPDATE $TABLE_NAME SET account=\'${card.account}\',password=\'${card.password}\' WHERE id=${card.id}';
    await db_connection.transaction((transaction) async{
      return await transaction.rawQuery(query);
    });
    */
  }

  //Remove Note
  Future<int> removeNote(int id) async{
    var dbConnection = await this.database;

    int result = await dbConnection.rawDelete('DELETE FROM $tableName WHERE $colId= $id');
    return result;
  }

  Future<int> getCount() async{
    var dbConnection = await this.database;

    List<Map<String,dynamic>> x = await dbConnection.rawQuery('Select Count (*) from $tableName');
    int result =Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async{

    var noteMapList = await getMapNotesList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();

    for(int i = 0; i< count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

}