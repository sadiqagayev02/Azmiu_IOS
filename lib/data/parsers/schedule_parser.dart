import 'package:flutter/foundation.dart' show debugPrint;
import 'package:html/parser.dart' as html_parser;
import 'package:azmiu_app/data/models/schedule_model.dart';

class ScheduleParser {
  static ScheduleModel parse(String html) {
    debugPrint('=== SCHEDULE PARSER BAŞLAYIR ===');
    final doc = html_parser.parse(html);

    // Başlıq (məs: "Cədvəl 2026/2027 Payız")
    String title = 'Dərs cədvəli';
    final portlet = doc.querySelector('.portlet');
    if (portlet != null) {
      final caption = portlet.querySelector('.caption, .portlet-title');
      if (caption != null && caption.text.trim().isNotEmpty) {
        title = caption.text.trim();
      }
    }

    // Cədvəli tap
    final table = doc.querySelector('table.table.bordered') ??
        doc.querySelector('table');
    if (table == null) {
      debugPrint('=== CƏDVƏL TAPILMADI ===');
      return ScheduleModel(title: title, days: []);
    }

    final List<DayScheduleModel> days = [];
    String? currentDayName;
    List<LessonModel> currentLessons = [];

    // Sətirləri gəzirik
    for (final row in table.querySelectorAll('tr')) {
      final cells = row.querySelectorAll('td, th');
      if (cells.isEmpty) continue;

      // Bəzən gün adı birinci xanada, bəzən rowspan ilə gəlir
      // Gəlin hər sətri yoxlayaq
      String rowText = cells.map((c) => c.text.trim()).join(' | ');
      
      // Gün adını yoxla (I gün, II gün, III gün, IV gün, V gün, VI gün)
      final dayRegex = RegExp(r'^(I|II|III|IV|V|VI)\s+gün');
      bool isDayRow = false;
      String? dayName;

      // Əgər 3 xana varsa: [Gün adı] [Vaxt] [Dərs]
      // Əgər 2 xana varsa: [Vaxt] [Dərs] — gün adı əvvəlki sətirdən gəlir
      
      if (cells.length >= 3) {
        final firstCell = cells[0].text.trim();
        if (dayRegex.hasMatch(firstCell)) {
          isDayRow = true;
          dayName = firstCell;
        }
      }

      // Əvvəlki günü yadda saxla
      if (isDayRow) {
        // Əvvəlki günü yadda saxla
        if (currentDayName != null && currentLessons.isNotEmpty) {
          days.add(DayScheduleModel(
            dayName: currentDayName,
            lessons: List.from(currentLessons),
          ));
        }
        currentDayName = dayName;
        currentLessons = [];
        
        // Bu sətirdə də dərs ola bilər (3-cü xana)
        if (cells.length >= 3) {
          final time = cells[1].text.trim();
          final lessonText = cells[2].text.trim();
          if (time.isNotEmpty && lessonText.isNotEmpty && !lessonText.contains('---')) {
            final lesson = _parseLesson(time, lessonText);
            if (lesson != null) currentLessons.add(lesson);
          }
        }
      } else {
        // Adi dərs sətri: [Vaxt] [Dərs]
        if (cells.length >= 2) {
          final time = cells[0].text.trim();
          final lessonText = cells[1].text.trim();
          
          // Vaxt formatını yoxla (09:00 - 10:20)
          final timeRegex = RegExp(r'\d{2}:\d{2}\s*-\s*\d{2}:\d{2}');
          if (timeRegex.hasMatch(time) && lessonText.isNotEmpty && !lessonText.contains('---')) {
            final lesson = _parseLesson(time, lessonText);
            if (lesson != null && currentDayName != null) {
              currentLessons.add(lesson);
            }
          }
        }
      }
    }

    // Son günü əlavə et
    if (currentDayName != null && currentLessons.isNotEmpty) {
      days.add(DayScheduleModel(
        dayName: currentDayName,
        lessons: List.from(currentLessons),
      ));
    }

    debugPrint('=== PARSER NƏTİCƏ: ${days.length} gün tapıldı ===');
    for (var d in days) {
      debugPrint('  ${d.dayName}: ${d.lessons.length} dərs');
    }

    return ScheduleModel(title: title, days: days);
  }

  static LessonModel? _parseLesson(String time, String text) {
    // Məsələn: "Fizika - Mühazirə (416a2)Fizika - Mühazirə"
    // və ya: "Tərsimi həndəsə və mühəndis qrafikası - Məşğələ"
    
    // Müəllim adını tapmaq çətindir, çünki HTML-də ayrıca yoxdur
    // Amma dərsin adını və tipini ayıra bilərik
    
    String subject = text;
    String type = '';
    
    // " - " ilə ayır
    if (text.contains(' - ')) {
      final parts = text.split(' - ');
      if (parts.length >= 2) {
        subject = parts[0].trim();
        final rest = parts[1].trim();
        // Tipi tap (Mühazirə, Laboratoriya, Məşğələ, Seminar)
        if (rest.startsWith('Mühazirə')) {
          type = 'Mühazirə';
        } else if (rest.startsWith('Laboratoriya')) {
          type = 'Laboratoriya';
        } else if (rest.startsWith('Məşğələ')) {
          type = 'Məşğələ';
        } else if (rest.startsWith('Seminar')) {
          type = 'Seminar';
        }
      }
    }
    
    // Təkrar mətni təmizlə (bəzən "Fizika - Mühazirə (416a2)Fizika - Mühazirə" olur)
    subject = subject.split(RegExp(r'[A-ZƏÖÜİÇŞĞ]')).first.trim();
    if (subject.isEmpty) {
      // Əgər boş qalıbsa, orijinal mətni istifadə et
      subject = text.split('(').first.trim();
    }

    return LessonModel(
      time: time,
      subject: subject.isEmpty ? text.split('(').first.trim() : subject,
      teacher: '',
      type: type,
    );
  }
}