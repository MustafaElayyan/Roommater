import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roommater/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('home screen shows new 5-tab navigation labels', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
  });

  testWidgets('home app bar has Roommater title and notification icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Roommater'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });
}
