import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Simpan data profil / user tambahan
  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // --- MATA KULIAH (COURSES) ---
  Stream<QuerySnapshot> getCourses(String uid) {
    return _db.collection('users').doc(uid).collection('courses').snapshots();
  }

  Future<void> addCourse(String uid, Map<String, dynamic> courseData) async {
    await _db.collection('users').doc(uid).collection('courses').add(courseData);
  }

  Future<void> updateCourse(String uid, String courseId, Map<String, dynamic> courseData) async {
    await _db.collection('users').doc(uid).collection('courses').doc(courseId).update(courseData);
  }

  Future<void> deleteCourse(String uid, String courseId) async {
    await _db.collection('users').doc(uid).collection('courses').doc(courseId).delete();
  }

  // --- STUDY PLANNER (PLANNERS) ---
  Stream<QuerySnapshot> getPlanners(String uid) {
    return _db.collection('users').doc(uid).collection('planners').snapshots();
  }

  Future<void> addPlanner(String uid, Map<String, dynamic> plannerData) async {
    await _db.collection('users').doc(uid).collection('planners').add({
      ...plannerData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePlannerCompletion(String uid, String plannerId, bool isCompleted, int duration) async {
    await _db.collection('users').doc(uid).collection('planners').doc(plannerId).update({
      'isCompleted': isCompleted,
      'durationInMinutes': duration,
    });
  }

  Future<void> deletePlanner(String uid, String plannerId) async {
    await _db.collection('users').doc(uid).collection('planners').doc(plannerId).delete();
  }

  // --- TUGAS (TASKS) ---
  Stream<QuerySnapshot> getTasks(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addTask(String uid, Map<String, dynamic> taskData) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .add({
          ...taskData,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateTaskStatus(String uid, String taskId, bool isCompleted) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': isCompleted});
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}