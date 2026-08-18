class SalaryRecord {
  final int? id;
  final int teacherId;
  final String monthYear;
  final double amountPaid;
  final String? paymentDate;
  final String status;

  const SalaryRecord({
    this.id,
    required this.teacherId,
    required this.monthYear,
    required this.amountPaid,
    this.paymentDate,
    required this.status,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'teacher_id': teacherId,
        'month_year': monthYear,
        'amount_paid': amountPaid,
        'payment_date': paymentDate,
        'status': status,
      };

  factory SalaryRecord.fromMap(Map<String, Object?> map) => SalaryRecord(
        id: map['id'] as int?,
        teacherId: map['teacher_id'] as int,
        monthYear: map['month_year'] as String,
        amountPaid: (map['amount_paid'] as num).toDouble(),
        paymentDate: map['payment_date'] as String?,
        status: map['status'] as String,
      );
}
