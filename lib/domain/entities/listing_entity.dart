class ListingEntity {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final List<String> images;
  final DateTime createdAt;

  ListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.images,
    required this.createdAt, required ownerId, required category, required List<String> imageUrls,
  });
}