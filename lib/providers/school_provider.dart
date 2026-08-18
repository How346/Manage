import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../database/database_helper.dart';
import '../models/dashboard_stats.dart';
import '../models/fee_record.dart';
import '../models/salary_record.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../services/image_service.dart';
import '../services/whatsapp_service.dart';

class SchoolProvider extends ChangeNotifier {
  final DatabaseHelper database;
  final ImageService imageService;
  final WhatsAppService whatsappService;

  SchoolProvider({
    required this.database,
    required this.imageService,
    required this.whatsappService,
  });

  bool loading = true;
  String schoolName = 'My School';
  String studentQuery = '';
  String classFilter = 'All';
  String teacherQuery = '';

  DashboardStats stats = const DashboardStats(
    students: 0,
    teachers: 0,
    pendingFees: 0,
    collectedThisMonth: 0,
    salariesThisMonth: 0,
    birthdaysToday: 0,
  );

  List<Student> students = [];
  List<Teacher> teachers = [];
  List<Student> birthdays = [];
  List<Map<String, Object?>> defaulters = [];

  String get monthYear => DateFormat('MMMM yyyy').format(DateTime.now());
  String get monthDay => DateFormat('MM-dd').format(DateTime.now());

  void setSchoolName(String value) {
    schoolName = value.trim().isEmpty ? 'My School' : value.trim();
    notifyListeners();
  }

  Future<void> initialize() async {
    await refreshAll();
    loading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    stats = await database.getDashboardStats(monthYear, monthDay);
    students = await database.getStudents(
      query: studentQuery,
      classFilter: classFilter,
    );
    teachers = await database.getTeachers(query: teacherQuery);
    birthdays = await database.getTodaysBirthdays(monthDay);
    defaulters = await database.getDefaulters();
    notifyListeners();
  }

  Future<void> setStudentFilter({String? query, String? className}) async {
    if (query != null) studentQuery = query;
    if (className != null) classFilter = className;
    students = await database.getStudents(
      query: studentQuery,
      classFilter: classFilter,
    );
    notifyListeners();
  }

  Future<void> setTeacherQuery(String value) async {
    teacherQuery = value;
    teachers = await database.getTeachers(query: value);
    notifyListeners();
  }

  Future<int> saveStudent(Student student) async {
    final id = student.id == null
        ? await database.insertStudent(student)
        : await database.updateStudent(student);
    await refreshAll();
    return id;
  }

  Future<void> deleteStudent(Student student) async {
    await database.deleteStudent(student.id!);
    await imageService.deleteIfExists(student.photoPath);
    await refreshAll();
  }

  Future<String?> pickPhoto(ImageSource source) =>
      imageService.pickAndPersist(source: source);

  Future<int> saveTeacher(Teacher teacher) async {
    final id = teacher.id == null
        ? await database.insertTeacher(teacher)
        : await database.updateTeacher(teacher);
    await refreshAll();
    return id;
  }

  Future<void> deleteTeacher(Teacher teacher) async {
    await database.deleteTeacher(teacher.id!);
    await imageService.deleteIfExists(teacher.photoPath);
    await refreshAll();
  }

  Future<void> saveFee({
    required int studentId,
    required String month,
    required double total,
    required double paid,
  }) async {
    final safePaid = paid.clamp(0, total).toDouble();
    final due = (total - safePaid).clamp(0, double.infinity).toDouble();
    final status = FeeRecord.calculateStatus(total, safePaid);
    await database.upsertFee(
      FeeRecord(
        studentId: studentId,
        monthYear: month,
        totalAmount: total,
        paidAmount: safePaid,
        dueAmount: due,
        status: status,
        paymentDate: safePaid > 0
            ? DateFormat('yyyy-MM-dd').format(DateTime.now())
            : null,
      ),
    );
    await refreshAll();
  }

  Future<void> markSalaryPaid({
    required Teacher teacher,
    required String month,
  }) async {
    await database.upsertSalary(
      SalaryRecord(
        teacherId: teacher.id!,
        monthYear: month,
        amountPaid: teacher.monthlySalary,
        paymentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        status: 'PAID',
      ),
    );
    await refreshAll();
  }

  String feeReminderMessage({
    required String studentName,
    required String month,
    required double due,
  }) =>
      "Respected Parent, this is a reminder regarding $studentName's pending fee for $month of ₹${due.toStringAsFixed(0)}. Kindly clear the dues at your earliest convenience. Regards, $schoolName.";

  Future<bool> sendFeeReminder(Map<String, Object?> row) async {
    final phone = row['whatsapp_number'] as String? ?? '';
    final studentName = row['student_name'] as String? ?? 'Student';
    final month = row['month_year'] as String? ?? monthYear;
    final due = (row['due_amount'] as num?)?.toDouble() ?? 0;
    return whatsappService.sendWhatsAppMessage(
      phone: phone,
      message: feeReminderMessage(
        studentName: studentName,
        month: month,
        due: due,
      ),
    );
  }

  Future<bool> sendBirthdayWish(Student student) async {
    final message =
        'Dear Parent, warm birthday wishes to ${student.name}! 🎉 We wish your child a joyful, healthy and wonderful year ahead. Regards, $schoolName.';
    return whatsappService.sendWhatsAppMessage(
      phone: student.whatsappNumber,
      message: message,
    );
  }
}
