import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:renty/features/auth/domain/entities/user_entity.dart';
import 'package:renty/features/auth/domain/repositories/auth_repository.dart';
import 'package:renty/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:renty/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:renty/core/errors/failures.dart';

@GenerateMocks([AuthRepository])
import 'auth_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('SignInWithEmail Tests', () {
    late SignInWithEmail signInUseCase;

    setUp(() {
      signInUseCase = SignInWithEmail(mockAuthRepository);
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
        enrollmentId: 'ENR123',
        isEmailVerified: true,
        isPhoneVerified: false,
        isIdVerified: false,
        createdAt: DateTime(2024, 1, 1),
        rating: 0.0,
        totalRatings: 0,
        avatarUrl: null,
      );

      when(mockAuthRepository.signInWithEmail(email, password))
          .thenAnswer((_) async => Right(user));

      // act
      final result = await signInUseCase(const SignInParams(email: email, password: password));

      // assert
      expect(result, Right(user));
      verify(mockAuthRepository.signInWithEmail(email, password));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when sign in fails with invalid credentials', () async {
      // arrange
      const email = 'test@college.edu';
      const password = 'wrongpassword';
      final failure = AuthFailure('Invalid credentials');

      when(mockAuthRepository.signInWithEmail(email, password))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await signInUseCase(const SignInParams(email: email, password: password));

      // assert
      expect(result, Left(failure));
      verify(mockAuthRepository.signInWithEmail(email, password));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when email is not college email', () async {
      // arrange
      const email = 'test@gmail.com';
      const password = 'password123';
      final failure = AuthFailure('Please use your college email address');

      when(mockAuthRepository.signInWithEmail(email, password))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await signInUseCase(const SignInParams(email: email, password: password));

      // assert
      expect(result, Left(failure));
      verify(mockAuthRepository.signInWithEmail(email, password));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });

  group('SignUpWithEmail Tests', () {
    late SignUpWithEmail signUpUseCase;

    setUp(() {
      signUpUseCase = SignUpWithEmail(mockAuthRepository);
    });

    test('should return user when sign up is successful', () async {
      // arrange
      const email = 'test@college.edu';
      const password = 'Password123!';
      const name = 'Test User';
      const role = UserRole.student;
      const college = 'Test College';
      const enrollmentId = 'ENR123';

      final user = UserEntity(
        id: '1',
        email: email,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
        isEmailVerified: false,
        isPhoneVerified: false,
        isIdVerified: false,
        createdAt: DateTime(2024, 1, 1),
        rating: 0.0,
        totalRatings: 0,
        avatarUrl: null,
      );

      when(mockAuthRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
      )).thenAnswer((_) async => Right(user));

      // act
      final result = await signUpUseCase(const SignUpParams(
        email: email,
        password: password,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
      ));

      // assert
      expect(result, Right(user));
      verify(mockAuthRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when sign up fails with existing email', () async {
      // arrange
      const email = 'existing@college.edu';
      const password = 'Password123!';
      const name = 'Test User';
      const role = UserRole.student;
      const college = 'Test College';
      const enrollmentId = 'ENR123';
      final failure = AuthFailure('Email already exists');

      when(mockAuthRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
      )).thenAnswer((_) async => Left(failure));

      // act
      final result = await signUpUseCase(const SignUpParams(
        email: email,
        password: password,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
      ));

      // assert
      expect(result, Left(failure));
      verify(mockAuthRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure when password is weak', () async {
      // arrange
      const email = 'test@college.edu';
      const password = 'weak';
      const name = 'Test User';
      const role = UserRole.student;
      const college = 'Test College';
      const enrollmentId = 'ENR123';
      final failure = AuthFailure('Password is too weak');

      when(mockAuthRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
      )).thenAnswer((_) async => Left(failure));

      // act
      final result = await signUpUseCase(const SignUpParams(
        email: email,
        password: password,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
      ));

      // assert
      expect(result, Left(failure));
      verify(mockAuthRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
        college: college,
        enrollmentId: enrollmentId,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
