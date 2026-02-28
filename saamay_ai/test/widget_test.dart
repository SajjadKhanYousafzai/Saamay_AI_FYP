import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saamay_ai/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Verify the app widget can be instantiated
    await tester.pumpWidget(const SaamayAIApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
