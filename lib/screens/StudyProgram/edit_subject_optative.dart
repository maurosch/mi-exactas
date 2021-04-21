import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plan_estudios/database/main.dart';
import 'package:plan_estudios/models.dart';
import 'package:plan_estudios/util.dart';

import 'edit_subject.dart';

class OptativeSubjectEditScreen extends StatefulWidget {
  const OptativeSubjectEditScreen({Key? key, required this.subjectId})
      : super(key: key);
  final int subjectId;

  @override
  OptativeSubjectEditScreenState createState() =>
      OptativeSubjectEditScreenState();
}

int diffYears() => DateTime.now().difference(DateTime(2020)).inDays ~/ 365;

class OptativeSubjectEditScreenState extends State<OptativeSubjectEditScreen> {
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
  OptativeSubjectWithUserInfo? _data;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    var db = DbHelper();
    OptativeSubjectWithUserInfo aux =
        await db.getSubjectOptativeInfoById(widget.subjectId);

    if (aux.tp == null) aux.tp = false;

    setState(() {
      _data = aux;
    });
  }

  Future<bool> saveData() async {
    var db = DbHelper();
    await db.saveOptativeSubjectInfo(_data!);
    return true;
  }

  Future<void> goBack() async {

	  await saveData();
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
            actions: <Widget>[
              _TrashIcon(parentContext: context, subjectId: widget.subjectId),
            ],
            toolbarOpacity: 0.52,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text("Editar Materia Optativa")),
        body: Container(
          decoration: BoxDecoration(
              gradient: RadialGradient(
                  center: Alignment(0, -1.6),
                  radius: 3,
                  stops: [0.2, 0.6],
                  colors: [getColorSubject(_data!), Colors.transparent])),
          child: Column(
            children: <Widget>[
              SizedBox(height: 100),
              Padding(
                padding: EdgeInsets.all(25),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TitleSubject(
                          name: _data!.name,
                          notifyParent: (String name) {
                            setState(() {
                              _data!.name = name;
                            });
                            print(_data!.name);
                            print(_data!.shortName);
                          }),
                      SizedBox(height: 20),
                      CheckboxListTile(
                        value: _data!.doingNow == true,
                        activeColor: Colors.blueAccent,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          setState(() {
                            _data!.doingNow = value;
                            _data!.tp = null;
                            _data!.grade = null;
                          });
                        },
                        title: Text("Cursando"),
                      ),
                      CheckboxListTile(
                        value: _data!.tp == true,
                        activeColor: Colors.blueAccent,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          setState(() {
                            _data!.tp = value;
                            _data!.grade = null;
                            _data!.doingNow = null;
                          });
                        },
                        title: Text("Trabajos Prácticos Aprobados"),
                      ),
                      SizedBox(height: 20),
                      Row(children: <Widget>[
                        Flexible(
                            child: GradeSubjectInput(
                                disabledHint: 'TP no ap.',
                                disabled:
                                    _data!.tp == null || _data!.tp == false,
                                grade: _data!.grade,
                                notifyParent: (int? grade) {
                                  setState(() {
                                    _data!.grade = grade;
                                  });
                                })),
                        SizedBox(width: 10),
                        Flexible(
                            child: TextFormField(
                          initialValue: _data!.points.toString(),
                          onChanged: (String value) {
                            setState(() {
                              _data!.points = int.parse(value);
                            });
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration:
                              InputDecoration(labelText: "Puntos Optativa"),
                        ))
                      ]),
                      SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          SelectCuatrimestre(
                              quarter: _data!.quarter,
                              notifyParent: (int? v) => setState(() {
                                    _data!.quarter = v;
                                  })),
                          SizedBox(width: 10),
                          Flexible(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: 'Año'),
                              value: _data!.year != null
                                  ? _data!.year.toString()
                                  : 'Seleccionar',
                              items: yearsList.map((String value) {
                                value = value;
                                return DropdownMenuItem<String>(
                                  value: value.toString(),
                                  child: new Text(value.toString()),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null && newValue != 'Año') {
                                  setState(() {
                                    _data!.year = int.parse(newValue);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
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

class GradeSubjectInput extends StatelessWidget {
  const GradeSubjectInput(
      {this.grade,
      required this.notifyParent,
      required this.disabled,
      required this.disabledHint});
  final num? grade;
  final Function(int?) notifyParent;
  final bool disabled;
  final String disabledHint;

  @override
  Widget build(BuildContext ctx) {
    final List<String> gradesList =
        ['Sin Aprobar'] + List<String>.generate(10, (i) => (i + 1).toString());

    final String gradeValue =
        grade == null ? gradesList[0] : grade!.truncate().toString();

    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
        decoration: InputDecoration(labelText: 'Nota Materia'),
        child: DropdownButton<String>(
          disabledHint: Text(disabledHint),
          isDense: true,
          isExpanded: true,
          underline: Container(),
          value: gradeValue,
          items: gradesList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList(),
          onChanged: disabled
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    int? aux = gradesList.indexOf(newValue);
                    if (aux == 0) aux = null;
                    notifyParent(aux);
                  }
                },
        ),
      );
    });
  }
}

class _TrashIcon extends StatelessWidget {
  _TrashIcon({required this.parentContext, required this.subjectId});
  final BuildContext parentContext;
  final int subjectId;

  Future<void> deleteSubject() async {
    var db = DbHelper();
    await db.deleteOptativeSubject(subjectId);
    Navigator.pop(parentContext);
    Navigator.pop(parentContext);
  }

  @override
  Widget build(BuildContext ctx) {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () => showDialog(
        barrierDismissible: true,
        context: parentContext,
        builder: (_) => AlertDialog(
          title: Text("Eliminar la optativa"),
          content: Text("¿Está seguro que quiere eliminar la optativa?"),
          actions: <Widget>[
            TextButton(
                onPressed: () =>
                    Navigator.of(parentContext, rootNavigator: true).pop(),
                child: Text("Cancelar")),
            TextButton(onPressed: deleteSubject, child: Text("Continuar"))
          ],
        ),
      ),
    );
  }
}

class TitleSubject extends StatelessWidget {
  TitleSubject({required this.name, required this.notifyParent});
  final String name;
  final Function(String) notifyParent;

  @override
  Widget build(BuildContext ctx) {
    return Container(
      //width: 100,
      margin: EdgeInsets.all(10),
      child: TextFormField(
		  
          initialValue: name,
          decoration: InputDecoration(suffixIcon: Icon(Icons.edit)),
		  onChanged: notifyParent),
    );
  }
}
