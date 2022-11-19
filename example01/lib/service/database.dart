import 'dart:convert';

import 'package:example01/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/position_model.dart';

class DatabaseService {
  Database? _database;
  Database? get database => _database;

  Future<void> createDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = "$databasesPath/demo.db";

    _database = await openDatabase(path);
  }

  Future<void> saveDataLocally(LocationModel locations) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = locations.toJson();
    await prefs.setString('locations', value.toString());
  }

  Future<LocationModel?> readLocationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // final locations = ;
    try {
      String? value = prefs.getString("locations");
      if (value != null) {
        LocationModel locationData = LocationModel.fromJson(value);

        return locationData;
      }
    } catch (e) {
      print("Error $e");
    }
  }

  void removeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      prefs.remove("locations");
    } catch (e) {
      print("ERROR ON DELETE $e");
    }
  }
}
