import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plan_estudios/database.dart';
import 'package:plan_estudios/models.dart';
import 'edit_subject_optative.dart';

class SubjectEditScreen extends StatefulWidget {
  const SubjectEditScreen({Key key, this.subjectId}) : super(key: key);
  final int subjectId;

  @override
  SubjectEditScreenState createState() => SubjectEditScreenState();
}

int diffYears() => DateTime.now().difference(DateTime(2020)).inDays ~/ 365;

class SubjectEditScreenState extends State<SubjectEditScreen> {
  final List<String> cursadas = [
    'Seleccionar',
    'Verano',
    '1° Cuatrimestre',
    'Invierno',
    '2° Cuatrimestre'
  ];

  final List<String> yearsList = List<String>.generate(
          diffYears() + 9,
          (i) =>
              (DateTime.now().year - (diffYears() + 9 - (i + 1))).toString()) +
      ['Seleccionar'];

  int cursadaMes = 0;
  String yearDone = DateTime.now().year.toString();
  SubjectWithUserInfo _data;
  List<Subject> _correlatives = <Subject>[];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    var db = DbHelper();
    SubjectWithUserInfo aux = await db.getSubjectInfoById(widget.subjectId);
    List<Subject> aux2 = await db.getCorrelatives(widget.subjectId);

    if (aux.tp == null) aux.tp = false;

    setState(() {
      _data = aux;
      _correlatives = aux2;
    });
  }

  Future<bool> saveData() async {
    var db = DbHelper();
    await db.saveSubjectInfo(_data);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) return Container();

    return WillPopScope(
      onWillPop: () => saveData(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Color(0xff2E3136),
        appBar: AppBar(
            toolbarOpacity: 0.52,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text("Editar Materia")),
        body: Container(
          decoration: BoxDecoration(
              gradient:
                  RadialGradient(center: Alignment(0, -1.6), radius: 3, stops: [
            0.2,
            0.6
          ], colors: [
            _data.tp
                ? (_data.grade != null ? Color(0xff00AF89) : Colors.purple[600])
                : Colors.transparent,
            Colors.transparent
          ])),
          child: Column(
            children: <Widget>[
              SizedBox(height: 100),
              Padding(
                padding: EdgeInsets.all(25),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TitleSubject(name: _data.name),
                      SizedBox(height: 20),
                      CheckboxListTile(
                        value: _data.tp,
                        activeColor: Colors.blueAccent,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool value) {
                          setState(() {
                            _data.tp = value;
                            _data.grade = null;
                          });
                        },
                        title: Text("Trabajos Prácticos Aprobados"),
                      ),
                      SizedBox(height: 20),
                      GradeSubjectInput(
                          disabledHint: 'TPs no aprobados',
                          disabled: _data.tp == null || _data.tp == false,
                          grade: _data.grade,
                          notifyParent: (int grade) {
                            setState(() {
                              _data.grade = grade;
                            });
                          }),
                      SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Flexible(
                              child: DropdownButtonFormField<String>(
                            decoration:
                                InputDecoration(labelText: 'Cuatrimestre'),
                            value: cursadas[
                                _data.quarter == null ? 0 : _data.quarter],
                            items: cursadas.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              var quarter = cursadas.indexOf(newValue);
                              if (quarter == 0) quarter = null;
                              setState(() {
                                _data.quarter = quarter;
                              });
                            },
                          )),
                          SizedBox(width: 10),
                          Flexible(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: 'Año'),
                              value: _data.year != null
                                  ? _data.year.toString()
                                  : 'Seleccionar',
                              items: yearsList.map((String value) {
                                value = value;
                                return DropdownMenuItem<String>(
                                  value: value.toString(),
                                  child: new Text(value.toString()),
                                );
                              }).toList(),
                              onChanged: (String newValue) {
                                if (newValue == 'Seleccionar') {
                                  setState(() {
                                    _data.year = null;
                                  });
                                } else {
                                  setState(() {
                                    _data.year = int.parse(newValue);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _Correlatives(correlatives: _correlatives)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Correlatives extends StatelessWidget {
  _Correlatives({this.correlatives});
  final List<Subject> correlatives;

  @override
  Widget build(BuildContext ctx) {
    if (correlatives.length == 0) return Container();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(18),
            child: Text(
              "Correlativas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: correlatives
                  .map((c) => Row(
                        children: <Widget>[
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                          ),
                          SizedBox(width: 15),
                          Text(c.name)
                        ],
                      ))
                  .toList(),
            ),
          )
        ]);
  }
}
