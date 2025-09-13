import 'package:equatable/equatable.dart';

enum UserRole { student, faculty }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final UserRole role;
  final String college;
  final String? enrollmentId;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isIdVerified;
  final DateTime createdAt;
  final double rating;
  final int totalRatings;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.college,
    this.enrollmentId,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isIdVerified,
    required this.createdAt,
    required this.rating,
    required this.totalRatings,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        role,
        college,
        enrollmentId,
        isEmailVerified,
        isPhoneVerified,
        isIdVerified,
        createdAt,
        rating,
        totalRatings,
      ];
}