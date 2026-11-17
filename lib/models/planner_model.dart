import 'package:flutter/material.dart';

class PlannerModel {
  final String id;
  final String title;
  final String? courseName;
  final String notes;
  final bool isCompleted;
  final DateTime dueDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String plannerType;
  final int durationInMinutes;

  PlannerModel({
    required this.id,
    required this.title,
    this.courseName,
    required this.notes,
    required this.isCompleted,
    required this.dueDate,
    required this.startTime,
    required this.endTime,
    required this.plannerType,
    required this.durationInMinutes,
  });

  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return pDate.isBefore(today);
  }
}