import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/listing_entity.dart';

final listingByIdProvider = FutureProvider.family<ListingEntity, String>((ref, id) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('listings').doc(id).get();
    
    if (!doc.exists) {
      throw Exception('Listing not found');
    }
    
    final data = doc.data()!;
    return ListingEntity(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      condition: ItemCondition.values.firstWhere(
        (c) => c.toString().split('.').last == (data['condition'] ?? 'good'),
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
        (s) => s.toString().split('.').last == (data['status'] ?? 'active'),
        orElse: () => ListingStatus.active,
      ),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
    );
  } catch (error, stackTrace) {
    throw AsyncError(
      'Failed to load listing: ${error.toString()}',
      stackTrace,
    );
  }
});