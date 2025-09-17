import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:renty/shared/providers/listing_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../widgets/listing_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final listingsState = ref.watch(listingsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSearchSection(),
                const SizedBox(height: 16),
                _buildCategoriesSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildListingsSection(listingsState),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.accentGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Hi there! 👋',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 4),
                  Text(
                    'What would you like to rent today?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ).animate().fadeInLeft(duration: 600.ms, delay: 100.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomSearchBar(
        controller: _searchController,
        onChanged: (query) {
          // Trigger search
          ref.read(listingsProvider.notifier).searchListings(query);
        },
        onFilterTap: () {
          _showFilterBottomSheet();
        },
      ).animate().fadeIn(duration: 600.ms, delay: 100.ms).moveY(begin: 20, duration: 600.ms
      )
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      'All',
      'Electronics',
      'Books',
      'Sports',
      'Furniture',
      'Fashion',
      'Tools',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 12),
            child: CategoryChip(
              label: category,
              isSelected: _selectedCategory == category,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                ref.read(listingsProvider.notifier).filterByCategory(
                  category == 'All' ? null : category,
                );
              },
            ).animate().fadeInUp(
              duration: 400.ms,
              delay: Duration(milliseconds: 50 * index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListingsSection(AsyncValue listingsState) {
    return listingsState.when(
      data: (listings) {
        if (listings.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.mutedText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList.builder(
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return ListingCard(
              listing: listing,
              onTap: () {
                // Navigate to listing detail
                context.push('/listing/${listing.id}');
              },
            );
          },
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      error: (error, stack) => SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        height: MediaQuery.of(context).size.height * 0.6,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedText,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            // Add filter options here
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}