
class Subject {
  Subject({this.name, this.shortName, this.id});
  String name;
  String shortName;
  int id;
  Subject.fromJson(Map json) {
    name = json['name'];
    shortName = json['shortName'];
    id = json['id'];
  }
}

class Event {
  Event({this.text, this.colorHex});
  final String text;
  final int colorHex;
}

class SubjectWithUserInfo extends Subject {
  SubjectWithUserInfo.fromJson(Map json) : super.fromJson(json){
    grade = json['grade'];
    year = json['year'];
    quarter = json['quarter'];
    tp = json['tp'] == null ? false : (json['tp'] == 1 ? true : false);
  }
  num grade;
  bool tp;
  int year;
  //Cuatrimestre de cursada: 0 (verano), 1 (1er cuatri), 2 (invierno), 3 (2do cuatri)
  int quarter;
}

class OptativeSubjectWithUserInfo extends SubjectWithUserInfo {
  OptativeSubjectWithUserInfo.fromJson(Map json) : super.fromJson(json){
    points = json['points'];
    idDegree = json['idDegree'];
  }
  int points;
  int idDegree;
}

class Degree {
  Degree({this.name, this.shortName, this.id});
  String name;
  String shortName;
  int id;
  int optativePoints;

  Degree.fromJson(Map json){ 
    name = json['name'];
    shortName = json['shortName'];
    id = json['id'];
    optativePoints = json['optativePoints'];
  }
}

enum Fechas {
  verano,
  primerCuatri,
  invierno,
  segundoCuatri,
}