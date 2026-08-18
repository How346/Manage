class Teacher {
  final int? id;
  final String name;
  final String subjectOrRole;
  final double monthlySalary;
  final String joiningDate;
  final String whatsappNumber;
  final String? photoPath;

  const Teacher({
    this.id,
    required this.name,
    required this.subjectOrRole,
    required this.monthlySalary,
    required this.joiningDate,
    required this.whatsappNumber,
    this.photoPath,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'subject_or_role': subjectOrRole,
        'monthly_salary': monthlySalary,
        'joining_date': joiningDate,
        'whatsapp_number': whatsappNumber,
        'photo_path': photoPath,
      };

  factory Teacher.fromMap(Map<String, Object?> map) => Teacher(
        id: map['id'] as int?,
        name: map['name'] as String,
        subjectOrRole: (map['subject_or_role'] as String?) ?? '',
        monthlySalary: (map['monthly_salary'] as num).toDouble(),
        joiningDate: map['joining_date'] as String,
        whatsappNumber: (map['whatsapp_number'] as String?) ?? '',
        photoPath: map['photo_path'] as String?,
      );
}
