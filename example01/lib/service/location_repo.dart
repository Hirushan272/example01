import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:example01/models/position_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

class Repo {
  static Repo? _instance;

  Repo._();

  factory Repo() => _instance ??= Repo._();

  PositionModel? convertToLocation(BackgroundLocationUpdateData data) {
    PositionModel position = PositionModel();
    position.lat = data.lat;
    position.long = data.lon;
    position.time = DateTime.now();
    print("RUN: convertFunc");
    return position;
  }

  List<PositionModel> p = [];
  Future<void> update(BackgroundLocationUpdateData data) async {
    final text = 'TTTTOTTT: Lat: ${data.lat} Lon: ${data.lon}';
    print(text); // ignore: avoid_print
    LocationModel? location;
    PositionModel? position;
    print("DATA LIST LENGTH ${p.length}");

    p = [...p, PositionModel(lat: data.lat, long: data.lon)];

    location = await LocationDao().readLocationData();
    if (location == null) {
      location = LocationModel(location: []);
    } else if (location.location == null) {
      location.location = [];
    } else {
      position = convertToLocation(data);
      location.location?.add(position!);
    }
    await LocationDao().saveDataLocally(location);

    // sendNotification(text);
  }
}

class LocationDao {
  static const _locationsKey = 'locations';

  static LocationDao? _instance;

  LocationDao._();

  factory LocationDao() => _instance ??= LocationDao._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> saveDataLocally(LocationModel locations) async {
    final prefs = await this.prefs;
    await prefs.reload();
    final value = locations.toJson();
    await prefs.setString(_locationsKey, value);
  }

  // Future<List<String>> getLocations() async {
  //   final prefs = await this.prefs;
  //   await prefs.reload();
  //   final locationsString = prefs.getString(_locationsKey);
  //   if (locationsString == null) return [];
  //   return locationsString.split(_locationSeparator);
  // }

  Future<LocationModel?> readLocationData() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationModel? locationData;
    final prefs = await this.prefs;
    await prefs.reload();
    try {
      String? value = prefs.getString(_locationsKey);
      print("HELLO HELLO $value");
      if (value != null) {
        locationData = LocationModel.fromJson(value);
      }
    } catch (e) {
      print("Error $e");
    }
    return locationData;
  }

  // Future<void> saveLocation(BackgroundLocationUpdateData data) async {
  // final locations = await getLocations();
  //   locations.add(
  //       '${DateTime.now().toIso8601String()}       ${data.lat},${data.lon}');
  //   await (await prefs)
  //       .setString(_locationsKey, locations.join(_locationSeparator));
  // }
}
