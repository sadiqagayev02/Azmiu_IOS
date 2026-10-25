import 'package:flutter/foundation.dart' show debugPrint;
import 'package:html/parser.dart' as html_parser;
import 'package:azmiu_app/data/models/curriculum_model.dart';

class CurriculumParser {
  static CurriculumModel parse(String html) {
    debugPrint('=== CURRICULUM PARSER BAŞLAYIR ===');
    final doc = html_parser.parse(html);

    // Başlıq məlumatları üçün ilk cədvəli tap
    String faculty = '';
    String specialty = '';
    String group = '';
    String academicYear = '';
    String semester = '';

    final tables = doc.querySelectorAll('table');
    if (tables.isNotEmpty) {
      final infoTable = tables[0];
      final rows = infoTable.querySelectorAll('tr');
      
      for (final row in rows) {
        final cells = row.querySelectorAll('td');
        if (cells.length >= 4) {
          final key1 = cells[0].text.trim();
          final val1 = cells[1].text.trim();
          final key2 = cells[2].text.trim();
          final val2 = cells[3].text.trim();
          
          if (key1 == 'Fakultə') faculty = val1;
          if (key2 == 'İxtisas') specialty = val2;
          if (key1 == 'Qrup') group = val1;
          if (key2 == 'Tədris ili') academicYear = val2;
        }
        // Semestr adı (I semestr (Payız))
        if (row.text.contains('semestr')) {
          semester = row.text.trim();
        }
      }
    }

    // Fənlərin siyahısı üçün ikinci cədvəli tap
    final List<CurriculumSubject> subjects = [];
    
    if (tables.length > 1) {
      final subjectsTable = tables[1];
      final rows = subjectsTable.querySelectorAll('tr');
      
      for (int i = 2; i < rows.length; i++) { // İlk 2 sətir başlıqdır
        final cells = rows[i].querySelectorAll('td');
        if (cells.length >= 6) {
          final number = cells[0].text.trim();
          final name = cells[1].text.trim();
          
          // Əgər fənn adı boşdursa və ya "-------" dirsə, keç
          if (name.isEmpty || name.contains('---')) continue;
          
          final totalHours = cells[4].text.trim();
          final credits = cells[5].text.trim();
          final department = cells[6].text.trim();
          final teacher = cells.length > 7 ? cells[7].text.trim() : '';

          subjects.add(CurriculumSubject(
            number: number,
            name: name,
            totalHours: totalHours,
            credits: credits,
            department: department,
            teacher: teacher,
          ));
        }
      }
    }

    debugPrint('=== PARSER NƏTİCƏ: ${subjects.length} fənn tapıldı ===');

    return CurriculumModel(
      faculty: faculty,
      specialty: specialty,
      group: group,
      academicYear: academicYear,
      semester: semester,
      subjects: subjects,
    );
  }
}