// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:momo_hackathon/app/routes/app_pages.dart';

void main() {
  testWidgets('Home page displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      GetMaterialApp(
        title: "Application",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the Home page elements are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Total Scan'), findsOneWidget);
    expect(find.text('Amount Saved'), findsOneWidget);
    expect(find.text('Articles'), findsOneWidget);

    // Verify navigation bar is present
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify floating action button is present
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
  });

  testWidgets('Navigation between pages works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      GetMaterialApp(
        title: "Application",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Tap on History tab
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // Verify we're on History page
    expect(find.text('History'), findsWidgets);

    // Tap on Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify we're on Settings page
    expect(find.text('Settings'), findsWidgets);
  });
}
