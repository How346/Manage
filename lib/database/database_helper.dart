import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/dashboard_stats.dart';
import '../models/fee_record.dart';
import '../models/salary_record.dart';
import '../models/student.dart';
import '../models/teacher.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'offline_school_manager.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.execute('PRAGMA journal_mode = WAL');
      },
      onCreate: (db, version) async {
        await db.transaction((txn) async {
          await txn.execute('''
            CREATE TABLE students(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              admission_no TEXT NOT NULL UNIQUE,
              name TEXT NOT NULL,
              father_name TEXT NOT NULL DEFAULT '',
              mother_name TEXT NOT NULL DEFAULT '',
              standard_class TEXT NOT NULL,
              section TEXT NOT NULL DEFAULT '',
              dob TEXT NOT NULL DEFAULT '',
              whatsapp_number TEXT NOT NULL DEFAULT '',
              photo_path TEXT,
              admission_date TEXT NOT NULL
            )
          ''');
          await txn.execute('''
            CREATE TABLE teachers(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              subject_or_role TEXT NOT NULL DEFAULT '',
              monthly_salary REAL NOT NULL DEFAULT 0,
              joining_date TEXT NOT NULL,
              whatsapp_number TEXT NOT NULL DEFAULT '',
              photo_path TEXT
            )
          ''');
          await txn.execute('''
            CREATE TABLE fee_records(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              student_id INTEGER NOT NULL,
              month_year TEXT NOT NULL,
              total_amount REAL NOT NULL DEFAULT 0,
              paid_amount REAL NOT NULL DEFAULT 0,
              due_amount REAL NOT NULL DEFAULT 0,
              status TEXT NOT NULL,
              payment_date TEXT,
              UNIQUE(student_id, month_year),
              FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
            )
          ''');
          await txn.execute('''
            CREATE TABLE salary_records(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              teacher_id INTEGER NOT NULL,
              month_year TEXT NOT NULL,
              amount_paid REAL NOT NULL DEFAULT 0,
              payment_date TEXT,
              status TEXT NOT NULL,
              UNIQUE(teacher_id, month_year),
              FOREIGN KEY(teacher_id) REFERENCES teachers(id) ON DELETE CASCADE
            )
          ''');
          await txn.execute('CREATE INDEX idx_students_name ON students(name COLLATE NOCASE)');
          await txn.execute('CREATE INDEX idx_students_class ON students(standard_class)');
          await txn.execute('CREATE INDEX idx_students_dob ON students(dob)');
          await txn.execute('CREATE INDEX idx_fee_status ON fee_records(status)');
          await txn.execute('CREATE INDEX idx_fee_student_month ON fee_records(student_id, month_year)');
          await txn.execute('CREATE INDEX idx_salary_teacher_month ON salary_records(teacher_id, month_year)');
        });
      },
    );
  }

  Future<int> insertStudent(Student student) async =>
      (await database).insert('students', student.toMap()..remove('id'));

  Future<int> updateStudent(Student student) async {
    if (student.id == null) throw ArgumentError('Student id is required.');
    return (await database).update(
      'students',
      student.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async =>
      (await database).delete('students', where: 'id = ?', whereArgs: [id]);

  Future<Student?> getStudent(int id) async {
    final rows = await (await database).query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Student.fromMap(rows.first);
  }

  Future<List<Student>> getStudents({String query = '', String classFilter = 'All'}) async {
    final db = await database;
    final clauses = <String>[];
    final args = <Object?>[];
    if (query.trim().isNotEmpty) {
      clauses.add('(name LIKE ? OR admission_no LIKE ? OR father_name LIKE ?)');
      final q = '%${query.trim()}%';
      args.addAll([q, q, q]);
    }
    if (classFilter != 'All') {
      clauses.add('standard_class = ?');
      args.add(classFilter);
    }
    final rows = await db.query(
      'students',
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<List<Student>> getTodaysBirthdays(String monthDay) async {
    final rows = await (await database).query(
      'students',
      where: "substr(dob, 6, 5) = ?",
      whereArgs: [monthDay],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<int> insertTeacher(Teacher teacher) async =>
      (await database).insert('teachers', teacher.toMap()..remove('id'));

  Future<int> updateTeacher(Teacher teacher) async {
    if (teacher.id == null) throw ArgumentError('Teacher id is required.');
    return (await database).update(
      'teachers',
      teacher.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<int> deleteTeacher(int id) async =>
      (await database).delete('teachers', where: 'id = ?', whereArgs: [id]);

  Future<List<Teacher>> getTeachers({String query = ''}) async {
    final rows = await (await database).query(
      'teachers',
      where: query.trim().isEmpty
          ? null
          : '(name LIKE ? OR subject_or_role LIKE ?)',
      whereArgs: query.trim().isEmpty
          ? null
          : ['%${query.trim()}%', '%${query.trim()}%'],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Teacher.fromMap).toList();
  }

  Future<int> upsertFee(FeeRecord record) async {
    final db = await database;
    return db.insert(
      'fee_records',
      record.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FeeRecord>> getFeesForStudent(int studentId) async {
    final rows = await (await database).query(
      'fee_records',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'id DESC',
    );
    return rows.map(FeeRecord.fromMap).toList();
  }

  Future<List<Map<String, Object?>>> getDefaulters() async {
    final rows = await (await database).rawQuery('''
      SELECT f.*, s.name AS student_name, s.admission_no, s.whatsapp_number,
             s.photo_path, s.standard_class, s.section
      FROM fee_records f
      INNER JOIN students s ON s.id = f.student_id
      WHERE f.status != 'PAID' AND f.due_amount > 0
      ORDER BY f.due_amount DESC, s.name COLLATE NOCASE ASC
    ''');
    return rows;
  }

  Future<int> upsertSalary(SalaryRecord record) async {
    final db = await database;
    return db.insert(
      'salary_records',
      record.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SalaryRecord>> getSalariesForTeacher(int teacherId) async {
    final rows = await (await database).query(
      'salary_records',
      where: 'teacher_id = ?',
      whereArgs: [teacherId],
      orderBy: 'id DESC',
    );
    return rows.map(SalaryRecord.fromMap).toList();
  }

  Future<DashboardStats> getDashboardStats(String monthYear, String monthDay) async {
    final db = await database;
    final students = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM students'),
        ) ??
        0;
    final teachers = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM teachers'),
        ) ??
        0;
    final pendingRow = await db.rawQuery(
      'SELECT COALESCE(SUM(due_amount), 0) AS total FROM fee_records WHERE due_amount > 0',
    );
    final collectedRow = await db.rawQuery(
      'SELECT COALESCE(SUM(paid_amount), 0) AS total FROM fee_records WHERE month_year = ?',
      [monthYear],
    );
    final salaryRow = await db.rawQuery(
      'SELECT COALESCE(SUM(amount_paid), 0) AS total FROM salary_records WHERE month_year = ?',
      [monthYear],
    );
    final birthdayCount = Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM students WHERE substr(dob, 6, 5) = ?",
            [monthDay],
          ),
        ) ??
        0;

    return DashboardStats(
      students: students,
      teachers: teachers,
      pendingFees: (pendingRow.first['total'] as num).toDouble(),
      collectedThisMonth: (collectedRow.first['total'] as num).toDouble(),
      salariesThisMonth: (salaryRow.first['total'] as num).toDouble(),
      birthdaysToday: birthdayCount,
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
