class LessonModel {
  final String time;
  final String subject;
  final String teacher;
  final String type; // Mühazirə, Laboratoriya, Məşğələ

  LessonModel({
    required this.time,
    required this.subject,
    required this.teacher,
    required this.type,
  });
}

class DayScheduleModel {
  final String dayName;
  final List<LessonModel> lessons;

  DayScheduleModel({
    required this.dayName,
    required this.lessons,
  });
}

class ScheduleModel {
  final String title;
  final List<DayScheduleModel> days;

  ScheduleModel({
    required this.title,
    required this.days,
  });
}