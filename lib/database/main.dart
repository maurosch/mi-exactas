import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
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
    return (await (await db).query(
        'DegreesDoing LEFT JOIN Degrees ON Degrees.id = DegreesDoing.idDegree',
        columns: ['idDegree', 'position', 'name']));
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

  void insertOptativeSubject(Subject model, int idDegree) async {
    await (await db).insert('OptativeSubjects', {
      'points': 0,
      'name': model.name,
      'shortName': model.shortName,
      'idDegree': idDegree
    });
  }

  Future<List<SubjectWithUserInfo>> getInfoSubjects(int idDegree) async {
    return (await (await db).query('''
			DegreeSubjects 
          	LEFT JOIN DoneSubjects ON DoneSubjects.id = DegreeSubjects.idSubject 
          	LEFT JOIN Subjects ON Subjects.id = DegreeSubjects.idSubject''',
            columns: [
          'Subjects.id',
          'name',
          'tp',
          'doingNow',
          'grade',
          'year',
          'quarter',
          'shortName'
        ],
            where: 'DegreeSubjects.idDegree = $idDegree'))
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
              'points',
              'doingNow'
            ],
            where: 'idDegree = $idDegree'))
        .map((x) => OptativeSubjectWithUserInfo.fromJson(x))
        .toList();
  }

  Future<List<Subject>> getCorrelativesToApprove(int id) async {
    return (await (await db).query('''CorrelativesSubjects 
        INNER JOIN Subjects ON CorrelativesSubjects.idCorrelative = Subjects.id
        LEFT JOIN DoneSubjects ON DoneSubjects.id = CorrelativesSubjects.idCorrelative''',
            columns: ['name', 'Subjects.id AS id', 'shortName'],
            where:
                'CorrelativesSubjects.idSubject = $id AND (DoneSubjects.tp IS NULL OR DoneSubjects.tp = 0)'))
        .map((e) => Subject.fromJson(e))
        .toList();
  }

  Future<SubjectWithUserInfo?> getSubjectInfoById(int id) async {
    List<Map> data = (await (await db).query(
        'Subjects LEFT JOIN DoneSubjects ON DoneSubjects.id = Subjects.id',
        columns: [
          'name',
          'tp',
          'grade',
          'year',
          'quarter',
          'shortName',
          'Subjects.id',
          'doingNow'
        ],
        where: 'Subjects.id = $id'));

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
              'quarter',
              'doingNow'
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
        'name': data.name,
        'doingNow': data.doingNow == true ? 1 : 0
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
            'name': data.name,
            'doingNow': data.doingNow == true ? 1 : 0
          },
          where: 'id = ${data.id}');

    return true;
  }

  Future<List<Subject>> getCorrelatives(int id) async {
    List<Map> data = await (await db).query('''CorrelativesSubjects
        LEFT JOIN Subjects ON Subjects.id = CorrelativesSubjects.idCorrelative''',
        columns: ['idCorrelative as id', 'name', 'shortName'],
        where: 'idSubject = $id');

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

  

  Future<List<Subject>> searchSubjects(String v) async {
    if (v == "") return <Subject>[];
    return (await (await db).rawQuery('''
      SELECT id, name, shortName FROM Subjects WHERE name LIKE '%$v%' OR shortName LIKE '%$v%'
    ''')).map((e) => Subject.fromJson(e)).toList();
  }
}

DateTime removeFormat(DateTime v) => DateTime(v.year, v.month, v.day);
