import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;

  BookingNotifier(this._firestore) : super(const AsyncValue.data(null));

  Future<void> createBooking({
    required String listingId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isHourlyBooking,
    int? duration,
    required double totalPrice,
    required double depositAmount,
  }) async {
    try {
      state = const AsyncValue.loading();

      final bookingData = {
        'listingId': listingId,
        'userId': userId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'isHourlyBooking': isHourlyBooking,
        'duration': duration,
        'totalPrice': totalPrice,
        'depositAmount': depositAmount,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('bookings').add(bookingData);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, AsyncValue<void>>((ref) {
  return BookingNotifier(FirebaseFirestore.instance);
});