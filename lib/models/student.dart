class Student {
  final int? id;
  final String admissionNo;
  final String name;
  final String fatherName;
  final String motherName;
  final String standardClass;
  final String section;
  final String dob;
  final String whatsappNumber;
  final String? photoPath;
  final String admissionDate;

  const Student({
    this.id,
    required this.admissionNo,
    required this.name,
    required this.fatherName,
    required this.motherName,
    required this.standardClass,
    required this.section,
    required this.dob,
    required this.whatsappNumber,
    this.photoPath,
    required this.admissionDate,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'admission_no': admissionNo,
        'name': name,
        'father_name': fatherName,
        'mother_name': motherName,
        'standard_class': standardClass,
        'section': section,
        'dob': dob,
        'whatsapp_number': whatsappNumber,
        'photo_path': photoPath,
        'admission_date': admissionDate,
      };

  factory Student.fromMap(Map<String, Object?> map) => Student(
        id: map['id'] as int?,
        admissionNo: map['admission_no'] as String,
        name: map['name'] as String,
        fatherName: (map['father_name'] as String?) ?? '',
        motherName: (map['mother_name'] as String?) ?? '',
        standardClass: map['standard_class'] as String,
        section: (map['section'] as String?) ?? '',
        dob: (map['dob'] as String?) ?? '',
        whatsappNumber: (map['whatsapp_number'] as String?) ?? '',
        photoPath: map['photo_path'] as String?,
        admissionDate: map['admission_date'] as String,
      );

  Student copyWith({
    int? id,
    String? admissionNo,
    String? name,
    String? fatherName,
    String? motherName,
    String? standardClass,
    String? section,
    String? dob,
    String? whatsappNumber,
    String? photoPath,
    String? admissionDate,
  }) =>
      Student(
        id: id ?? this.id,
        admissionNo: admissionNo ?? this.admissionNo,
        name: name ?? this.name,
        fatherName: fatherName ?? this.fatherName,
        motherName: motherName ?? this.motherName,
        standardClass: standardClass ?? this.standardClass,
        section: section ?? this.section,
        dob: dob ?? this.dob,
        whatsappNumber: whatsappNumber ?? this.whatsappNumber,
        photoPath: photoPath ?? this.photoPath,
        admissionDate: admissionDate ?? this.admissionDate,
      );
}
