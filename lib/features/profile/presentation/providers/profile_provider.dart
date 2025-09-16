import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _userId;

  ProfileNotifier(this._firestore, this._storage, this._userId)
      : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>?> getProfileData() async {
    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      return doc.data();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required int age,
    required String address,
    required String college,
    required String enrollmentId,
    File? imageFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      String? imageUrl;
      if (imageFile != null) {
        // Upload image if a new one is selected
        final ref = _storage.ref().child('profile_images').child('$_userId.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      // Update user profile in Firestore
      final userData = {
        'name': name,
        'phone': phone,
        'age': age,
        'address': address,
        'college': college,
        'enrollmentId': enrollmentId,
        if (imageUrl != null) 'avatarUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(_userId).update(userData);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // Re-throw to handle in UI
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
  final userId = ref.read(authStateProvider).user!.id;
  return ProfileNotifier(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
    userId,
  );
});