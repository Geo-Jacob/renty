enum ItemCondition { newItem, good, fair }
enum ListingStatus { active, inactive, rented, deleted }

class ListingEntity {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final List<String> images;
  final DateTime createdAt;
  final String ownerId;
  final String category;
  final List<String> imageUrls;
  final ItemCondition condition;
  final double hourlyPrice;
  final double dailyPrice;
  final double depositAmount;
  final List<String> tags;
  final DateTime updatedAt;
  final ListingStatus status;
  final double rating;
  final int totalRatings;

  ListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.images,
    required this.createdAt,
    required this.ownerId,
    required this.category,
    required this.imageUrls,
    this.condition = ItemCondition.good,
    this.hourlyPrice = 0.0,
    this.dailyPrice = 0.0,
    this.depositAmount = 0.0,
    this.tags = const [],
    required this.updatedAt,
    this.status = ListingStatus.active,
    this.rating = 0.0,
    this.totalRatings = 0,
  });
}