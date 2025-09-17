import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/listing/presentation/pages/home_page.dart';
import '../../features/listing/presentation/pages/listing_detail_page.dart';
import '../../features/listing/presentation/pages/create_listing_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/bookings_list_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/listing/presentation/providers/listing_providers.dart';
import '../widgets/bottom_nav_scaffold.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: authState.user != null ? '/home' : '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoginRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      
      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      
      // Main app routes with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return BottomNavScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/bookings',
            name: 'bookings',
            builder: (context, state) => const BookingsListPage(),
          ),
          GoRoute(
            path: '/booking/:listingId',
            name: 'booking',
            builder: (context, state) {
              final listingId = state.pathParameters['listingId']!;
              return Consumer(
                builder: (context, ref, child) {
                  final listingAsync = ref.watch(listingByIdProvider(listingId));
                  return listingAsync.when(
                    data: (listing) => BookingPage(listing: listing),
                    loading: () => const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Scaffold(
                      body: Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/chats',
            name: 'chats',
            builder: (context, state) => const ChatListPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      
      // Detail routes
      GoRoute(
        path: '/listing/:id',
        name: 'listing-details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return Consumer(
            builder: (context, ref, child) {
              final listingAsync = ref.watch(listingByIdProvider(id));
              return listingAsync.when(
                data: (listing) => ListingDetailPage(listing: listing),
                loading: () => const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Scaffold(
                  body: Center(
                    child: Text('Error: $error'),
                  ),
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/create-listing',
        name: 'create-listing',
        builder: (context, state) => const CreateListingPage(),
      ),
    ],
  );
});