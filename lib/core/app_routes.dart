import 'package:flutter/material.dart';

// Mövcud native ekranlar
import 'package:azmiu_app/presentation/screens/grades_screen.dart';
import 'package:azmiu_app/presentation/screens/home_screen.dart';
import 'package:azmiu_app/presentation/screens/login_screen.dart';
import 'package:azmiu_app/presentation/screens/menu_screen.dart';
import 'package:azmiu_app/presentation/screens/news_list_screen.dart';
import 'package:azmiu_app/presentation/screens/notification_screen.dart';
import 'package:azmiu_app/presentation/screens/schedule_screen.dart';
import 'package:azmiu_app/presentation/screens/services_screen.dart';
import 'package:azmiu_app/presentation/screens/settings_screen.dart';
import 'package:azmiu_app/presentation/screens/splash_screen.dart';
import 'package:azmiu_app/presentation/screens/student_card_screen.dart';
import 'package:azmiu_app/presentation/screens/student_info_screen.dart';

// YENİ NATİVE EKRANLAR
import 'package:azmiu_app/presentation/screens/curriculum_screen.dart';
import 'package:azmiu_app/presentation/screens/materials_screen.dart';
import 'package:azmiu_app/presentation/screens/journal_screen.dart';
import 'package:azmiu_app/presentation/screens/exam_questions_screen.dart';
import 'package:azmiu_app/presentation/screens/online_lessons_screen.dart';
import 'package:azmiu_app/presentation/screens/exam_schedule_screen.dart';
import 'package:azmiu_app/presentation/screens/final_grades_screen.dart';
import 'package:azmiu_app/presentation/screens/virtual_card_screen.dart';
import 'package:azmiu_app/presentation/screens/profile_screen.dart'; // YENİ

// WEBVIEW
import 'package:azmiu_app/presentation/screens/web_content_screen.dart';
import 'package:azmiu_app/presentation/screens/auth_lock_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const String authLock = '/auth-lock';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/';
  static const String schedule = '/schedule';
  static const String grades = '/grades';
  static const String studentCard = '/student-card';
  static const String studentInfo = '/student-info';
  static const String profile = '/profile'; // YENİ
  static const String services = '/services';
  static const String news = '/news';
  static const String settings = '/settings';
  static const String menu = '/menu';
  static const String notifications = '/notifications';
  static const String virtualCard = '/virtual-card';

  // Digər keçidlər
  static const String curriculum = '/curriculum';
  static const String journal = '/journal';
  static const String materials = '/materials';
  static const String examQuestions = '/exam-questions';
  static const String onlineLessons = '/online-lessons';
  static const String examSchedule = '/exam-schedule';
  static const String finalGrades = '/final-grades';
  static const String appeal = '/appeal';
  static const String lms = '/lms';
  static const String usefulLinks = '/useful-links';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case schedule:
        page = const ScheduleScreen();
        break;
      case grades:
        page = const GradesScreen();
        break;
      case studentCard:
        page = const StudentCardScreen();
        break;
      case studentInfo:
        page = const StudentInfoScreen();
        break;
      case profile: // YENİ
        page = const ProfileScreen();
        break;
      case services:
        page = const ServicesScreen();
        break;
      case news:
        page = const NewsListScreen();
        break;
      case AppRoutes.settings:
        page = const SettingsScreen();
        break;
      case menu:
        page = const MenuScreen();
        break;
      case notifications:
        page = const NotificationScreen();
        break;
      case virtualCard:
        page = const VirtualCardScreen();
        break;
      
      // NATIVE SƏHİFƏLƏR
      case curriculum:
        page = const CurriculumScreen();
        break;
      case materials:
        page = const MaterialsScreen();
        break;
      case journal:
        page = const JournalScreen();
        break;
      case examQuestions:
        page = const ExamQuestionsScreen();
        break;
      case onlineLessons:
        page = const OnlineLessonsScreen();
        break;
      case examSchedule:
        page = const ExamScheduleScreen();
        break;
      case finalGrades:
        page = const FinalGradesScreen();
        break;

        case authLock:
  page = const AuthLockScreen();
  break;

      // WEBVIEW SƏHİFƏLƏRİ
      case appeal:
        page = const WebContentScreen(title: 'Onlayn apellyasiya', path: '/appeal/view');
        break;
      case lms:
        page = const WebContentScreen(title: 'LMS', path: '/lmsLogin/l');
        break;
      case usefulLinks:
        page = const WebContentScreen(title: 'Faydalı linklər', path: '');
        break;

      case home:
      default:
        page = const HomeScreen();
    }
    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }
}