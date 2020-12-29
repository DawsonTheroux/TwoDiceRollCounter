import 'package:flutter/material.dart';
import 'package:flutter_grid_button/flutter_grid_button.dart';
import 'package:charts_flutter/flutter.dart' as charts;


void main() => runApp(MyApp());
List _rollsCounter = [0,0,0,0,0,0,0,0,0,0,0];
List _rollsInOrder = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice roll counter',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
      ),
      home: RollInput(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RollData {
  int rollNum;
  int amountRolled;
  charts.Color barColor;

  RollData({
    @required this.rollNum,
    @required this.amountRolled,
    @required this.barColor,
  });
}

class RollInput extends StatefulWidget {
  _RollInput createState() => _RollInput();
}

class _RollInput extends State<RollInput> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Dice Roll Counter'),
      ),
      body: _buildRollInput(),
    );
  }

  Widget _buildRollInput(){
    final pgController = PageController(initialPage: 1);
    return SingleChildScrollView(
      child: Column(
        children :[
          Container(
              padding: EdgeInsets.all(10),
              height: 450,
              child: GridButton(
                borderColor: Colors.grey[300],
                borderWidth: 2,
                onPressed: (dynamic value){
                  changeValues(value);
                  setState((){});
                  },
                items: createButtons(),

              )
          ),
          Container(
            padding: EdgeInsets.all(10),
            height: 300,
            child: PageView(
              controller: pgController,
              children:[
                showRollsInOrder(),
                showGraph(),
              ]
            )
          )
        ]

      )
    );
    }

    //Creates the grid buttons.
    List<List<GridButtonItem>> createButtons(){
      List<List<GridButtonItem>> retList = new List();
      for(int i=0; i < 3; i++){
        List<GridButtonItem> innerList = new List();
        for(int j=2; j <= 5; j++) {
          if(i == 2 && j == 5)
            innerList.add(GridButtonItem(title: "<", value: -1, longPressValue: -2));
          else
            innerList.add(GridButtonItem(title: (j + (i*4)).toString(), value: (j + (i*4))));
        }
        retList.add(innerList);
      }
      return retList;
    }

  //Updates the values in the arrays to either remove a single value, all the values, or add a new value.
  void changeValues(value) {
    if(value == -1) { //user shortpresses the backspace button to erase the last roll.
      int remValue = _rollsInOrder.removeLast();
      _rollsCounter[remValue - 2]--;
    }else if(value == -2){  //User longpress backspace to erase all rolls.
      _rollsInOrder = [];
      _rollsCounter = [0,0,0,0,0,0,0,0,0,0,0];
    }else{
      _rollsCounter[value-2] ++ ;
      _rollsInOrder.add(value);
    }
  }

  //turns the rolls in order array into a widget to be displayed.
  Widget showRollsInOrder(){
    String str = "";
    for(int i = 0; i < _rollsInOrder.length; i++){
      str += _rollsInOrder[i].toString();
      if(i < _rollsInOrder.length - 1){
        str += ", ";
     }
    }
    return Column(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Text("Total Rolls: " + _rollsInOrder.length.toString()),
              ),
              Container(
                child: Column(
                  children: [
                    Text("Rolls in Order: "),
                    Text(str),
                  ],
                )
              )


            ]
        );

  }

  //Turns the roll information into a graph to be displayed at the bottom of the page.
  Widget showGraph(){
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
      vertical: false,
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
}

