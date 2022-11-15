import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:example01/models/position_model.dart';

class LocationModel {
  List<PositionModel>? location;
  LocationModel({
    this.location,
  });

  LocationModel copyWith({
    List<PositionModel>? location,
  }) {
    return LocationModel(
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location': location?.map((x) => x.toMap()).toList(),
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      location: map['location'] != null
          ? List<PositionModel>.from(
              map['location']?.map((x) => PositionModel.fromMap(x)))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationModel.fromJson(String source) =>
      LocationModel.fromMap(json.decode(source));

  @override
  String toString() => 'LocationModel(location: $location)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is LocationModel && listEquals(other.location, location);
  }

  @override
  int get hashCode => location.hashCode;
}
