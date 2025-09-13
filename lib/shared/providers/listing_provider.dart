import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/listing_entity.dart';

class ListingsNotifier extends StateNotifier<AsyncValue<List<ListingEntity>>> {
  final FirebaseFirestore _firestore;
  String? _currentQuery;
  String? _currentCategory;

  ListingsNotifier(this._firestore) : super(const AsyncValue.loading()) {
    loadListings();
  }

  Future<void> loadListings() async {
    try {
      state = const AsyncValue.loading();
      
      Query query = _firestore.collection('listings');
      
      // Apply filters
      query = query.where('status', isEqualTo: 'active');
      
      if (_currentCategory != null) {
        query = query.where('category', isEqualTo: _currentCategory);
      }
      
      // Apply search query
      if (_currentQuery != null && _currentQuery!.isNotEmpty) {
        // In a real app, you'd use a proper search solution like Algolia
        query = query
            .where('searchKeywords', arrayContainsAny: _generateSearchKeywords(_currentQuery!))
            .limit(20);
      } else {
        query = query.orderBy('createdAt', descending: true).limit(20);
      }

      final snapshot = await query.get();
      final listings = snapshot.docs
          .map((doc) => _mapDocToListing(doc))
          .toList();

      state = AsyncValue.data(listings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void searchListings(String query) {
    _currentQuery = query;
    loadListings();
  }

  void filterByCategory(String? category) {
    _currentCategory = category;
    loadListings();
  }

  List<String> _generateSearchKeywords(String query) {
    // Simple keyword generation - in production, use better search
    return query.toLowerCase().split(' ').where((word) => word.isNotEmpty).toList();
  }

  ListingEntity _mapDocToListing(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingEntity(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      condition: ItemCondition.values.firstWhere(
        (c) => c.toString().split('.').last == data['condition'],
        orElse: () => ItemCondition.good,
      ),
      hourlyPrice: (data['hourlyPrice'] ?? 0.0).toDouble(),
      dailyPrice: (data['dailyPrice'] ?? 0.0).toDouble(),
      depositAmount: (data['depositAmount'] ?? 0.0).toDouble(),
      location: data['location'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ListingStatus.values.firstWhere(
        (s) => s.toString().split('.').last == data['status'],
        orElse: () => ListingStatus.active,
      ),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
    );
  }
}

final listingsProvider = StateNotifierProvider<ListingsNotifier, AsyncValue<List<ListingEntity>>>((ref) {
  return ListingsNotifier(FirebaseFirestore.instance);
});
