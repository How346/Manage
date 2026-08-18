import 'package:flutter_test/flutter_test.dart';
import 'package:offline_school_manager/main.dart';

void main() {
  testWidgets('School Manager app builds', (tester) async {
    await tester.pumpWidget(const SchoolManagerApp());
    expect(find.text('My School'), findsOneWidget);
  });
}
