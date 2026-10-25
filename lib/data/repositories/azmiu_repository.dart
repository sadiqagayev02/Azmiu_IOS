import 'package:azmiu_app/data/models/grades_model.dart';
import 'package:azmiu_app/data/models/news_model.dart';
import 'package:azmiu_app/data/models/schedule_model.dart';
import 'package:azmiu_app/data/models/student_model.dart';
import 'package:azmiu_app/data/parsers/dashboard_parser.dart';
import 'package:azmiu_app/data/parsers/grades_parser.dart';
import 'package:azmiu_app/data/parsers/schedule_parser.dart';
import 'package:azmiu_app/data/services/api_client.dart';

class AzmiuRepository {
  final ApiClient _api = ApiClient();

  Future<void> init() async {
    await _api.loadCookiesFromStorage();
  }

  // === 1. ANA SƏHİFƏ ===
  Future<Map<String, dynamic>> fetchDashboard() async {
    final html = await _api.fetchHtml('/telebe/index');
    final student = DashboardParser.parseStudent(html);
    final news = DashboardParser.parseNews(html);
    return {'student': student, 'news': news};
  }

  // === 2. DƏRS CƏDVƏLİ ===
  Future<ScheduleModel> fetchSchedule() async {
    final html = await _api.fetchHtml('/timetable/showGroup');
    return ScheduleParser.parse(html);
  }

  // === 3. AYLIQ NƏTİCƏLƏR ===
  Future<GradesModel> fetchGrades() async {
    final html = await _api.fetchHtml('/telebe/bal');
    return GradesParser.parse(html);
  }

  // === 4. TƏDRİS PLANI ===
  Future<String> fetchCurriculumHtml() async {
    return await _api.fetchHtml('/telebe/tedris_plani');
  }

  // === 5. ELEKTRON JURNAL ===
  Future<String> fetchJournalHtml() async {
    return await _api.fetchHtml('/telebe/jurnal');
  }

  // === 6. İMTAHAN CƏDVƏLİ ===
  Future<String> fetchExamScheduleHtml() async {
    return await _api.fetchHtml('/telebe/examNewTeamTable');
  }

  // === 7. YEKUN BAL ===
  Future<String> fetchFinalGradesHtml() async {
    return await _api.fetchHtml('/telebe/yekun_bal');
  }

  // === 8. ONLAYN APELLYASİYA ===
  Future<String> fetchAppealHtml() async {
    return await _api.fetchHtml('/appeal/view');
  }

  Future<void> logout() async {
    await _api.logout();
  }
}