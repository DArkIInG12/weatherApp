import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:weather/models/location_model.dart';

class WeatherDataBase {
  static const db_name = 'Weatherdb';
  static const versiondb = 1;

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    return _database = await _initDatabase();
  }

  Future<Database?> _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String pathdb = join(dir.path, db_name);
    return openDatabase(pathdb, version: versiondb, onCreate: _createTables);
  }

  FutureOr<void> _createTables(Database db, int version) {
    String locations =
        '''create table locations(location_id integer primary key,location_name text,
    latitude real, longitude real)''';

    db.execute(locations);
  }

  // ignore: non_constant_identifier_names
  Future<int> INSERT(Map<String, dynamic> data) async {
    var connection = await database;
    return connection!.insert("locations", data);
  }

  // ignore: non_constant_identifier_names
  Future<int> UPDATE(Map<String, dynamic> data) async {
    var connection = await database;
    return connection!.update("locations", data,
        where: 'location_id = ?', whereArgs: [data['location_id']]);
  }

  // ignore: non_constant_identifier_names
  Future<int> DELETE(int objectId) async {
    var connection = await database;
    return connection!
        .delete("locations", where: 'location_id = ?', whereArgs: [objectId]);
  }

  // ignore: non_constant_identifier_names
  Future<List<LocationModel>> GETALLLOCATIONS() async {
    var connection = await database;
    var result = await connection!.query('locations');
    return result.map((location) => LocationModel.fromMap(location)).toList();
  }
}
