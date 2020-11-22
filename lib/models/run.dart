import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Run extends Equatable {
  final String mapImage;
  final String title;
  final String note;
  final DateTime startDate;
  final Duration totalTime;
  final double distance;
  final double avgSpeed;
  final double topSpeed;

  Run({
    @required this.title,
    @required this.note,
    @required this.totalTime,
    @required this.startDate,
    @required this.distance,
    @required this.avgSpeed,
    @required this.topSpeed,
    @required this.mapImage,
  });

  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      mapImage: json['mapImage'],
      title: json['title'],
      note: json['note'],
      distance: json['distance'],
      avgSpeed: json['avgSpeed'],
      topSpeed: json['topSpeed'],
      totalTime: Duration(
        milliseconds: int.parse(json["totalTime"]),
      ),
      startDate: DateTime.parse(
        json["startDate"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["title"] = this.title;
    data["note"] = this.note;
    data["distance"] = this.distance;
    data["avgSpeed"] = this.avgSpeed;
    data["topSpeed"] = this.topSpeed;
    data["mapImage"] = this.mapImage;
    data["totalTime"] = this.totalTime.inMilliseconds.toString();
    data["startDate"] = this.startDate.toIso8601String();
    return data;
  }

  @override
  List<Object> get props => [
        this.title,
        this.note,
        this.totalTime,
        this.startDate,
        this.distance,
        this.avgSpeed,
        this.topSpeed,
        this.mapImage,
      ];
}
