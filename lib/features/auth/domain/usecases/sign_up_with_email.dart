import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;
  final String name;
  final UserRole role;
  final String college;
  final String? enrollmentId;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.college,
    this.enrollmentId,
  });
}

class SignUpWithEmail {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    if (!params.email.endsWith('.edu')) {
      return Left(AuthFailure('Please use your college email address'));
    }

    if (params.password.length < 8) {
      return Left(AuthFailure('Password must be at least 8 characters long'));
    }

    return repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
      college: params.college,
      enrollmentId: params.enrollmentId,
    );
  }
}