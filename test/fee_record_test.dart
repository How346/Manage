import 'package:flutter_test/flutter_test.dart';
import 'package:offline_school_manager/models/fee_record.dart';

void main() {
  test('fee status calculation is deterministic', () {
    expect(FeeRecord.calculateStatus(1000, 0), 'PENDING');
    expect(FeeRecord.calculateStatus(1000, 500), 'PARTIAL');
    expect(FeeRecord.calculateStatus(1000, 1000), 'PAID');
  });
}
