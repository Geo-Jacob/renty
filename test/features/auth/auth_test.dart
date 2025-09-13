import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:renty/features/auth/domain/entities/user_entity.dart';
import 'package:renty/features/auth/domain/repositories/auth_repository.dart';
import 'package:renty/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:renty/core/errors/failures.dart';

// Generate Mocks BEFORE importing the mocks file
@GenerateMocks([AuthRepository])
import 'auth_test.mocks.dart';

void main() {
  group('Authentication Tests', () {
    late SignInWithEmail usecase;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      usecase = SignInWithEmail(mockAuthRepository);
    });

    test('should return user when sign in is successful', () async {
      // arrange
      const email = 'test@college.edu';
      const password = 'password123';
      final user = UserEntity(
        id: '1',
        email: email,
        name: 'Test User',
        role: UserRole.student,
        college: 'Test College',
        isEmailVerified: true,
        isPhoneVerified: false,
        isIdVerified: false,
        createdAt: DateTime(2024, 1, 1),
        rating: 0.0,
        totalRatings: 0,
      );

      when(mockAuthRepository.signInWithEmail(email, password))
          .thenAnswer((_) async => Right(user));

      // act
      final result = await usecase(SignInParams(email: email, password: password));

      // assert
      expect(result, Right(user));
      verify(mockAuthRepository.signInWithEmail(email, password));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when sign in fails', () async {
      // arrange
      const email = 'test@college.edu';
      const password = 'wrongpassword';
      final failure = AuthFailure('Invalid credentials');

      when(mockAuthRepository.signInWithEmail(email, password))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(SignInParams(email: email, password: password));

      // assert
      expect(result, Left(failure));
      verify(mockAuthRepository.signInWithEmail(email, password));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
