import 'package:flutter/material.dart';
import 'package:plan_estudios/database/main.dart';
import 'package:plan_estudios/models.dart';
import 'package:flutter/services.dart';

import 'edit_subject.dart';
import 'edit_subject_optative.dart';
import 'header_card.dart';
import 'subject_tile.dart';

class StudyProgramScreen extends StatefulWidget {
  final List<int> degreeIds;

  StudyProgramScreen({Key? key, required this.degreeIds}) : super(key: key);

  @override
  _StudyProgramScreenState createState() => _StudyProgramScreenState();
}

class _StudyProgramScreenState extends State<StudyProgramScreen>
    with AutomaticKeepAliveClientMixin {
  List<SubjectWithUserInfo>? infoSubjects;
  List<OptativeSubjectWithUserInfo>? infoOptatives;
  Map<int, List<Subject>>? correlativesToDo;
  late num averageDegree,
      amountSubjects,
      countPassed,
      passedWithoutFinal,
      optativePoints;
  late Degree degree;
  var db = DbHelper();

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void didUpdateWidget(StudyProgramScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.degreeIds != widget.degreeIds) getData();
  }

  void getData() async {
    List<SubjectWithUserInfo> infoSubjects =
        await db.getInfoSubjects(this.widget.degreeIds.first);
    List<OptativeSubjectWithUserInfo> infoOptatives =
        await db.getInfoOptatives(widget.degreeIds.first);
    Map<int, List<Subject>> correlativesToDo = Map<int, List<Subject>>();

    for (SubjectWithUserInfo x in infoSubjects)
      correlativesToDo[x.id] = await db.getCorrelativesToApprove(x.id);

    num sumDegree = 0,
        quantityDone = 0,
        quantityOptativesDone = 0,
        quantityOnlyTp = 0;
    for (var x in infoSubjects) {
      if (x.grade != null) {
        sumDegree += x.grade!;
        quantityDone += 1;
      } else {
        if (x.tp != null && x.tp == true) quantityOnlyTp += 1;
      }
    }
    for (var x in infoOptatives) {
      if (x.grade != null) {
        sumDegree += x.grade!;
        quantityOptativesDone += 1;
      }
    }

    int optativePoints = 0;
    infoOptatives.forEach((a) {
      if (a.points != null && a.tp == true && a.grade != null)
        optativePoints += a.points;
    });

    var degree = await db.getDegreeInfo(this.widget.degreeIds.first);

    setState(() {
      this.infoSubjects = infoSubjects;
      this.infoOptatives = infoOptatives;
      this.averageDegree = quantityDone != 0
          ? sumDegree / (quantityDone + quantityOptativesDone)
          : 0;
      this.amountSubjects = infoSubjects.length;
      this.countPassed = quantityDone;
      this.passedWithoutFinal = quantityOnlyTp;
      this.degree = degree;
      this.correlativesToDo = correlativesToDo;
      this.optativePoints = optativePoints;
    });
  }

  void addOptative() {
    db.insertOptativeSubject(
        Subject(
          id: 1,
          name: "Materia Optativa",
        ),
        widget.degreeIds.first);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (infoSubjects == null) return Container();
    return ListView.builder(
        itemCount: infoSubjects!.length + 1 + infoOptatives!.length + 1,
        itemBuilder: (context, i) {
          final int subjectsIndex = i - 1;
          final int optativesIndex = i - infoSubjects!.length - 1;
          final int headerCardIndex = 0;
          final int optativesStartIndex = infoSubjects!.length + 1;
          final int addOptativeButtonIndex =
              infoSubjects!.length + 1 + infoOptatives!.length;

          if (i == headerCardIndex) {
            return HeaderCard(
                average: averageDegree,
                passed: countPassed,
                amount: amountSubjects,
                passedWithoutFinal: passedWithoutFinal,
                title: degree.name,
                optativePoints: optativePoints,
                amountOptativePoints: degree.optativePoints!);
          }
          if (i == addOptativeButtonIndex) {
            return ButtonAddOptativeSubject(addOptative: addOptative);
          }

          SubjectWithUserInfo subject;
          bool canBeAproved;
          if (i < optativesStartIndex) {
            subject = infoSubjects![subjectsIndex];
            canBeAproved = correlativesToDo![subject.id]!.length == 0;
          } else {
            subject = infoOptatives![optativesIndex];
            canBeAproved = true;
          }

          return GestureDetector(
            onTap: canBeAproved
                ? () {
                    i < optativesStartIndex
                        ? Navigator.of(context)
                            .push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    SubjectEditScreen(subjectId: subject.id)),
                          )
                            .then((_) {
                            getData();
                          })
                        : Navigator.of(context)
                            .push(
                            MaterialPageRoute(
                                builder: (context) => OptativeSubjectEditScreen(
                                    subjectId: subject.id)),
                          )
                            .then((_) {
                            getData();
                          });
                  }
                : () {
                    HapticFeedback.vibrate();
                  },
            child: SubjectTile(
              subject: subject,
              canBeAproved: canBeAproved,
              correlatives: correlativesToDo![subject.id]!
                  .map((x) => x.shortName ?? x.name)
                  .toList(),
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class ButtonAddOptativeSubject extends StatelessWidget {
  ButtonAddOptativeSubject({Key? key, required this.addOptative})
      : super(key: key);
  final void Function() addOptative;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 16, left: 26, right: 26),
        child: ElevatedButton(
            onPressed: addOptative, child: Text("Agregar Optativa")));
  }
}
