import 'package:flutter/material.dart';
class BirthData {
  final String name;
  final DateTime date;
  final TimeOfDay time;
  final String location;

  BirthData({
    required this.name,
    required this.date,
    required this.time,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
      'location': location,
    };
  }
}