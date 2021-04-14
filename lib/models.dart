import 'dart:ui';

class Subject {
  Subject({required this.name, this.shortName, required this.id});
  String name;
  String? shortName;
  int id;
  Subject.fromJson(Map json)
      : name = json['name'],
        shortName = json['shortName'],
        id = json['id'];
}

class EventFb {
  final DateTime dateStart;
  final DateTime dateEnd;
  final String text;
  final TypeEvent type;

  EventFb.fromJson(Map json)
      : dateStart = json["date_start"].toDate() as DateTime,
        dateEnd = json["date_end"].toDate() as DateTime,
        text = json["name"],
        type = TypeEvent.values[json["type"]];
}

class Event {
  Event({required this.text, required this.color, required this.type});
  final String text;
  final Color color;
  final TypeEvent type;
}

enum TypeEvent { inscripcion_finales, finales }

class SubjectWithUserInfo extends Subject {
  num? grade;
  bool? tp;
  bool? doingNow;
  int? year;
  //Cuatrimestre de cursada: 0 (verano), 1 (1er cuatri), 2 (invierno), 3 (2do cuatri)
  int? quarter;

  SubjectWithUserInfo.fromJson(Map json)
      : grade = json['grade'],
        year = json['year'],
        quarter = json['quarter'],
        tp = json['tp'] == null ? false : (json['tp'] == 1 ? true : false),
        doingNow = json['doingNow'] == null
            ? false
            : (json['doingNow'] == 1 ? true : false),
        super.fromJson(json);
}

class OptativeSubjectWithUserInfo extends SubjectWithUserInfo {
  int points;
  int idDegree;
  OptativeSubjectWithUserInfo.fromJson(Map json)
      : points = json['points'],
        idDegree = json['idDegree'],
        super.fromJson(json);
}

class Degree {
  String name;
  String? shortName;
  int id;
  int? optativePoints;
  Degree({required this.name, this.shortName, required this.id});

  Degree.fromJson(Map json)
      : name = json['name'],
        shortName = json['shortName'],
        id = json['id'],
        optativePoints = json['optativePoints'];
}

enum Fechas {
  verano,
  primerCuatri,
  invierno,
  segundoCuatri,
}
