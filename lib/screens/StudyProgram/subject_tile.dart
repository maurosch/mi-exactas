import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubjectTile extends StatelessWidget {
  SubjectTile(
      {this.idSubject,
      this.name,
      this.grade,
      this.tp,
      this.canBeAproved,
      this.correlatives});
  final String name;
  final num grade;
  final bool tp;
  final bool canBeAproved;
  final int idSubject;
  final List<String> correlatives;

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: canBeAproved ? 0.9 : 0.4,
        child: Card(
            color: Color(0xff2E3136),
            margin: EdgeInsets.only(bottom: 10, left: 8, right: 8),
            child: Container(
              padding:
                  EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 10),
              decoration: canBeAproved
                  ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      gradient: LinearGradient(
                          begin: Alignment(-1, 2),
                          end: Alignment(1, -2),
                          stops: [
                            0.6,
                            0.8
                          ],
                          colors: [
                            Colors.transparent,
                            grade == null
                                ? (tp == true
                                    ? Colors.purple[600]
                                    : Colors.transparent)
                                : Colors.teal
                          ]),
                    )
                  : BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      color: Colors.transparent),
              child: Container(
                  child: Row(
                children: <Widget>[
                  SizedBox(height: 35),
                  Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Text(
                        "$name",
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      )),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: _Trailing(
                      canBeAproved: canBeAproved,
                      tp: tp,
                      grade: grade,
                      correlatives: correlatives,
                    ),
                  )
                ],
              )),
            )));
  }
}

class _Trailing extends StatelessWidget {
  _Trailing({this.canBeAproved, this.tp, this.grade, this.correlatives});
  final num grade;
  final bool tp;
  final bool canBeAproved;
  final List<String> correlatives;

  String removeDecimalZeroFormat(num n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }

  @override
  Widget build(BuildContext ctx) {
    Widget result;
    if (canBeAproved) {
      if (grade == null) {
        if (tp == true)
          return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(right: 2),
                    child: Text(
                      "FINAL",
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 18.0),
                    )),
                SizedBox(width: 5),
                Icon(FontAwesomeIcons.chevronRight),
              ]);

        return Container(
            alignment: Alignment.centerRight,
            child: Icon(FontAwesomeIcons.chevronRight));
      } else {
        return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Nota",
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  removeDecimalZeroFormat(grade),
                  style: TextStyle(fontSize: 20.0),
                )
              ]),
          SizedBox(width: 18),
          Icon(FontAwesomeIcons.chevronRight),
        ]);
      }
    } else {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
                Text(
                  "Correlativas",
                  style: TextStyle(
                    fontSize: 9.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] +
              correlatives
                  .map((n) => Container(
                      child: Text(n,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 10,
                          ))))
                  .toList());
    }
  }
}
