import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
}

class SignInWithEmail {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    if (!params.email.endsWith('.edu')) {
      return Left(AuthFailure('Please use your college email address'));
    }
    return repository.signInWithEmail(params.email, params.password);
  }
}