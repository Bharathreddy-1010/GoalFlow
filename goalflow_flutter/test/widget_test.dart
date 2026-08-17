import 'package:flutter_test/flutter_test.dart';
import 'package:goalflow_flutter/main.dart';

void main() {
  testWidgets('GoalFlow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GoalFlowApp());
  });
}
