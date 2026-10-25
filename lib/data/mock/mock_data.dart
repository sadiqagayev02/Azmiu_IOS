import 'package:azmiu_app/data/models/news_model.dart';

class MockData {
  MockData._();

  static List<NewsModel> mockNews() {
    return [
      const NewsModel(
        title: 'Tələbələr üçün vacib elan',
        description: '2025/2026 tədris ili üzrə qeydiyyat prosesi haqqında məlumat.',
        date: '12.09.2025',
        link: '',
      ),
      const NewsModel(
        title: '"Yüksəliş" müsabiqəsi çərçivəsində keçirilən III Tələbə Mentorluq Proqramına (TMP) qeydiyyat',
        description: 'Qeydiyyat üçün linkə keçid edin.',
        date: '25.11.2025',
        link: 'https://forms.gle/ogmJaE64397sCfFcA',
      ),
    ];
  }
}