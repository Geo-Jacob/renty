import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:renty/main.dart' as app;

extension FinderIsNotEmpty on Finder {
  bool get isNotEmpty => evaluate().isNotEmpty;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Renty App Integration Tests', () {
    testWidgets('Complete user flow - Sign up to creating listing', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test app launch
      expect(find.byType(MaterialApp), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to sign up if not already logged in
      if (find.text('Sign Up').isNotEmpty) {
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Fill sign up form
        await tester.enterText(find.byType(TextField).at(0), 'test@college.edu');
        await tester.enterText(find.byType(TextField).at(1), 'Test User');
        await tester.enterText(find.byType(TextField).at(2), 'password123');

        // Select role
        await tester.tap(find.text('Student'));
        await tester.pumpAndSettle();

        // Submit form
        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Should be on home page
      expect(find.text('Hi there! 👋'), findsOneWidget);

      // Test search functionality
      await tester.enterText(find.byType(TextField).first, 'laptop');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Test category selection
      await tester.tap(find.text('Electronics'));
      await tester.pumpAndSettle();

      // Test creating a listing
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should navigate to create listing page
      expect(find.text('Create Listing'), findsOneWidget);

      // Fill listing form
      await tester.enterText(find.byType(TextField).at(0), 'MacBook Pro 2021');
      await tester.enterText(find.byType(TextField).at(1), 'Excellent condition laptop for rent');
      await tester.enterText(find.byType(TextField).at(2), '50');
      await tester.enterText(find.byType(TextField).at(3), '500');

      // Submit listing
      await tester.tap(find.text('Publish Listing'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should return to home page with success message
      expect(find.text('Hi there! 👋'), findsOneWidget);
    });

    testWidgets('Booking flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Assume user is logged in and on home page
      if (find.byType(ListTile).isNotEmpty) {
        // Tap on first listing
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();

        // Should be on listing detail page
        expect(find.text('Book Now'), findsOneWidget);

        // Tap book now
        await tester.tap(find.text('Book Now'));
        await tester.pumpAndSettle();

        // Should show booking dialog or page
        expect(find.text('Select Dates'), findsOneWidget);

        // Select dates and confirm
        await tester.tap(find.text('Confirm Booking'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show booking confirmation
        expect(find.text('Booking Requested'), findsOneWidget);
      }
    });
  });
}
