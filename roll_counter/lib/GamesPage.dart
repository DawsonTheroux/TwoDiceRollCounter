import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grid_button/flutter_grid_button.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'GameDBHelper.dart';
import 'main.dart';

class GamesDataPage extends StatefulWidget {
  final GameDBHelper gameDB;
  GamesDataPage({this.gameDB});
  _GamesData createState() => _GamesData(this.gameDB);
}

class _GamesData extends State<GamesDataPage> {
  final GameDBHelper gameDB;
  _GamesData(this.gameDB);
  TextStyle titleStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: TextDecoration.underline);
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: buildFromTab(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Saved Games"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Stats"
          ),
        ],
        currentIndex: tabIndex,
        onTap: changeTab,
      )
    );
  }

  void changeTab(int index){
    setState((){
      tabIndex = index;
    });
  }

  Widget buildFromTab(){
    if(tabIndex == 0){
      return _buildGamesData();
    }else{
      return _buildStats();
    }
  }

  Widget _buildGamesData(){
    return Container(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: gameDB.getGames(),
        builder: (context, gamesList){
          if(gamesList.hasData){
            if(gamesList.data.length == 0){
              return Container(
                alignment: Alignment.center,
                child: Text("No games in DB"),
              );
            }
            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: gamesList.data.length,
              reverse: true,
              itemBuilder: (context, index){
                return Container(
                  child: Card(
                    child: Row(children: [
                      Container(
                        width: 150,
                        padding: EdgeInsets.all(20),
                        child: Column(children:[
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: Text("Delete Game?"),
                                    content: Text("Are you sure you want to delete this game"),
                                    actions:[
                                      FlatButton(
                                        child: Text("Yes"),
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                          deleteGame(gamesList.data[index]['id']);
                                          setState((){});
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
                          Row(children: [
                            Icon(Icons.stars),
                            Text(getWinnerStr(gamesList.data[index])),
                            ]),
                          Row(children: [
                            Text("P1:", style: titleStyle),
                            Text(" " + gamesList.data[index]['player1']),
                          ]),
                          Row(children: [
                            Text("P2:", style: titleStyle),
                            Text(" " + gamesList.data[index]['player2']),
                          ]),
                          Row(children: [
                            Text("P3:", style: titleStyle),
                            Text(" " + gamesList.data[index]['player3']),
                          ]),
                          Row(children: [
                            Text("P4:", style: titleStyle),
                            Text(" " + gamesList.data[index]['player4']),
                          ])

                        ])
                      ),
                      Container(
                        height: 225,
                        width: MediaQuery.of(context).size.width - 170,
                        alignment: Alignment.centerRight,
                        child: showGraph(gamesList.data[index]['rollsCounter'], false),
                      )
                    ])

                    ),

                  );
              }
            );
          }else
            return Text("NoGameData");
      }
      )
    );
  }

  Widget _buildStats(){
    return FutureBuilder<Map<String, dynamic>>(
      future: gameDB.getOverallStats(),
      builder: (context, stats){
        if(stats.hasData){
          if(stats.data == null){
            return Container(
              child: Text("The Games DB is empty"),
              padding: EdgeInsets.all(10),
            );
          }
          return SingleChildScrollView(
            child: Column(children:[
              Container(
                width: MediaQuery.of(context).size.width - 20,
                height: 120,
                child: showGraph(stats.data['rollsCounter'], true),
                padding: EdgeInsets.all(20),
              ),
              Container(
                height: 100,
                child: buildWinners(stats.data["winnerMap"]),
              )
            ])
          );

        }else{
          return Text("Loading...");
        }
      }
    );
  }

  Widget buildWinners(Map<String, int> winnersMap){
    List<String> keys = winnersMap.keys.toList();
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: keys.length,
        itemBuilder: (context, index) {
          return Card(
            child: Container(
              child: Text(keys[index] + ": " + winnersMap[keys[index]].toString(), style: TextStyle(fontSize: 20)),
            )
          );
        }
    );
  }
  Widget showGraph(List<int> _rollsCounter, bool bVertical){
    List<RollData> data = new List();
    for(int i=0; i < _rollsCounter.length; i++){
      RollData rd = RollData(
        rollNum: i + 2,
        amountRolled: _rollsCounter[i],
        barColor: charts.ColorUtil.fromDartColor(Colors.purple),
      );
      data.add(rd);
    }
    return charts.BarChart(
      getSeriesData(data),
      animate: true,
      vertical: bVertical,
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
            labelRotation:0,
            labelStyle: new charts.TextStyleSpec(
              color: charts.MaterialPalette.white,
            )
        ),
      ),

      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
            labelRotation:0,
            labelStyle: new charts.TextStyleSpec(
              color: charts.MaterialPalette.white,
            )
        ),
      ),
    );
  }

  getSeriesData(List<RollData> data){
    List<charts.Series<RollData, String>> series = [
      charts.Series(
          id: "RollData",
          data: data,
          domainFn: (RollData series, _) => series.rollNum.toString(),
          measureFn: (RollData series, _) => series.amountRolled,
          colorFn: (RollData series, _) => series.barColor
      )
    ];
    return series;
  }

  String getWinnerStr(Map<String,dynamic> data,){
    switch(data["winner"]){
      case "Player 1": {return data["player1"];}
      case "Player 2": {return data["player2"];}
      case "Player 3": {return data["player3"];}
      case "Player 4": {return data["player4"];}
      default: {return data["winner"];}
    }
  }

  void deleteGame(int id){
    gameDB.deleteGame(id);
  }
}