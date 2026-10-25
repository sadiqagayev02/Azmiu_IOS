class CurriculumSubject {
  final String number;
  final String name;
  final String totalHours;
  final String credits;
  final String department;
  final String teacher;

  CurriculumSubject({
    required this.number,
    required this.name,
    required this.totalHours,
    required this.credits,
    required this.department,
    required this.teacher,
  });
}

class CurriculumModel {
  final String faculty;
  final String specialty;
  final String group;
  final String academicYear;
  final String semester;
  final List<CurriculumSubject> subjects;

  CurriculumModel({
    required this.faculty,
    required this.specialty,
    required this.group,
    required this.academicYear,
    required this.semester,
    required this.subjects,
  });
}