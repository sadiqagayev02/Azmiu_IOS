// === ELEKTRON JURNAL ===
class JournalEntry {
  final String date;
  final String subject;
  final String topic;
  final String grade;
  JournalEntry({required this.date, required this.subject, required this.topic, required this.grade});
}

class JournalModel {
  final String title;
  final List<JournalEntry> entries;
  JournalModel({required this.title, required this.entries});
}

// === İMTAHAN SUALLARI ===
class ExamQuestion {
  final String subject;
  final String topic;
  final String link;
  ExamQuestion({required this.subject, required this.topic, required this.link});
}

class ExamQuestionsModel {
  final List<ExamQuestion> questions;
  ExamQuestionsModel({required this.questions});
}

// === ONLAYN DƏRSLƏR ===
class OnlineLesson {
  final String subject;
  final String link;
  OnlineLesson({required this.subject, required this.link});
}

class OnlineLessonsModel {
  final List<OnlineLesson> lessons;
  OnlineLessonsModel({required this.lessons});
}

// === İMTAHAN CƏDVƏLİ ===
class ExamScheduleItem {
  final String date;
  final String time;
  final String subject;
  final String room;
  ExamScheduleItem({required this.date, required this.time, required this.subject, required this.room});
}

class ExamScheduleModel {
  final List<ExamScheduleItem> exams;
  ExamScheduleModel({required this.exams});
}

// === YE KUN BAL ===
class FinalGradeItem {
  final String subject;
  final String credits;
  final String grade;
  FinalGradeItem({required this.subject, required this.credits, required this.grade});
}

class FinalGradesModel {
  final List<FinalGradeItem> grades;
  FinalGradesModel({required this.grades});
}