import 'dart:convert';

class PositionModel {
  double? lat;
  double? long;
  PositionModel({
    this.lat,
    this.long,
  });

  PositionModel copyWith({
    double? lat,
    double? long,
  }) {
    return PositionModel(
      lat: lat ?? this.lat,
      long: long ?? this.long,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'long': long,
    };
  }

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    return PositionModel(
      lat: map['lat']?.toDouble(),
      long: map['long']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PositionModel.fromJson(String source) =>
      PositionModel.fromMap(json.decode(source));

  @override
  String toString() => 'PositionModel(lat: $lat, long: $long)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PositionModel && other.lat == lat && other.long == long;
  }

  @override
  int get hashCode => lat.hashCode ^ long.hashCode;
}
