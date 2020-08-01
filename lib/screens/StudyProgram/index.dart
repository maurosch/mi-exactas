import 'package:flutter/material.dart';
import 'package:plan_estudios/database.dart';
import 'package:plan_estudios/models.dart';
import 'package:flutter/services.dart';

import 'edit_subject.dart';
import 'edit_subject_optative.dart';
import 'header_card.dart';
import 'search_subject.dart';
import 'subject_tile.dart';

class StudyProgramScreen extends StatefulWidget {
  final List<int> degreeIds;

  StudyProgramScreen({Key key, this.degreeIds}) : super(key: key);

  @override
  _StudyProgramScreenState createState() => _StudyProgramScreenState();
}

class _StudyProgramScreenState extends State<StudyProgramScreen>
    with AutomaticKeepAliveClientMixin {
  List<SubjectWithUserInfo> infoSubjects;
  List<OptativeSubjectWithUserInfo> infoOptatives;
  Map<int, List<Subject>> correlativesToDo;
  num averageDegree,
      amountSubjects,
      countPassed,
      passedWithoutFinal,
      optativePoints;
  Degree degree;
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

    num sumDegree = 0, quantity = 0, quantityOnlyTp = 0;
    for (var x in infoSubjects) {
      if (x.grade != null) {
        sumDegree += x.grade;
        quantity += 1;
      } else {
        if (x.tp != null && x.tp == true) quantityOnlyTp += 1;
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
      this.averageDegree = quantity != 0 ? sumDegree / quantity : 0;
      this.amountSubjects = infoSubjects.length;
      this.countPassed = quantity;
      this.passedWithoutFinal = quantityOnlyTp;
      this.degree = degree;
      this.correlativesToDo = correlativesToDo;
      this.optativePoints = optativePoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (infoSubjects == null) return Container();
    return ListView.builder(
        itemCount: infoSubjects.length + 1 + infoOptatives.length + 1,
        itemBuilder: (context, i) {
          final int subjectsIndex = i - 1;
          final int optativesIndex = i - infoSubjects.length - 1;
          final int headerCardIndex = 0;
          final int optativesStartIndex = infoSubjects.length + 1;
          final int addOptativeButtonIndex =
              infoSubjects.length + 1 + infoOptatives.length;

          if (i == headerCardIndex) {
            return HeaderCard(
                average: averageDegree,
                passed: countPassed,
                amount: amountSubjects,
                passedWithoutFinal: passedWithoutFinal,
                title: degree.name,
                optativePoints: optativePoints,
                amountOptativePoints: degree.optativePoints);
          }
          if (i == addOptativeButtonIndex) {
            return Container(
                margin: EdgeInsets.only(bottom: 16, left: 26, right: 26),
                child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => SearchSubjectScreen(
                                  idDegree: widget.degreeIds.first)))
                          .then((_) => getData());
                    },
                    child: Text("Agregar Optativa")));
          }

          var subject, canBeAproved;
          if (i < optativesStartIndex) {
            subject = infoSubjects[subjectsIndex];
            canBeAproved = correlativesToDo[subject.id].length == 0;
          } else {
            subject = infoOptatives[optativesIndex];
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
              name:
                  subject.shortName != null ? subject.shortName : subject.name,
              idSubject: subject.id,
              tp: subject.tp ? true : false,
              grade: subject.grade,
              canBeAproved: canBeAproved,
              correlatives: correlativesToDo[subject.id]
                  .map((x) => x.shortName != null ? x.shortName : x.name)
                  .toList(),
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
