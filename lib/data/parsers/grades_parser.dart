import 'package:flutter/foundation.dart' show debugPrint;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:azmiu_app/data/models/grades_model.dart';

class GradesParser {
  static GradesModel parse(String html) {
    debugPrint('=== GRADES PARSER BAŞLAYIR ===');
    final doc = html_parser.parse(html);

    // Başlıq
    String title = 'Qiymətlər';
    final portlet = doc.querySelector('.portlet');
    if (portlet != null) {
      final caption = portlet.querySelector('.caption, .portlet-title');
      if (caption != null && caption.text.trim().isNotEmpty) {
        title = caption.text.trim();
      }
    }

    final List<SubjectGradeModel> subjects = [];

    // Hər h4-ü gəzirik
    final h4s = doc.querySelectorAll('h4');
    debugPrint('=== H4 SAYI: ${h4s.length} ===');

    for (final h4 in h4s) {
      final subjectName = h4.text.trim();
      if (subjectName.isEmpty) continue;

      // H4-dən sonra gələn cədvəli tap
      dom.Element? nextElement = h4.nextElementSibling;
      dom.Element? tableElement;
      
      while (nextElement != null) {
        if (nextElement.localName == 'table') {
          tableElement = nextElement;
          break;
        }
        final innerTable = nextElement.querySelector('table');
        if (innerTable != null) {
          tableElement = innerTable;
          break;
        }
        nextElement = nextElement.nextElementSibling;
      }

      if (tableElement == null) {
        debugPrint('  $subjectName: CƏDVƏL TAPILMADI');
        continue;
      }

      final months = _parseTable(tableElement);
      
      if (months.isNotEmpty) {
        subjects.add(SubjectGradeModel(
          subjectName: subjectName,
          months: months,
        ));
        debugPrint('  $subjectName: ${months.length} ay');
      }
    }

    debugPrint('=== PARSER NƏTİCƏ: ${subjects.length} fənn tapıldı ===');

    return GradesModel(title: title, subjects: subjects);
  }

  static List<GradeMonthModel> _parseTable(dom.Element table) {
    final rows = table.querySelectorAll('tr');
    if (rows.isEmpty) return [];

    // Başlıq sətrində ayları tap (Oktyabr, Noyabr, Dekabr)
    List<String> monthNames = [];
    final headerCells = rows[0].querySelectorAll('th, td');
    
    for (final cell in headerCells) {
      final text = cell.text.trim();
      if (text == 'Oktyabr' || text == 'Noyabr' || text == 'Dekabr' ||
          text == 'Yanvar' || text == 'Fevral' || text == 'Mart' ||
          text == 'Aprel' || text == 'May' || text == 'İyun') {
        monthNames.add(text);
      }
    }

    debugPrint('=== AYLAR: ${monthNames.join(", ")} ===');

    if (monthNames.isEmpty) return [];

    // Hər ay üçün məlumatları toplayaq
    final Map<String, Map<String, String>> monthData = {};
    for (var m in monthNames) {
      monthData[m] = {};
    }

    // Sətirləri gəzirik (başlıqdan sonra)
    for (int r = 1; r < rows.length; r++) {
      final cells = rows[r].querySelectorAll('td, th');
      if (cells.length < 2) continue;

      final rowLabel = cells[0].text.trim();
      
      // Hər ay üçün qiyməti götür
      int monthIndex = 0;
      for (int c = 1; c < cells.length; c++) {
        // Bəzən boş sütunlar olur (ikinci sütun)
        final cellText = cells[c].text.trim();
        
        // Əgər bu sütun bir aya uyğundursa
        if (monthIndex < monthNames.length) {
          final month = monthNames[monthIndex];
          
          if (rowLabel.contains('Sərbəst iş')) {
            monthData[month]!['freeWork'] = cellText;
          } else if (rowLabel.contains('Seminar')) {
            monthData[month]!['seminar'] = cellText;
          } else if (rowLabel.contains('Laboratoriya')) {
            monthData[month]!['lab'] = cellText;
          } else if (rowLabel.contains('Kurs işi')) {
            monthData[month]!['courseWork'] = cellText;
          }
          
          monthIndex++;
        }
      }
    }

    // Nəticəni qaytar
    final List<GradeMonthModel> result = [];
    for (var month in monthNames) {
      final data = monthData[month]!;
      result.add(GradeMonthModel(
        monthName: month,
        freeWorkCount: data['freeWork'] ?? '',
        seminar: data['seminar'] ?? '',
        lab: data['lab'] ?? '',
        courseWork: data['courseWork'] ?? '',
      ));
    }

    return result;
  }
}