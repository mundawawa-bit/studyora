import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/login_view.dart';
import 'views/dashboard_view.dart';
import 'views/course_view.dart';
import 'views/task_view.dart';
import 'views/study_planner_view.dart';
import 'views/report_view.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart'; // Import service notifikasi

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studyora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8C72EC)),
        scaffoldBackgroundColor: const Color(0xFFF8F8FC),
        useMaterial3: true,
      ),
      // Mengecek status autentikasi secara real-time
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              return const LoginView();
            } else {
              return const MainNavigator(); // Membawa kembali semua fitur lengkap!
            }
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF8C72EC)),
            ),
          );
        },
      ),
    );
  }
}

// Navigasi Bawah dengan Semua Fitur Lengkapmu
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const CourseView(),
    const TaskView(),
    const StudyPlannerView(),
    const ReportView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF5A4B81),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Matkul'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tugas'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart_rounded), label: 'Laporan'),
        ],
      ),
    );
  }
}