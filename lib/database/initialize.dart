import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'onUpgrade.dart';

const LAST_DB_VERSION = 2;

Future<Database> initializeDB() async {
  var dbName = "plan_estudios.db";
  var path = await getPathDatabase(dbName);

  // Check if the database exists
  var exists = await databaseExists(path);

  if (!exists) {
    print("No existe ninguna base de datos");
    await copyAssetDatabase(path, dbName);
    Database db = await openDatabase(path);
    await db.setVersion(LAST_DB_VERSION);
    return db;
  }

  print("Abriendo base de datos existente...");
  return await openDatabase(path,
      version: LAST_DB_VERSION, onUpgrade: onUpgradeDatabase);
}

Future<String> getPathDatabase(String dbName) async =>
    join(await getDatabasesPath(), dbName);

Future<void> copyAssetDatabase(String saveToPath, String dbName) async {
  // Should happen only the first time you launch your application
  print("Copiando base de datos desde assets");

  // Make sure the parent directory exists
  try {
    await Directory(dirname(saveToPath)).create(recursive: true);
  } catch (_) {}

  // Copy from asset
  ByteData data = await rootBundle.load(join("assets", dbName));
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  // Write and flush the bytes written
  await File(saveToPath).writeAsBytes(bytes, flush: true);
}
