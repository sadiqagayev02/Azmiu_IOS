import 'package:flutter/material.dart';
import 'package:azmiu_app/core/app_routes.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/data/models/news_model.dart';
import 'package:azmiu_app/data/models/student_model.dart';
import 'package:azmiu_app/data/repositories/azmiu_repository.dart';
import 'package:azmiu_app/data/services/storage_service.dart';
import 'package:azmiu_app/data/mock/mock_data.dart';
import 'package:azmiu_app/presentation/widgets/animated_student_card.dart';
import 'package:azmiu_app/presentation/widgets/bottom_nav_bar.dart';
import 'package:azmiu_app/presentation/widgets/greeting_section.dart';
import 'package:azmiu_app/presentation/widgets/header_section.dart';
import 'package:azmiu_app/presentation/widgets/info_section.dart';
import 'package:azmiu_app/presentation/widgets/news_section.dart';
import 'package:azmiu_app/presentation/widgets/quick_actions.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  final AzmiuRepository _repo = AzmiuRepository();

  StudentModel? _student;
  List<NewsModel> _news = MockData.mockNews();

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // 1. Yaddaşdan oxu (sürətli olsun deyə)
    final cached = await _storage.getStudent();
    if (cached != null && mounted) {
      setState(() => _student = cached);
    }

    // 2. API-dən real məlumatı çək
    try {
      await _repo.init();
      final data = await _repo.fetchDashboard();
      if (!mounted) return;

      final student = data['student'] as StudentModel;
      final news = data['news'] as List<NewsModel>;

      setState(() {
        if (student.fullName.isNotEmpty) _student = student;
        if (news.isNotEmpty) _news = news;
        _loading = false;
      });

      if (student.fullName.isNotEmpty) {
        await _storage.saveStudent(student);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.menu);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _student?.displayName ?? 'Tələbə';

    return Scaffold(
      // Body navbarın arxasına qədər uzansın: navbarın yanlarında və
      // altında boş (ağ) zolaq qalmasın, ekran görünsün.
      extendBody: true,
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavBar(currentIndex: 0, onTap: _onNavTap),
      body: Stack(
        children: [
          // Arxa plan şəkli
                    // Arxa plan şəkli (tam en)
          Positioned(
            top: 0,
            right: 0,
            left: 0, // Sol tərəf də 0 olsun ki, şəkil tam enə otursun
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(60)),
              child: Container(
                width: double.infinity, // Tam en
                height: 260,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/azmiu_building.jpg'),
                    fit: BoxFit.cover, // Şəkil çərçivəyə tam otursun
                  ),
                ),
              ),
            ),
          ),
          // Gradient overlay
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            height: 350,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background.withValues(alpha: 0.85),
                    AppColors.background.withValues(alpha: 0.4),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Loading indikatoru
          if (_loading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
            ),

          // Əsas məzmun
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _loadAll,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                 HeaderSection(
  onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
  onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile), // YENİ
),
                  GreetingSection(studentName: displayName),

                  const SizedBox(height: 10),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Məlumat çəkilə bilmədi. Yenidən cəhd edin.',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                            GestureDetector(
                              onTap: _loadAll,
                              child: const Icon(Icons.refresh, size: 18, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_student != null)
  AnimatedStudentCard(
    student: _student!,
    onTap: () {
      Navigator.pushNamed(context, AppRoutes.studentCard);
    },
  ),

                  const SizedBox(height: 20),
                  const QuickActions(),
                  const SizedBox(height: 20),
                  NewsSection(news: _news),
                  const SizedBox(height: 20),
                  const InfoSection(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}