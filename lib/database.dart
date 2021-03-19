import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

// CorrelativesSubjects
// DegreeSubjects
// Degrees
// DegreesDoing
// DoneSubjects
// Events
// OptativeSubjects (id, points, name, shortName, idDegree, tp, grade, year, quarter)
// Order
// Subjects

class EventFb {
  EventFb({this.dateStart, this.dateEnd, this.text});
  final DateTime dateStart;
  final DateTime dateEnd;
  final String text;
}



class DbHelper {
  static final DbHelper _dbHelper = DbHelper._internal();
  static final DBVersion = 1;
  static Database _db;

  DbHelper._internal();
  factory DbHelper() {
    return _dbHelper;
  }
  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDB();
    }
    return _db;
  }

  Future<Database> initializeDB() async {
    var dbName = "plan_estudios.db";
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, dbName);

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", dbName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    // open the database
    return await openDatabase(path, version: 1, onUpgrade: _onUpgrade);
    //return await openDatabase(path, version: DBVersion, onCreate: _onCreate);
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Actualizando db de ' +
        oldVersion.toString() +
        ' a ' +
        newVersion.toString());
    var dbName = "plan_estudios.db";
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, dbName);

    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    ByteData data = await rootBundle.load(join("assets", dbName));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await File(path).writeAsBytes(bytes, flush: true);

    await db.rawDelete('DELETE FROM Subjects');
    await db.rawDelete('DELETE FROM Degrees');
    await db.rawDelete('DELETE FROM CorrelativesSubjects');
    await db.rawDelete('DELETE FROM CorrelativesSubjects');

    Database _dbNew = await openDatabase(path, readOnly: true);
    var collection =
        await _dbNew.query('Subjects', columns: ['id', 'name', 'shortName']);
    var batch = db.batch();
    for (var x in collection) {
      batch.insert('Subjects',
          {'id': x['id'], 'name': x['name'], 'shortName': x['shortName']});
    }

    collection =
        await _dbNew.query('Degrees', columns: ['id', 'name', 'shortName', 'optativePoints']);
    for (var x in collection) {
      batch.insert('Degrees',
          {'id': x['id'], 'name': x['name'], 'shortName': x['shortName'], 'optativePoints' : x['optativePoints']});
    }

    collection = await _dbNew
        .query('DegreeSubjects', columns: ['id', 'idDegree', 'idSubject']);
    for (var x in collection) {
      batch.insert('DegreeSubjects', {
        'id': x['id'],
        'idDegree': x['idDegree'],
        'idSubject': x['idSubject']
      });
    }

    collection = await _dbNew.query('CorrelativesSubjects',
        columns: ['id', 'idSubject', 'idCorrelative']);
    for (var x in collection) {
      batch.insert('CorrelativesSubjects', {
        'id': x['id'],
        'idSubject': x['idSubject'],
        'idCorrelative': x['idCorrelative']
      });
    }

    await batch.commit(noResult: true);
    await _dbNew.close();
    await db.setVersion(newVersion);
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
    return (await (await db)
            .query('Degrees', columns: ['name','shortName','id','optativePoints'], where: '"id" = $idDegree'))
            .map( (x) => Degree.fromJson(x) ).toList().first;
  }

  void insertSubjectDone(int id, bool tp, num grade, DateTime date) async {
    int dateMilis = date.millisecondsSinceEpoch;
    int tpInt = tp as int;
    int id1 = await (await db).rawInsert(
        'INSERT INTO DoneSubjects(id, tp, grade, year, quarter) VALUES($id, $tpInt, $grade, $dateMilis)');
    print('inserted1: $id1');
  }

  void insertOptativeSubject(Subject model, int idDegree) async {
    await (await db).insert('OptativeSubjects', 
      {'points': 0,'name': model.name,'shortName': model.shortName,'idDegree': idDegree});
  }

  Future<List<SubjectWithUserInfo>> getInfoSubjects(int idDegree) async {
    return (await (await db).rawQuery('''
          SELECT Subjects.id, name, tp, grade, year, quarter, shortName FROM DegreeSubjects 
          LEFT JOIN DoneSubjects ON DoneSubjects.id = DegreeSubjects.idSubject 
          LEFT JOIN Subjects ON Subjects.id = DegreeSubjects.idSubject 
          WHERE DegreeSubjects.idDegree = $idDegree'''))
          .map( (x) => SubjectWithUserInfo.fromJson(x) ).toList();
  }

  Future<List<OptativeSubjectWithUserInfo>> getInfoOptatives(int idDegree) async {
    return (await (await db).query('OptativeSubjects', columns: ['idDegree', 
      'id', 'name', 'tp', 'grade', 'year', 'quarter', 'shortName', 'points'], where: 'idDegree = $idDegree'))
          .map( (x) => OptativeSubjectWithUserInfo.fromJson(x) ).toList();
  }

  Future<List<Subject>> getCorrelativesToApprove(int id) async {
    return (await (await db).rawQuery('''
        SELECT name, Subjects.id AS id, shortName FROM CorrelativesSubjects 
        INNER JOIN Subjects ON CorrelativesSubjects.idCorrelative = Subjects.id
        LEFT JOIN DoneSubjects ON DoneSubjects.id = CorrelativesSubjects.idCorrelative
        WHERE CorrelativesSubjects.idSubject = $id AND (DoneSubjects.tp IS NULL OR DoneSubjects.tp = 0) '''))
        .map((e) => Subject.fromJson(e)).toList();
  }

  Future<SubjectWithUserInfo> getSubjectInfoById(int id) async {
    List<Map> data = (await (await db).rawQuery('''
        SELECT name, tp, grade, year, quarter, shortName, Subjects.id FROM Subjects 
        LEFT JOIN DoneSubjects ON DoneSubjects.id = Subjects.id
        WHERE Subjects.id = $id'''));
    if (data.isEmpty)
      return null;
    else
      return SubjectWithUserInfo.fromJson(data.first);
  }

  Future<OptativeSubjectWithUserInfo> getSubjectOptativeInfoById(int id) async{
    return (await (await db).query("OptativeSubjects", 
      columns: ['id', 'points', 'name', 'shortName', 'idDegree', 'tp', 'grade', 'year', 'quarter'],
      where: 'id = $id')).map( (x) => OptativeSubjectWithUserInfo.fromJson(x) )?.first;
  }

  Future<int> deleteOptativeSubject(int id) async{
    return (await (await db).delete('OptativeSubjects', where: 'id = ?', whereArgs: [id]));
  }

  Future<bool> saveSubjectInfo(SubjectWithUserInfo data) async {
    var dbAux = await db;
    var checkExist = await dbAux.query('DoneSubjects',
        columns: ['id'], where: 'id = ${data.id}');
    if (checkExist.length == 0)
      await dbAux.insert('DoneSubjects', {
        'id': data.id,
        'tp': data.tp ? 1 : 0,
        'grade': data.grade,
        'year': data.year,
        'quarter': data.quarter
      });
    else
      await dbAux.update(
          'DoneSubjects',
          {
            'tp': data.tp ? 1 : 0,
            'grade': data.grade,
            'year': data.year,
            'quarter': data.quarter
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
        'tp': data.tp ? 1 : 0,
        'grade': data.grade,
        'year': data.year,
        'quarter': data.quarter,
        'points': data.points,
        'idDegree': data.idDegree
      });
    else
      await dbAux.update(
          'OptativeSubjects',
          {
            'tp': data.tp ? 1 : 0,
            'grade': data.grade,
            'year': data.year,
            'quarter': data.quarter,
            'points': data.points,
            'idDegree': data.idDegree
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
    final prefs = await SharedPreferences.getInstance();
    final eventsLastUpdate = prefs.getInt('eventsLastUpdate') ?? 0;

    var dbAux = await db;
    Map<DateTime, List<Event>> response = Map<DateTime, List<Event>>();


    // Access Firestore using the default Firebase app:
	FirebaseFirestore firestore = FirebaseFirestore.instance;

	final data = (await firestore.collection('events').get())
		.docs.map((v) => v.data() as EventFb).toList();

	for (var i in data) {
		var event = Event(text: i.text, colorHex: int.parse("0xfffff"));
		if (response[i.dateStart] == null)
			response[i.dateStart] = [event];
		else
			response[i.dateStart].add(event);
	}


    /* //Obtengo del servidor que todavía no hice
    if (eventsLastUpdate == 0 ||
        DateTime.fromMillisecondsSinceEpoch(eventsLastUpdate)
                .difference(DateTime.now())
                .inDays >
            1) {*/
      
   
	/*var result =
		await dbAux.query('Events', columns: ['date', 'text', 'colorHex']);
	for (var i in result) {
	var event =
		Event(text: i['text'], colorHex: int.parse("0xff${i['colorHex']}"));
	if (response[DateTime.parse(i['date'])] == null)
		response[DateTime.parse(i['date'])] = [event];
	else
		response[DateTime.parse(i['date'])].add(event);
	}*/

    return response;
  }

  Future<List<Subject>> searchSubjects(String v) async {
    if(v == "")
      return <Subject>[];
    return (await (await db).rawQuery('''
      SELECT id, name, shortName FROM Subjects WHERE name LIKE '%$v%' OR shortName LIKE '%$v%'
    ''')).map((e) => Subject.fromJson(e)).toList();
  }
}
