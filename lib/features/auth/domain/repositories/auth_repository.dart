import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password);

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String college,
    String? enrollmentId,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, bool>> isSignedIn();
}