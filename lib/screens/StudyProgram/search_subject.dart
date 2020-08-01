import 'package:flutter/material.dart';
import 'package:plan_estudios/database.dart';
import 'package:plan_estudios/models.dart';

class SearchSubjectScreen extends StatefulWidget {
  final int idDegree;
  
  SearchSubjectScreen({this.idDegree, Key key}) : super(key: key);

  @override
  _SearchSubjectScreenState createState() => _SearchSubjectScreenState();
}

class _SearchSubjectScreenState extends State<SearchSubjectScreen> {
  
  var db = DbHelper();
  List<Subject> subjectsList = [];
  TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void selectSubject(Subject model, BuildContext context) async{
    db.insertOptativeSubject(model, widget.idDegree);
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: 
        Padding(
          padding: EdgeInsets.only(left:12),
          child:
            Text("Buscar Materia")),
      ),

      body: 
        ListView.separated(    
          itemCount: subjectsList.length+1,
          itemBuilder: (BuildContext context, int index) {
            if(index == 0)
              return Container(
                margin: EdgeInsets.all(20),
                child: 
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search)
                    ),
                    onChanged: (String value) async {
                      var aux = await db.searchSubjects(value);
                      setState(() {
                        subjectsList = aux;
                      });
                    },
                    controller: _controller
                  ),
              );
            return GestureDetector(
                child:
                  ListTile(
                    title: Text(subjectsList[index-1].name),
                  onTap: () => selectSubject( 
                    Subject(id: 1, name: subjectsList[index-1].name, shortName: subjectsList[index-1].shortName), context),
              )
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        )       
    );
  }
}