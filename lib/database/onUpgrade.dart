import 'package:sqflite/sqflite.dart';
import 'initialize.dart';

void onUpgradeDatabase(Database db, int oldVersion, int newVersion) async {
  print('Actualizando db de ' +
      oldVersion.toString() +
      ' a ' +
      newVersion.toString());

  //Obtenemos la nueva version de la base de datos

  final dbNameFile = "plan_estudios.db";
  final dbNameDelete = "plan_estudios_delete.db";
  final pathDelete = await getPathDatabase(dbNameDelete);

  await copyAssetDatabase(pathDelete, dbNameFile);

  Database _dbNew = await openDatabase(pathDelete, readOnly: true);

  await db.rawDelete('DELETE FROM Subjects');
  await db.rawDelete('DELETE FROM Degrees');
  await db.rawDelete('DELETE FROM CorrelativesSubjects');

  var collection =
      await _dbNew.query('Subjects', columns: ['id', 'name', 'shortName']);
  var batch = db.batch();
  for (var x in collection) {
    batch.insert('Subjects',
        {'id': x['id'], 'name': x['name'], 'shortName': x['shortName']});
  }

  collection = await _dbNew
      .query('Degrees', columns: ['id', 'name', 'shortName', 'optativePoints']);
  for (var x in collection) {
    batch.insert('Degrees', {
      'id': x['id'],
      'name': x['name'],
      'shortName': x['shortName'],
      'optativePoints': x['optativePoints']
    });
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

  await _dbNew.close();
  print("Borrando base de datos auxiliar");
  await deleteDatabase(pathDelete);

  await batch.commit(noResult: true);

  fundamentalUpgradeChanges(db, oldVersion);

  await db.setVersion(newVersion);
  await db.close();
}

void updateSubjects() {}
void fundamentalUpgradeChanges(Database db, int oldVersion) {
  //Ir poniendo las modificaciones de cada actualizacion a la base de datos
  if (oldVersion <= 1) {
    db.execute("ALTER TABLE DoneSubjects ADD COLUMN doingNow INTEGER;");
    db.execute("ALTER TABLE OptativeSubjects ADD COLUMN doingNow INTEGER;");
  }
}
