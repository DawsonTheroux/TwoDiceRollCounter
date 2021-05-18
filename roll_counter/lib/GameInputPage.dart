import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid_button/flutter_grid_button.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'GamesPage.dart';
import 'GameDBHelper.dart';

class GameInputPage extends StatefulWidget{
  GameInputPage({this.rollsInOrder, this.rollsCounter, this.gameDB});
  final List<int> rollsInOrder;
  final List<int> rollsCounter;
  final GameDBHelper gameDB;
  _GameInputState createState()=> _GameInputState(this.rollsInOrder, this.rollsCounter, this.gameDB);
}

class _GameInputState extends State<GameInputPage>{
  final List<int> rollsInOrder;
  final List<int> rollsCounter;
  final GameDBHelper gameDB;
  _GameInputState(this.rollsInOrder, this.rollsCounter, this.gameDB);

  final textController1 = TextEditingController();
  final textController2 = TextEditingController();
  final textController3 = TextEditingController();
  final textController4 = TextEditingController();
  dynamic winner = "N/A";



  Widget createInputPage(){
    TextStyle pageTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    String p1Name = "Player 1";
    String p2Name = "Player 2";
    String p3Name = "Player 3";
    String p4Name = "Player 4";


    void addGametoDB() async{
      print(p1Name + p2Name + p3Name + p4Name);
      bool added = await gameDB.addGame(p1Name, p2Name, p3Name, p4Name, winner, rollsInOrder, rollsInOrder.length, rollsCounter);
    }

    return Container(
      padding: EdgeInsets.all(10),
        child: Column(
                children:[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(children:[
                      Text("Player 1: ", style: pageTextStyle),
                      Expanded(child: TextField(decoration: InputDecoration(labelText: 'Player1', border: OutlineInputBorder()),controller: textController1, onChanged: (String value){print(value); p1Name = value;})),
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(children:[
                      Text("Player 2: ", style: pageTextStyle),
                      Expanded(child: TextField(decoration: InputDecoration(labelText: 'Player2', border: OutlineInputBorder()),controller: textController2, onChanged: (String value){ p2Name = value;})),
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(children:[
                      Text("Player 3: ", style: pageTextStyle),
                      Expanded(child: TextField(decoration: InputDecoration(labelText: 'Player3', border: OutlineInputBorder()),controller: textController3, onChanged: (String value){p3Name = value;})),
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(children:[
                      Text("Player 4: ", style: pageTextStyle),
                      Expanded(child: TextField(decoration: InputDecoration(labelText: 'Player4', border: OutlineInputBorder()),controller: textController4, onChanged: (String value){p4Name = value;})),
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(children:[
                      Text("Winner: ", style: pageTextStyle),
                      DropdownButton<dynamic>(
                        value: winner,
                        onChanged: (dynamic newValue){
                          print("changed" + newValue.toString());
                          setState((){
                            winner = newValue;
                          });
                        },
                        items: <dynamic>['N/A',"Player1","Player2","Player3","Player4"].map<DropdownMenuItem>((dynamic value){
                          return DropdownMenuItem<dynamic>(
                          value: value,
                          child: Text(value),
                          );
                        }).toList()),
                      FlatButton(
                        child: Text("Save Game"),
                        color: Colors.purple,
                        textColor: Colors.white,
                        onPressed: (){
                          showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                    title: Text("Save Game?"),
                                    content: Text("Are you sure all the game data is correct?"),
                                    actions:[
                                      FlatButton(
                                          child: Text("Yes"),
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            addGametoDB();
                                          }
                                      ),
                                      FlatButton(
                                          child: Text("No"),
                                          onPressed:(){
                                            Navigator.of(context).pop();
                                          }
                                      )
                                    ]
                                );
                              }
                          );
                        },
                      ),
                    ])
                  )


                ])
      );
  }


  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Input Game Data"),
      ),
      body: createInputPage(),
    );
  }



}