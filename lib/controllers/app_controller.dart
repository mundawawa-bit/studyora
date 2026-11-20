import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course_model.dart';
import '../models/task_model.dart';
import '../models/planner_model.dart';
import '../services/firestore_service.dart';

class AppController {
  static final AppController _instance = AppController._internal();
  factory AppController() => _instance;
  AppController._internal() {
    initListeners();
  }

  final FirestoreService _firestoreService = FirestoreService();
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  List<CourseModel> courses = [];
  List<TaskModel> tasksList = [];
  List<PlannerModel> planners = [];

  void initListeners() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // Listener Mata Kuliah
        _firestoreService.getCourses(user.uid).listen((snapshot) {
          courses = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CourseModel(
              id: doc.id,
              courseName: data['courseName'] ?? '',
              lecturer: data['lecturer'] ?? '',
            );
          }).toList();
        });

        // Listener Tugas (Menggunakan TaskModel)
        _firestoreService.getTasks(user.uid).listen((snapshot) {
          tasksList = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TaskModel(
              id: doc.id,
              title: data['title'] ?? '',
              course: data['course'] ?? '',
              notes: data['notes'] ?? '',
              dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : DateTime.now(),
              isCompleted: data['isCompleted'] ?? false,
            );
          }).toList();
        });

        // Listener Study Planner
        _firestoreService.getPlanners(user.uid).listen((snapshot) {
          planners = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return PlannerModel(
              id: doc.id,
              title: data['title'] ?? '',
              courseName: data['courseName'],
              notes: data['notes'] ?? '',
              isCompleted: data['isCompleted'] ?? false,
              dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : DateTime.now(),
              startTime: TimeOfDay(
                hour: data['startTimeHour'] ?? 8,
                minute: data['startTimeMinute'] ?? 0,
              ),
              endTime: TimeOfDay(
                hour: data['endTimeHour'] ?? 10,
                minute: data['endTimeMinute'] ?? 0,
              ),
              plannerType: data['plannerType'] ?? 'Daily',
              durationInMinutes: data['durationInMinutes'] ?? 0,
            );
          }).toList();
        });
      } else {
        courses.clear();
        tasksList.clear();
        planners.clear();
      }
    });
  }

  int get totalCourses => courses.length;
  int get totalTasks => tasksList.length;
  int get completedTasks => tasksList.where((t) => t.isCompleted == true).length;

  int get activeTasksCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return tasksList.where((t) {
      final taskDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      bool isNotExpired = taskDate.isAfter(today) || taskDate.isAtSameMomentAs(today);
      return t.isCompleted == false && isNotExpired;
    }).length;
  }

  int get totalPlanners => planners.length;
  int get completedPlanners => planners.where((p) => p.isCompleted).length;
  int get missedPlanners => planners.where((p) => !p.isCompleted && p.isExpired).length;
  int get uncompletedPlanners => planners.where((p) => !p.isCompleted && !p.isExpired).length;

  List<PlannerModel> get todayPlanners {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return planners.where((p) {
      final pDate = DateTime(p.dueDate.year, p.dueDate.month, p.dueDate.day);
      return pDate.isAtSameMomentAs(today) && !p.isCompleted && !p.isExpired;
    }).toList();
  }

  String get weeklyStudyTimeText {
    int totalMinutes = 0;
    for (var p in planners.where((item) => item.isCompleted)) {
      totalMinutes += p.durationInMinutes;
    }
    return formatMinutesToText(totalMinutes);
  }

  // --- MATA KULIAH (COURSES) ---
  Future<void> addCourse(String name, String lecturer) async {
    if (_uid == null) return;
    await _firestoreService.addCourse(_uid!, {'courseName': name, 'lecturer': lecturer});
  }

  Future<void> editCourse(String id, String name, String lecturer) async {
    if (_uid == null) return;
    await _firestoreService.updateCourse(_uid!, id, {'courseName': name, 'lecturer': lecturer});
  }

  Future<void> deleteCourse(String id) async {
    if (_uid == null) return;
    await _firestoreService.deleteCourse(_uid!, id);
  }

  // --- STUDY PLANNER ---
  Future<void> addPlanner({
    required String title,
    String? courseName,
    String notes = '',
    required DateTime dueDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String plannerType,
  }) async {
    if (_uid == null) return;

    int startTotalMinutes = startTime.hour * 60 + startTime.minute;
    int endTotalMinutes = endTime.hour * 60 + endTime.minute;
    int calculatedDuration = endTotalMinutes - startTotalMinutes;
    if (calculatedDuration <= 0) {
      calculatedDuration = 60;
    }

    await _firestoreService.addPlanner(_uid!, {
      'title': title,
      'courseName': courseName,
      'notes': notes,
      'dueDate': dueDate.toIso8601String(),
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime.hour,
      'endTimeMinute': endTime.minute,
      'plannerType': plannerType,
      'isCompleted': false,
      'durationInMinutes': calculatedDuration,
    });
  }

  Future<void> togglePlannerCompletion(String id) async {
    if (_uid == null) return;
    final index = planners.indexWhere((p) => p.id == id);
    if (index != -1) {
      final plan = planners[index];
      bool newStatus = !plan.isCompleted;
      int startMins = plan.startTime.hour * 60 + plan.startTime.minute;
      int endMins = plan.endTime.hour * 60 + plan.endTime.minute;
      int diffFromTime = endMins - startMins;
      int planDuration = diffFromTime > 0
          ? diffFromTime
          : (plan.durationInMinutes > 0 ? plan.durationInMinutes : 60);
      int newDuration = newStatus ? planDuration : 0;
      await _firestoreService.updatePlannerCompletion(_uid!, id, newStatus, newDuration);
    }
  }

  // --- TUGAS (TASKS) ---
  Future<void> addTaskData({
    required String title,
    required String course,
    required String notes,
    required DateTime dueDate,
  }) async {
    if (_uid == null) return;
    await _firestoreService.addTask(_uid!, {
      'title': title,
      'course': course,
      'notes': notes,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': false,
    });
  }

  Future<void> updateTaskStatus(String id, bool isCompleted) async {
    if (_uid == null) return;
    await _firestoreService.updateTaskStatus(_uid!, id, isCompleted);
  }

  Future<void> deleteTask(String id) async {
    if (_uid == null) return;
    await _firestoreService.deleteTask(_uid!, id);
  }

  // --- FORMAT WAKTU & LAPORAN ---
  String formatMinutesToText(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) return '$hours Jam $minutes Mnt';
    if (hours > 0) return '$hours Jam';
    return '$minutes Mnt';
  }

  List<String> get availableMonths {
    Set<String> months = {};
    for (var p in planners.where((item) => item.isCompleted)) {
      String mKey = '${p.dueDate.year}-${p.dueDate.month.toString().padLeft(2, '0')}';
      months.add(mKey);
    }
    String currentMonthKey = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    months.add(currentMonthKey);

    List<String> sortedMonths = months.toList();
    sortedMonths.sort((a, b) => b.compareTo(a));
    return sortedMonths;
  }

  String formatMonthName(String yearMonthKey) {
    try {
      final parts = yearMonthKey.split('-');
      int month = int.parse(parts[1]);
      int year = int.parse(parts[0]);
      const months = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${months[month]} $year';
    } catch (e) {
      return yearMonthKey;
    }
  }

  Map<String, dynamic> getReportDataForMonth(String yearMonthKey) {
    final parts = yearMonthKey.split('-');
    int targetYear = int.parse(parts[0]);
    int targetMonth = int.parse(parts[1]);

    final monthPlans = planners.where((p) {
      return p.isCompleted && p.dueDate.year == targetYear && p.dueDate.month == targetMonth;
    }).toList();

    Map<String, int> dailyMinutes = {};
    int totalMonthMinutes = 0;
    int week1Mins = 0, week2Mins = 0, week3Mins = 0, week4Mins = 0;

    for (var p in monthPlans) {
      int day = p.dueDate.day;
      int mins = p.durationInMinutes;
      String dateKey = '${day.toString().padLeft(2, '0')}/${p.dueDate.month.toString().padLeft(2, '0')}/${p.dueDate.year}';
      dailyMinutes[dateKey] = (dailyMinutes[dateKey] ?? 0) + mins;
      totalMonthMinutes += mins;

      if (day <= 7) {
        week1Mins += mins;
      } else if (day <= 14) {
        week2Mins += mins;
      } else if (day <= 21) {
        week3Mins += mins;
      } else {
        week4Mins += mins;
      }
    }

    return {
      'daily': dailyMinutes,
      'totalWeekMinutes': totalMonthMinutes,
      'totalMonthMinutes': totalMonthMinutes,
      'weeklyBreakdown': {
        'Minggu 1 (Tgl 1-7)': week1Mins,
        'Minggu 2 (Tgl 8-14)': week2Mins,
        'Minggu 3 (Tgl 15-21)': week3Mins,
        'Minggu 4 (Tgl 22+)': week4Mins,
      },
    };
  }
}