import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../main.dart';
import '../models.dart';
import 'package:timezone/timezone.dart' as tz;
import 'initialize.dart';

// CorrelativesSubjects
// DegreeSubjects
// Degrees
// DegreesDoing
// DoneSubjects
// Events
// OptativeSubjects (id, points, name, shortName, idDegree, tp, grade, year, quarter)
// Order
// Subjects

class DbHelper {
  static final DbHelper _dbHelper = DbHelper._internal();
  static Database? _db;

  DbHelper._internal();
  factory DbHelper() {
    return _dbHelper;
  }
  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDB();
    }
    return _db!;
  }

  Future<List<Map>> getDegreesDoing() async {
    return (await (await db).rawQuery(
        'SELECT idDegree, position, name FROM DegreesDoing LEFT JOIN Degrees ON Degrees.id = DegreesDoing.idDegree'));
  }

  Future<List<int>> getDegreesDoingIds() async {
    return (await (await db).query('DegreesDoing', columns: ['idDegree']))
        .map((obj) => (obj['idDegree'] as int))
        .toList();
  }

  Future<Degree> getDegreeInfo(int idDegree) async {
    return (await (await db).query('Degrees',
            columns: ['name', 'shortName', 'id', 'optativePoints'],
            where: '"id" = $idDegree'))
        .map((x) => Degree.fromJson(x))
        .toList()
        .first;
  }

  void insertSubjectDone(int id, bool tp, num grade, DateTime date) async {
    int dateMilis = date.millisecondsSinceEpoch;
    int tpInt = tp as int;
    int id1 = await (await db).rawInsert(
        'INSERT INTO DoneSubjects(id, tp, grade, year, quarter) VALUES($id, $tpInt, $grade, $dateMilis)');
    print('inserted1: $id1');
  }

  void insertOptativeSubject(Subject model, int idDegree) async {
    await (await db).insert('OptativeSubjects', {
      'points': 0,
      'name': model.name,
      'shortName': model.shortName,
      'idDegree': idDegree
    });
  }

  Future<List<SubjectWithUserInfo>> getInfoSubjects(int idDegree) async {
    return (await (await db).rawQuery('''
          SELECT Subjects.id, name, tp, doingNow, grade, year, quarter, shortName FROM DegreeSubjects 
          LEFT JOIN DoneSubjects ON DoneSubjects.id = DegreeSubjects.idSubject 
          LEFT JOIN Subjects ON Subjects.id = DegreeSubjects.idSubject 
          WHERE DegreeSubjects.idDegree = $idDegree'''))
        .map((x) => SubjectWithUserInfo.fromJson(x))
        .toList();
  }

  Future<List<OptativeSubjectWithUserInfo>> getInfoOptatives(
      int idDegree) async {
    return (await (await db).query('OptativeSubjects',
            columns: [
              'idDegree',
              'id',
              'name',
              'tp',
              'grade',
              'year',
              'quarter',
              'shortName',
              'points'
            ],
            where: 'idDegree = $idDegree'))
        .map((x) => OptativeSubjectWithUserInfo.fromJson(x))
        .toList();
  }

  Future<List<Subject>> getCorrelativesToApprove(int id) async {
    return (await (await db).rawQuery('''
        SELECT name, Subjects.id AS id, shortName FROM CorrelativesSubjects 
        INNER JOIN Subjects ON CorrelativesSubjects.idCorrelative = Subjects.id
        LEFT JOIN DoneSubjects ON DoneSubjects.id = CorrelativesSubjects.idCorrelative
        WHERE CorrelativesSubjects.idSubject = $id AND (DoneSubjects.tp IS NULL OR DoneSubjects.tp = 0) '''))
        .map((e) => Subject.fromJson(e))
        .toList();
  }

  Future<SubjectWithUserInfo?> getSubjectInfoById(int id) async {
    List<Map> data = (await (await db).rawQuery('''
        SELECT name, tp, grade, year, quarter, shortName, Subjects.id, doingNow FROM Subjects 
        LEFT JOIN DoneSubjects ON DoneSubjects.id = Subjects.id
        WHERE Subjects.id = $id'''));
    if (data.isEmpty)
      return null;
    else
      return SubjectWithUserInfo.fromJson(data.first);
  }

  Future<OptativeSubjectWithUserInfo> getSubjectOptativeInfoById(int id) async {
    return (await (await db).query("OptativeSubjects",
            columns: [
              'id',
              'points',
              'name',
              'shortName',
              'idDegree',
              'tp',
              'grade',
              'year',
              'quarter'
            ],
            where: 'id = $id'))
        .map((x) => OptativeSubjectWithUserInfo.fromJson(x))
        .first;
  }

  Future<int> deleteOptativeSubject(int id) async {
    return (await (await db)
        .delete('OptativeSubjects', where: 'id = ?', whereArgs: [id]));
  }

  Future<bool> saveSubjectInfo(SubjectWithUserInfo data) async {
    var dbAux = await db;
    var checkExist = await dbAux.query('DoneSubjects',
        columns: ['id'], where: 'id = ${data.id}');
    if (checkExist.length == 0)
      await dbAux.insert('DoneSubjects', {
        'id': data.id,
        'tp': data.tp == true ? 1 : 0,
        'grade': data.grade,
        'year': data.year,
        'quarter': data.quarter,
        'doingNow': data.doingNow == true ? 1 : 0
      });
    else
      await dbAux.update(
          'DoneSubjects',
          {
            'tp': data.tp == true ? 1 : 0,
            'grade': data.grade,
            'year': data.year,
            'quarter': data.quarter,
            'doingNow': data.doingNow == true ? 1 : 0
          },
          where: 'id = ${data.id}');

    return true;
  }

  Future<bool> saveOptativeSubjectInfo(OptativeSubjectWithUserInfo data) async {
    var dbAux = await db;
    var checkExist = await dbAux.query('OptativeSubjects',
        columns: ['id'], where: 'id = ${data.id}');
    if (checkExist.length == 0)
      await dbAux.insert('OptativeSubjects', {
        'id': data.id,
        'tp': data.tp == true ? 1 : 0,
        'grade': data.grade,
        'year': data.year,
        'quarter': data.quarter,
        'points': data.points,
        'idDegree': data.idDegree,
        'name': data.name
      });
    else
      await dbAux.update(
          'OptativeSubjects',
          {
            'tp': data.tp == true ? 1 : 0,
            'grade': data.grade,
            'year': data.year,
            'quarter': data.quarter,
            'points': data.points,
            'idDegree': data.idDegree,
            'name': data.name
          },
          where: 'id = ${data.id}');

    return true;
  }

  Future<List<Subject>> getCorrelatives(int id) async {
    List<Map> data = await (await db).rawQuery('''
        SELECT idCorrelative as id, name, shortName FROM CorrelativesSubjects
        LEFT JOIN Subjects ON Subjects.id = CorrelativesSubjects.idCorrelative
        WHERE idSubject = $id
        ''');

    return data.map((x) => Subject.fromJson(x)).toList();
  }

  Future<List<Map>> getDegrees() async {
    return (await (await db).query('Degrees', columns: ['name', 'id']));
  }

  Future<bool> insertDegreeDoing(int id) async {
    await (await db).insert('DegreesDoing', {'idDegree': id});
    return true;
  }

  Future<bool> deleteDegreeDoing() async {
    await (await db).delete('DegreesDoing');
    return true;
  }

  Future<Map<DateTime, List<Event>>> getEvents() async {
    Map<DateTime, List<Event>> response = Map<DateTime, List<Event>>();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final data =
        (await firestore.collection('events').get()) //TODO: Catch error
            .docs
            .map((v) => EventFb.fromJson(v.data()!))
            .toList();

    for (var i in data) {
      var event = Event(text: i.text, color: Colors.green[400]!, type: i.type);
      DateTime aux = removeFormat(i.dateStart).subtract(Duration(days: 1));
      do {
        aux = aux.add(Duration(days: 1));
        if (response[removeFormat(i.dateEnd)] == null)
          response[removeFormat(aux)] = [event];
        else
          response[removeFormat(aux)]!.add(event);
      } while (i.dateEnd.day != aux.day || i.dateEnd.month != aux.month);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finalesNotifications = prefs.getBool('finalesNotifications') ?? false;
    //await prefs.setBool('finalesNotifications', counter);
    if (finalesNotifications) {
      final Map<String, bool> mapaNotificacionesPendientes =
          new Map<String, bool>();
      final List<PendingNotificationRequest> pendingNotificationRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      pendingNotificationRequests.forEach((element) {
        String index = element.payload!;
        mapaNotificacionesPendientes[index] = true;
      });

      for (var i in data) {
        if (i.type == TypeEvent.inscripcion_finales) {
          if (mapaNotificacionesPendientes[
                  i.dateStart.toString() + i.type.toString()] !=
              true) {
            await flutterLocalNotificationsPlugin.zonedSchedule(
                0,
                'scheduled title',
                'scheduled body',
                tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
                const NotificationDetails(
                    android: AndroidNotificationDetails('your channel id',
                        'your channel name', 'your channel description')),
                androidAllowWhileIdle: true,
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
                payload: i.dateStart.toString() + i.type.toString());
            mapaNotificacionesPendientes[
                i.dateStart.toString() + i.type.toString()] = true;
          }
        }
      }
    }

    return response;
  }

  Future<List<Subject>> searchSubjects(String v) async {
    if (v == "") return <Subject>[];
    return (await (await db).rawQuery('''
      SELECT id, name, shortName FROM Subjects WHERE name LIKE '%$v%' OR shortName LIKE '%$v%'
    ''')).map((e) => Subject.fromJson(e)).toList();
  }
}

DateTime removeFormat(DateTime v) => DateTime(v.year, v.month, v.day);
