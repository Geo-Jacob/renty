import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/listing_entity.dart';

/// A notifier that manages the state of listings in the application.
/// Handles loading, filtering, and searching of listings from Firestore.
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
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      location: data['location'] ?? '',
      images: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownerId: data['ownerId'] ?? '',
      category: data['category'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }
}

final listingsProvider = StateNotifierProvider<ListingsNotifier, AsyncValue<List<ListingEntity>>>((ref) {
  return ListingsNotifier(FirebaseFirestore.instance);
});
