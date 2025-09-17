import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthResult {
  final bool isSuccess;
  final String? error;

  const AuthResult.success() : isSuccess = true, error = null;
  const AuthResult.failure(this.error) : isSuccess = false;
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthStateNotifier(this._firebaseAuth, this._googleSignIn) 
      : super(const AuthState()) {
    _init();
  }

  void _init() {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadUserProfile(firebaseUser);
      } else {
        state = state.copyWith(user: null);
      }
    });
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      // In a real app, you'd fetch additional user data from Firestore
      final user = UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName ?? 'User',
        avatarUrl: firebaseUser.photoURL,
        role: UserRole.student, // Default, would be fetched from database
        college: 'Unknown', // Would be fetched from database
        isEmailVerified: firebaseUser.emailVerified,
        isPhoneVerified: firebaseUser.phoneNumber != null,
        isIdVerified: false, // Would be fetched from database
        createdAt: DateTime.now(),
        rating: 0.0,
        totalRatings: 0,
      );
      
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<AuthResult> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      debugPrint('Attempting sign in with email: $email'); // Debug log
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        debugPrint('Sign in successful for user: ${userCredential.user!.uid}'); // Debug log
        return const AuthResult.success();
      } else {
        const error = 'Sign in failed - no user returned';
        state = state.copyWith(error: error, isLoading: false);
        return const AuthResult.failure(error);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}'); // Debug log
      final error = _getAuthErrorMessage(e.code);
      state = state.copyWith(error: error, isLoading: false);
      return AuthResult.failure(error);
    } catch (e) {
      debugPrint('Unexpected error during sign in: $e'); // Debug log
      const error = 'An unexpected error occurred';
      state = state.copyWith(error: error, isLoading: false);
      return const AuthResult.failure(error);
    }
  }

  Future<AuthResult> signUpWithEmail(
    String email, 
    String password, 
    String name,
    UserRole role,
    String college,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await result.user?.updateDisplayName(name);
      await result.user?.sendEmailVerification();
      
      // In a real app, save additional user data to Firestore here
      
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      final error = _getAuthErrorMessage(e.code);
      state = state.copyWith(error: error, isLoading: false);
      return AuthResult.failure(error);
    } catch (e) {
      const error = 'An unexpected error occurred';
      state = state.copyWith(error: error, isLoading: false);
      return const AuthResult.failure(error);
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return const AuthResult.failure('Sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      return const AuthResult.success();
    } catch (e) {
      const error = 'Google sign in failed';
      state = state.copyWith(error: error, isLoading: false);
      return const AuthResult.failure(error);
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed';
    }
  }

  Future signUpWithGoogle() async {}
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(
    FirebaseAuth.instance,
    GoogleSignIn(scopes: ['email', 'profile']),
  );
});