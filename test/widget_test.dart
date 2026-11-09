import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:untitled1/main.dart';

void main() {
  testWidgets('FreshFriendsApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: FreshFriendsApp(),
      ),
    );

    // Verify app starts up
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
