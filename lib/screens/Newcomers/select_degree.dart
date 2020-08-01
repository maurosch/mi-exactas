import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_estudios/screens/main.dart';
import 'package:plan_estudios/database.dart';

class SelectDegreeScreen extends StatelessWidget {
  final db = DbHelper();

  void selectedDegree(int id, BuildContext context) async{
    await db.insertDegreeDoing(id);
    Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (context) => 
        MainScreen())
    );
  }
  var data = [ //FIXME: Hacer más genérico
    {
      "title": "Química",
      "icon": FontAwesomeIcons.flask,
      "color": Colors.deepPurple,
      "id": 7
    },{
      "title": "Física",
      "icon": FontAwesomeIcons.atom,
      "color": Colors.blueAccent,
      "id": 4
    },{
      "title": "Biología\n(v2019)",
      "icon": FontAwesomeIcons.seedling,
      "color": Colors.lightGreen,
      "id": 1
    },{
      "title": "Matemática\n(PURA)",
      "icon": FontAwesomeIcons.infinity,
      "color": Colors.redAccent,
      "id": 6
    },{
      "title": "Matemática\n(APLICADA)",
      "icon": FontAwesomeIcons.chartPie,
      "color": Colors.redAccent,
      "id": 11
    }
  ];
   
  @override 
  Widget build(BuildContext context) {    
    return 
      Scaffold(
       appBar: AppBar(
         title: Text('Seleccione la carrera')
       ),
       body: 
        GridView.count(
          padding: EdgeInsets.all(20),
          mainAxisSpacing: 0.1,
          crossAxisCount: 2,
          children: [
            GestureDetector(
                onTap: () => selectedDegree(12, context),
                child:
                Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(15),
                    elevation: 10,
                    child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(image: AssetImage('assets/university-buenos-aires.png'), width: 80),
                          SizedBox(height:5),
                          Text("CBC",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500
                            ),)
                        ],
                      )
                  )
              ),
              GestureDetector(
                onTap: () => selectedDegree(3, context),
                child:
                  Card(
                    color: Color(0xff008296),
                    margin: EdgeInsets.all(15),
                    elevation: 10,
                    child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(image: AssetImage('assets/computer-science-logo.png'), width: 60, color: Colors.white),
                          SizedBox(height:5),
                          Text("Computación",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500
                            ),)
                        ],
                      )
                  )
              )
          ]+
            data.map(
              (item) => 
              GestureDetector(
                onTap: () => selectedDegree(item['id'], context),
                child:
                Card(
                  color: item["color"],
                  margin: EdgeInsets.all(15),
                  elevation: 10,
                  child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(item['icon'], size: 38),
                        SizedBox(height:15),
                        Text(item['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500
                          ),)
                      ],
                    )
                ))).toList()
            

        )
        );
  }
}