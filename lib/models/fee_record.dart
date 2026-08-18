class FeeRecord {
  final int? id;
  final int studentId;
  final String monthYear;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final String? paymentDate;

  const FeeRecord({
    this.id,
    required this.studentId,
    required this.monthYear,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    this.paymentDate,
  });

  static String calculateStatus(double total, double paid) {
    if (paid <= 0) return 'PENDING';
    if (paid >= total) return 'PAID';
    return 'PARTIAL';
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'student_id': studentId,
        'month_year': monthYear,
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'due_amount': dueAmount,
        'status': status,
        'payment_date': paymentDate,
      };

  factory FeeRecord.fromMap(Map<String, Object?> map) => FeeRecord(
        id: map['id'] as int?,
        studentId: map['student_id'] as int,
        monthYear: map['month_year'] as String,
        totalAmount: (map['total_amount'] as num).toDouble(),
        paidAmount: (map['paid_amount'] as num).toDouble(),
        dueAmount: (map['due_amount'] as num).toDouble(),
        status: map['status'] as String,
        paymentDate: map['payment_date'] as String?,
      );
}
