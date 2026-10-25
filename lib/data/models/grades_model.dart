class GradeMonthModel {
  final String monthName; // Oktyabr, Noyabr, Dekabr
  final String freeWorkCount; // Sərbəst iş sayı
  final String seminar; // Seminar (Məşğələ)
  final String lab; // Laboratoriya
  final String courseWork; // Kurs işi

  GradeMonthModel({
    required this.monthName,
    this.freeWorkCount = '',
    this.seminar = '',
    this.lab = '',
    this.courseWork = '',
  });
}

class SubjectGradeModel {
  final String subjectName;
  final List<GradeMonthModel> months;

  SubjectGradeModel({
    required this.subjectName,
    required this.months,
  });
}

class GradesModel {
  final String title; // İQB 2026/2027 tədris ili Payız smester
  final List<SubjectGradeModel> subjects;

  GradesModel({
    required this.title,
    required this.subjects,
  });
}