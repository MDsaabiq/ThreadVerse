import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threadverse/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ThreadVerseApp());

    // Verify app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
