import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_estudios/screens/main.dart';
import 'package:plan_estudios/database/main.dart';

class SelectDegreeScreen extends StatelessWidget {
  final db = DbHelper();

  void selectedDegree(int id, BuildContext context) async {
    await db.insertDegreeDoing(id);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Seleccione la carrera')),
        body: GridView.count(
            padding: EdgeInsets.all(20),
            mainAxisSpacing: 0.1,
            crossAxisCount: 2,
            children: data
                .map((item) => GestureDetector(
                    onTap: () => selectedDegree(item.id, context),
                    child: Card(
                        color: item.color,
                        margin: EdgeInsets.all(15),
                        elevation: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            item.icon != null
                                ? Icon(item.icon, size: 38)
                                : item.image!,
                            SizedBox(height: 15),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            )
                          ],
                        ))))
                .toList()));
  }
}

class ItemDegree {
  String title;
  Image? image;
  IconData? icon;
  int id;
  Color color;
  ItemDegree(
      {required this.title,
      required this.id,
      required this.color,
      this.icon,
      this.image});
}

final data = [
  ItemDegree(
      title: "CBC",
      id: 12,
      color: Colors.amber[700]!,
      image: Image(
          image: AssetImage('assets/university-buenos-aires.png'),
          width: 80,
          color: Colors.white)),
  ItemDegree(
      title: "Computación",
      id: 3,
      color: Colors.blue[700]!,
      image: Image(
          image: AssetImage('assets/computer-science-logo.png'),
          width: 60,
          color: Colors.white)),
  ItemDegree(
      title: "Química",
      id: 7,
      color: Colors.deepPurple,
      icon: FontAwesomeIcons.flask),
  ItemDegree(
      title: "Física",
      id: 4,
      color: Colors.blueAccent,
      icon: FontAwesomeIcons.atom),
  ItemDegree(
      title: "Biología\n(v2019)",
      id: 1,
      color: Colors.lightGreen,
      icon: FontAwesomeIcons.seedling),
  ItemDegree(
      title: "Matemática\n(PURA)",
      id: 6,
      color: Colors.redAccent,
      icon: FontAwesomeIcons.infinity),
  ItemDegree(
      title: "Matemática\n(APLICADA)",
      id: 11,
      color: Colors.redAccent,
      icon: FontAwesomeIcons.chartPie),
  ItemDegree(
      title: "Paleontología",
      id: 10,
      color: Colors.brown,
      icon: FontAwesomeIcons.atlas),
  ItemDegree(
      title: "CyT Alimentos",
      id: 9,
      color: Colors.deepOrange,
      icon: FontAwesomeIcons.carrot),
  ItemDegree(
      title: "C. Atmósfera",
      id: 5,
      color: Colors.lightBlueAccent,
      icon: FontAwesomeIcons.cloudSunRain),
  ItemDegree(
      title: "C. Geológicas",
      id: 8,
      color: Colors.brown,
      icon: FontAwesomeIcons.globeAmericas),
  ItemDegree(
      title: "Oceonografía",
      id: 14,
      color: Colors.blue[700]!,
      icon: FontAwesomeIcons.water),
];
