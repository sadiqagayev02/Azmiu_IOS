import 'package:flutter/foundation.dart' show debugPrint;
import 'package:html/parser.dart' as html_parser;
import 'package:azmiu_app/data/models/general_models.dart';

class GeneralParsers {
  // === ELEKTRON JURNAL ===
  static JournalModel parseJournal(String html) {
    final doc = html_parser.parse(html);
    String title = 'Elektron jurnal';
    final caption = doc.querySelector('.portlet .caption');
    if (caption != null) title = caption.text.trim();

    final entries = <JournalEntry>[];
    doc.querySelectorAll('table tr').forEach((row) {
      final cells = row.querySelectorAll('td');
      if (cells.length >= 4) {
        entries.add(JournalEntry(
          date: cells[0].text.trim(),
          subject: cells[1].text.trim(),
          topic: cells[2].text.trim(),
          grade: cells[3].text.trim(),
        ));
      }
    });
    return JournalModel(title: title, entries: entries);
  }

  // === İMTAHAN SUALLARI ===
  static ExamQuestionsModel parseExamQuestions(String html) {
    final doc = html_parser.parse(html);
    final questions = <ExamQuestion>[];
    doc.querySelectorAll('table tr').forEach((row) {
      final cells = row.querySelectorAll('td');
      if (cells.length >= 2) {
        final link = cells[1].querySelector('a')?.attributes['href'] ?? '';
        questions.add(ExamQuestion(
          subject: cells[0].text.trim(),
          topic: cells[1].text.trim(),
          link: link,
        ));
      }
    });
    return ExamQuestionsModel(questions: questions);
  }

  // === ONLAYN DƏRSLƏR ===
  static OnlineLessonsModel parseOnlineLessons(String html) {
    final doc = html_parser.parse(html);
    final lessons = <OnlineLesson>[];
    doc.querySelectorAll('table tr').forEach((row) {
      final cells = row.querySelectorAll('td');
      if (cells.length >= 2) {
        final link = cells[1].querySelector('a')?.attributes['href'] ?? '';
        lessons.add(OnlineLesson(
          subject: cells[0].text.trim(),
          link: link,
        ));
      }
    });
    return OnlineLessonsModel(lessons: lessons);
  }

  // === İMTAHAN CƏDVƏLİ ===
  static ExamScheduleModel parseExamSchedule(String html) {
    final doc = html_parser.parse(html);
    final exams = <ExamScheduleItem>[];
    doc.querySelectorAll('table tr').forEach((row) {
      final cells = row.querySelectorAll('td');
      if (cells.length >= 4) {
        exams.add(ExamScheduleItem(
          date: cells[0].text.trim(),
          time: cells[1].text.trim(),
          subject: cells[2].text.trim(),
          room: cells[3].text.trim(),
        ));
      }
    });
    return ExamScheduleModel(exams: exams);
  }

  // === YE KUN BAL ===
  static FinalGradesModel parseFinalGrades(String html) {
    final doc = html_parser.parse(html);
    final grades = <FinalGradeItem>[];
    doc.querySelectorAll('table tr').forEach((row) {
      final cells = row.querySelectorAll('td');
      if (cells.length >= 3) {
        grades.add(FinalGradeItem(
          subject: cells[0].text.trim(),
          credits: cells[1].text.trim(),
          grade: cells[2].text.trim(),
        ));
      }
    });
    return FinalGradesModel(grades: grades);
  }
}