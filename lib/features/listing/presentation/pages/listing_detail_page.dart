import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/listing_entity.dart';

class ListingDetailPage extends ConsumerWidget {
  final ListingEntity listing;

  const ListingDetailPage({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: listing.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      listing.imageUrls[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 8),
                      Text(listing.location),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
