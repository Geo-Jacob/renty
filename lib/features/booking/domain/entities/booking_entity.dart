import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, rejected, completed, cancelled }

class BookingEntity extends Equatable {
  final String id;
  final String listingId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isHourlyBooking;
  final int? duration;
  final double totalPrice;
  final double depositAmount;
  final BookingStatus status;
  final DateTime createdAt;

  const BookingEntity({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.isHourlyBooking,
    this.duration,
    required this.totalPrice,
    required this.depositAmount,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        listingId,
        userId,
        startDate,
        endDate,
        isHourlyBooking,
        duration,
        totalPrice,
        depositAmount,
        status,
        createdAt,
      ];
}