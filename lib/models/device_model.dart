import 'package:flutter/material.dart';

class DeviceModel {
  final String id;
  String title;
  String value;
  String status;
  IconData icon;
  Color color;

  DeviceModel({
    required this.id,
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'status': status,
      'icon': icon.codePoint,
      'color': color.value,
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'] as String,
      title: map['title'] as String,
      value: map['value'] as String,
      status: map['status'] as String,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] as int),
    );
  }
}
