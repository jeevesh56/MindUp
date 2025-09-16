// Basic smoke test for the StressApp root widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stress_app/app.dart';

void main() {
  testWidgets('App loads and shows Chatbot tab title', (WidgetTester tester) async {
    await tester.pumpWidget(const StressApp());

    // Verify initial app bar title is Chatbot
    expect(find.text('Chatbot'), findsOneWidget);

    // Tap the Mood tab and verify title updates
    await tester.tap(find.byIcon(Icons.mood_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Mood'), findsOneWidget);
  });
}
