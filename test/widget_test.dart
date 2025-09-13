import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:renty/main.dart';
import 'package:renty/features/listing/presentation/widgets/listing_card.dart';
import 'package:renty/features/listing/domain/entities/listing_entity.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('RentyApp smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: RentyApp()));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('ListingCard displays listing information correctly', 
        (WidgetTester tester) async {
      final listing = ListingEntity(
        id: '1',
        ownerId: 'owner1',
        title: 'Test Item',
        description: 'Test Description',
        category: 'Electronics',
        imageUrls: const [],
        condition: ItemCondition.good,
        hourlyPrice: 10.0,
        dailyPrice: 50.0,
        depositAmount: 100.0,
        location: 'Campus Library',
        tags: const ['electronics'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: ListingStatus.active,
        rating: 4.5,
        totalRatings: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListingCard(
              listing: listing,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Campus Library'), findsOneWidget);
      expect(find.text('₹50/day'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
    });
  });
}