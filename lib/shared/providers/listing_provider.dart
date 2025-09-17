import 'package:flutter/foundation.dart';
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
      
      // Start with a simple query to avoid index requirements
      Query query = _firestore.collection('listings');
      
      // Apply basic filter for active listings only
      query = query.where('status', isEqualTo: 'active').limit(20);

      final snapshot = await query.get();
      final allListings = snapshot.docs
          .map((doc) => _mapDocToListing(doc))
          .toList();

      // Apply filters in memory to avoid complex Firestore queries
      List<ListingEntity> filteredListings = allListings;

      // Apply category filter
      if (_currentCategory != null) {
        filteredListings = filteredListings
            .where((listing) => listing.category == _currentCategory)
            .toList();
      }

      // Apply search filter
      if (_currentQuery != null && _currentQuery!.isNotEmpty) {
        final searchLower = _currentQuery!.toLowerCase();
        filteredListings = filteredListings
            .where((listing) => 
                listing.title.toLowerCase().contains(searchLower) ||
                listing.description.toLowerCase().contains(searchLower) ||
                listing.category.toLowerCase().contains(searchLower))
            .toList();
      }

      // Sort by creation date (newest first)
      filteredListings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = AsyncValue.data(filteredListings);
    } catch (error, stackTrace) {
      // Provide more specific error messages
      String errorMessage = 'Failed to load listings';
      if (error.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please check your authentication.';
      } else if (error.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (error.toString().contains('not-found')) {
        errorMessage = 'No listings found.';
      }
      
      // Log the original error for debugging
      debugPrint('Error loading listings: $error');
      debugPrint('Stack trace: $stackTrace');
      
      state = AsyncValue.error(Exception(errorMessage), stackTrace);
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

  Future<void> createListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required String category,
    required String ownerId,
    List<String> imageUrls = const [],
  }) async {
    try {
      // Validate input
      if (title.trim().isEmpty) {
        throw Exception('Title cannot be empty');
      }
      if (description.trim().isEmpty) {
        throw Exception('Description cannot be empty');
      }
      if (price <= 0) {
        throw Exception('Price must be greater than 0');
      }
      if (location.trim().isEmpty) {
        throw Exception('Location cannot be empty');
      }
      if (ownerId.trim().isEmpty) {
        throw Exception('Owner ID cannot be empty');
      }

      final listingData = {
        'title': title.trim(),
        'description': description.trim(),
        'price': price,
        'location': location.trim(),
        'category': category,
        'ownerId': ownerId,
        'imageUrls': imageUrls,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'searchKeywords': _generateSearchKeywords('$title $description $category'),
      };

      await _firestore.collection('listings').add(listingData);
      
      // Reload listings to show the new one
      await loadListings();
    } catch (error, stackTrace) {
      // Log the error for debugging
      debugPrint('Error creating listing: $error');
      debugPrint('Stack trace: $stackTrace');
      
      // Don't update the main state with error, just rethrow for UI handling
      rethrow;
    }
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
      condition: ItemCondition.values.firstWhere(
        (c) => c.toString().split('.').last == (data['condition'] ?? 'good'),
        orElse: () => ItemCondition.good,
      ),
      hourlyPrice: (data['hourlyPrice'] ?? 0.0).toDouble(),
      dailyPrice: (data['dailyPrice'] ?? 0.0).toDouble(),
      depositAmount: (data['depositAmount'] ?? 0.0).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ListingStatus.values.firstWhere(
        (s) => s.toString().split('.').last == (data['status'] ?? 'active'),
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
