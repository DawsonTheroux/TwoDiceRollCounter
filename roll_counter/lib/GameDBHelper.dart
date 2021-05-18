import 'dart:async';
import 'dart:io';
import 'main.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';


class GameRollData {
  final List<int> rollsInOrder;
  final int totalRolls;
  final List<int> rollsCounter;
  final String player1;
  final String player2;
  final String player3;
  final String player4;
  final String winner;

  GameRollData(this.rollsInOrder, this.totalRolls, this.rollsCounter, this.player1, this.player2, this.player3, this.player4, this.winner);

  Map<String, dynamic> toMap(){
    return{
      'rollsInOrder' : rollsInOrder,
      'totalRolls' : totalRolls,
      'rollsCounter': rollsCounter,
      'player1' : player1,
      'player2' : player2,
      'player3' : player3,
      'player4' : player4,
      'winner' : winner
    };
  }
}

class GameDBHelper{

  static Database _database;

  //ctors for the GameDBHelper.
  GameDBHelper._privateConstructor();
  static final GameDBHelper instance = GameDBHelper._privateConstructor();

  //Returns the db if exists, creates and returns if not.
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  factory GameDBHelper() {
    return instance;
  }

  //Database creation func.
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'GamesDatbase.db');
    return await openDatabase(path,
        version: 1, onCreate: _onCreate);
  }
  //Run when _initDatabase() is run to create the table ^^.
  Future _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE games(id INTEGER PRIMARY KEY autoincrement, rollsInOrder Uint8List, totalRolls INTEGER, rollsCounter Uint8List, player1 TEXT, player2 TEXT, player3 TEXT, player4 TEXT, winner TEXT)");
  }

  //Inserts a game into the DB.
  Future<void> insertGame(GameRollData gameData) async{
    final Database db = await _database;
    await db.insert(
      'games',
      gameData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Checks to see if a game exists with the given id and changes it if it does to the new game. **THIS MAY NOT BE NEEDED**
  Future<int> update(Map<String, dynamic> row) async{
    Database db = await instance.database;
    var query = await db.rawQuery('SELECT * FROM games WHERE id="${row["id"]}"');

    int gameId = row["id"];
    if(query.isNotEmpty) {
      print("Removing game: $gameId.");
      return await db.delete('games', where: 'id = ?', whereArgs: ['$gameId']);
    }else{
      print("Adding: $gameId");
      return await db.insert('games',row);
    }
  }

  Future<void> drop() async {
    print("DROPPING DB");
    Database db = await instance.database;
    return db.execute("DROP TABLE IF EXISTS games");
  }

  void createDB(db) {
    try {
      _onCreate(db, 1);
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String,dynamic>>> getGames() async{
    Database db = await instance.database;
    return await db.query('games');
  }

  Future<bool> addGame(String player1, String player2, String player3, String player4, String winner, List<int> rollsInOrder, int totalRolls, List<int> rollsCounter) async{

    Database db = await instance.database;
    Uint8List rio = Uint8List(rollsInOrder.length);
    Uint8List rc = Uint8List(rollsCounter.length);

    for(int i=0; i < rollsInOrder.length; i++){
      rio[i] = rollsInOrder[i];
    }

    for(int i=0; i < rollsCounter.length; i++){
      rc[i] = rollsCounter[i];
    }

    GameRollData curGame = GameRollData(rio, totalRolls, rc, player1, player2, player3, player3, winner);
    db.insert("games", curGame.toMap());

    return true;
  }
  Future<int> deleteGame(int id) async {
    Database db = await instance.database;
    return await db.delete('games', where: 'id = ?', whereArgs: ['$id']);
  }

  Future<Map<String, dynamic>> getOverallStats() async {

    Database db = await instance.database;
    List<Map<String,dynamic>> gamesList = await db.query('games');
    List<int> rollsCounter = [0,0,0,0,0,0,0,0,0,0,0];
    Map<String,int> winnerMap = Map<String,int>();
    Map<String,dynamic> returnMap = Map<String,dynamic>();

    if(gamesList.length == 0){
      return null;
    }

    for(int i=0;i<gamesList.length; i++){
      //The name of the winner.
      String winnerName = gamesList[i]['winner'].toLowerCase();
      for(int j=0;j<rollsCounter.length;j++){                   //Loops through
        rollsCounter[j] += gamesList[i]['rollsCounter'][j];
      }
      if(winnerMap.isEmpty || !winnerMap.containsKey(winnerName)){
        winnerMap[winnerName] = 1;
      }else if(winnerMap.containsKey(winnerName)){
        winnerMap[winnerName] += 1;
      }
    }
    returnMap["winnerMap"] = winnerMap;
    returnMap["rollsCounter"] = rollsCounter;
    return returnMap;
  }
}
//WidgetsFlutterBinding.ensureInitialized();




