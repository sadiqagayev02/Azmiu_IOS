import 'package:flutter/foundation.dart' show debugPrint;
import 'package:html/parser.dart' as html_parser;

import 'package:azmiu_app/data/models/news_model.dart';
import 'package:azmiu_app/data/models/student_model.dart';

class DashboardParser {
  static StudentModel parseStudent(String html) {
    debugPrint('=== PARSER: parseStudent BAŞLAYIR ===');
    final doc = html_parser.parse(html);

    final portlet = doc.querySelector('.portlet.box.blue');
    if (portlet == null) {
      debugPrint('=== PARSER: .portlet.box.blue TAPILMADI ===');
      throw Exception('Tələbə məlumatları tapılmadı');
    }

    final rows = portlet.querySelectorAll('table tr');
    debugPrint('=== PARSER: CƏDVƏL SƏTİR SAYI: ${rows.length} ===');

    String fullName = '';
    String faculty = '';
    String specialty = '';
    String group = '';

    for (final row in rows) {
      final cells = row.querySelectorAll('td');
      if (cells.length < 2) continue;
      final key = cells[0].text.trim();
      final value = cells[1].text.trim();

      debugPrint('  KEY: "$key" | VALUE: "$value"');

      switch (key) {
        case 'S.A.A':
          fullName = value;
          break;
        case 'Fakultə':
          faculty = value;
          break;
        case 'İxtisas':
          specialty = value;
          break;
        case 'Qrup':
          group = value;
          break;
      }
    }

    debugPrint('=== PARSER NƏTİCƏ ===');
    debugPrint('  fullName: $fullName');
    debugPrint('  faculty: $faculty');
    debugPrint('  specialty: $specialty');
    debugPrint('  group: $group');

    return StudentModel(
      fullName: fullName.isEmpty ? 'Tələbə' : fullName,
      faculty: faculty,
      studentId: '',
      group: group,
      specialty: specialty,
      educationLevel: '',
      academicYear: '',
      avatarUrl: null,
    );
  }

  static List<NewsModel> parseNews(String html) {
    debugPrint('=== PARSER: parseNews BAŞLAYIR ===');
    final doc = html_parser.parse(html);
    final tab = doc.getElementById('tab_1_2');
    if (tab == null) return [];

    final newsList = <NewsModel>[];
    final items = tab.querySelectorAll('ul.feeds li');

    for (final li in items) {
      final style = li.attributes['style'] ?? '';
      if (style.contains('display:none')) continue;

      final link = li.querySelector('a');
      if (link == null) continue;

      final href = link.attributes['href'] ?? '';
      final descEl = li.querySelector('.desc');
      final dateEl = li.querySelector('.date b');

      if (descEl == null) continue;

      final title = descEl.text
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll('ELAN:', '')
          .trim();

      if (title.isEmpty) continue;

      newsList.add(NewsModel(
        title: title,
        description: '',
        date: dateEl?.text.trim() ?? '',
        link: href,
        imageUrl: null,
      ));
    }

    return newsList;
  }
}