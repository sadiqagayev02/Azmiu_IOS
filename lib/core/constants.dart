class AppConstants {
  AppConstants._();

  // === TƏTBİQ MƏLUMATLARI ===
  static const String appName = 'AZMİU';
  static const String universityName =
      'Azərbaycan Memarlıq və İnşaat Universiteti';

  // === ASSET-LƏR ===
  static const String logoAsset = 'assets/images/azmiu_logo.png';
  static const String buildingAsset = 'assets/images/azmiu_building.jpg';
  static const String avatarAsset = 'assets/images/default_avatar.png';

  // === STORAGE AÇARLARI ===
  static const String studentKey = 'student_data';
  static const String cookieCfClearanceKey = 'cf_clearance';
  static const String cookiePhpSessionKey = 'PHPSESSID';
  static const String cookieSavedAtKey = 'cookie_saved_at';

  // === SAYT URL-LƏRİ ===
  static const String baseUrl = 'https://kabinet.azmiu.edu.az';
  static const String loginUrl = '$baseUrl/istifadechi/giris';
  static const String logoutUrl = '$baseUrl/istifadechi/loqout';
  static const String dashboardUrl = '$baseUrl/telebe/index';
  static const String profileUrl = '$baseUrl/istifadechi/profil';
  static const String scheduleUrl = '$baseUrl/timetable/showGroup';
  static const String curriculumUrl = '$baseUrl/telebe/tedris_plani';
  static const String journalUrl = '$baseUrl/telebe/jurnal';
  static const String materialsUrl = '$baseUrl/telebe/elektron_materiallar';
  static const String examQuestionsUrl = '$baseUrl/telebe/imtahan_suallar';
  static const String onlineLessonsUrl = '$baseUrl/telebe/lms';
  static const String examScheduleUrl = '$baseUrl/telebe/examNewTeamTable';
  static const String monthlyGradesUrl = '$baseUrl/telebe/bal';
  static const String finalGradesUrl = '$baseUrl/telebe/yekun_bal';
  static const String appealUrl = '$baseUrl/appeal/view';
  static const String lmsUrl = '$baseUrl/lmsLogin/l';
  static const String videoLessonsUrl = '$baseUrl/telebe/lms_video';
  static const String pollUrl = '$baseUrl/poll/form';

  // === COOKIE MÜDDƏTİ ===
  static const Duration cookieMaxAge = Duration(days: 1460); // 4 il (365 * 4)

  // === UI SABİTLƏRİ ===
  static const double horizontalPadding = 20;
  static const double cardRadius = 24;
  static const double smallRadius = 12;

  // === USER AGENT ===
  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 14; SM-A556B) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/120.0.0.0 Mobile Safari/537.36';
}