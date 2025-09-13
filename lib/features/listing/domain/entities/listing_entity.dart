import 'package:equatable/equatable.dart';

enum ItemCondition { newItem, good, fair }
enum ListingStatus { active, rented, paused, deleted }

class ListingEntity extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final List<String> imageUrls;
  final ItemCondition condition;
  final double hourlyPrice;
  final double dailyPrice;
  final double depositAmount;
  final String location;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ListingStatus status;
  final double rating;
  final int totalRatings;

  const ListingEntity({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrls,
    required this.condition,
    required this.hourlyPrice,
    required this.dailyPrice,
    required this.depositAmount,
    required this.location,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.rating,
    required this.totalRatings,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        category,
        imageUrls,
        condition,
        hourlyPrice,
        dailyPrice,
        depositAmount,
        location,
        tags,
        createdAt,
        updatedAt,
        status,
        rating,
        totalRatings,
      ];
}
