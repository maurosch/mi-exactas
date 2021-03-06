import 'package:flutter/material.dart';
import 'package:plan_estudios/database/main.dart';

class ChangeDegreeScreen extends StatelessWidget {
  final db = DbHelper();

  void selectedDegree(int id, String nameDegree, BuildContext context) async {
    await db.deleteDegreeDoing();
    await db.insertDegreeDoing(id);
    Navigator.pop(context, nameDegree);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Seleccione la carrera')),
        body: FutureBuilder(
            future: db.getDegrees(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();

              List<Map> subjectsList = snapshot.data as List<Map>;
              return ListView.separated(
                itemCount: subjectsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      child: ListTile(
                    title: Text(subjectsList[index]['name']),
                    onTap: () => selectedDegree(subjectsList[index]['id'],
                        subjectsList[index]['name'], context),
                  ));
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              );
            }));
  }
}
