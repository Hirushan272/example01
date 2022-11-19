import 'dart:convert';

class PositionModel {
  double? lat;
  double? long;
  DateTime? time;
  PositionModel({
    this.lat,
    this.long,
    this.time,
  });

  PositionModel copyWith({
    double? lat,
    double? long,
    DateTime? time,
  }) {
    return PositionModel(
      lat: lat ?? this.lat,
      long: long ?? this.long,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'long': long,
      'time': time?.millisecondsSinceEpoch,
    };
  }

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    return PositionModel(
      lat: map['lat']?.toDouble(),
      long: map['long']?.toDouble(),
      time: map['time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['time'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PositionModel.fromJson(String source) =>
      PositionModel.fromMap(json.decode(source));

  @override
  String toString() => 'PositionModel(lat: $lat, long: $long, time: $time)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PositionModel &&
        other.lat == lat &&
        other.long == long &&
        other.time == time;
  }

  @override
  int get hashCode => lat.hashCode ^ long.hashCode ^ time.hashCode;
}
