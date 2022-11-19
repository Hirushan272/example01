import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:example01/models/position_model.dart';

class LocationModel {
  List<PositionModel>? location;
  DateTime? time;
  LocationModel({
    this.location,
    this.time,
  });

  LocationModel copyWith({
    List<PositionModel>? location,
    DateTime? time,
  }) {
    return LocationModel(
      location: location ?? this.location,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location': location?.map((x) => x.toMap()).toList(),
      'time': time?.millisecondsSinceEpoch,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      location: map['location'] != null
          ? List<PositionModel>.from(
              map['location']?.map((x) => PositionModel.fromMap(x)))
          : null,
      time: map['time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['time'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationModel.fromJson(String source) =>
      LocationModel.fromMap(json.decode(source));

  static LocationModel decode(String topic) => (json.decode(topic) as dynamic)
      .map<LocationModel>((item) => LocationModel.fromJson(item))
      .toList();

  @override
  String toString() => 'LocationModel(location: $location, time: $time)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is LocationModel &&
        listEquals(other.location, location) &&
        other.time == time;
  }

  @override
  int get hashCode => location.hashCode ^ time.hashCode;
}
