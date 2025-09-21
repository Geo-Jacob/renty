import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ImageService {
  static FirebaseStorage? _storageInstance;
  
  static FirebaseStorage get _storage {
    if (_storageInstance != null) return _storageInstance!;
    
    try {
      // Use default instance only
      _storageInstance = FirebaseStorage.instance;
      print('Using Firebase Storage bucket: ${_storageInstance!.bucket}');
      return _storageInstance!;
    } catch (e) {
      print('Error getting Firebase Storage instance: $e');
      rethrow;
    }
  }
  
  static final ImagePicker _picker = ImagePicker();
  static const Uuid _uuid = Uuid();

  /// Check network connectivity before upload
  static Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Connectivity check failed: $e');
      return false; // Assume no connection if check fails
    }
  }

  /// Test Firebase Storage connectivity and write access
  static Future<bool> testStorageConnection() async {
    try {
      print('Testing Firebase Storage connection...');
      
      // Test with default instance
      final storage = _storage;
      print('Storage bucket: ${storage.bucket}');
      
      // Try to create a simple test file to verify write access
      try {
        final testRef = storage.ref().child('test/connection-test-${DateTime.now().millisecondsSinceEpoch}.txt');
        print('Test reference path: ${testRef.fullPath}');
        print('Test reference bucket: ${testRef.bucket}');
        
        // Try to upload a simple string as a test
        final testData = 'Firebase Storage connection test - ${DateTime.now()}';
        await testRef.putString(testData);
        
        print('✅ Successfully uploaded test file to Firebase Storage');
        
        // Try to read it back
        final downloadUrl = await testRef.getDownloadURL();
        print('✅ Successfully got download URL: $downloadUrl');
        
        // Clean up test file
        await testRef.delete();
        print('✅ Successfully deleted test file');
        
        print('🎉 Firebase Storage is working correctly!');
        return true;
        
      } catch (e) {
        print('❌ Firebase Storage test failed: $e');
        
        if (e.toString().contains('object-not-found') || e.toString().contains('404')) {
          print('💡 This means Firebase Storage is not enabled in your Firebase project.');
          print('💡 Please go to Firebase Console and enable Storage.');
        } else if (e.toString().contains('permission-denied') || e.toString().contains('403')) {
          print('💡 This means Firebase Storage rules deny access.');
          print('💡 Please check your Storage security rules.');
        } else if (e.toString().contains('storage/bucket-not-found')) {
          print('💡 Storage bucket does not exist. Please enable Firebase Storage.');
        }
        
        return false;
      }
    } catch (e) {
      print('❌ Storage connection test failed: $e');
      return false;
    }
  }

  /// Pick multiple images from gallery (one by one)
  static Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = [];
      XFile? image;
      
      // Pick first image
      image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        images.add(image);
      }
      
      return images;
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  /// Pick single image from gallery or camera
  static Future<XFile?> pickSingleImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Upload single image to Firebase Storage
  static Future<String> uploadImage(XFile imageFile, String folder) async {
    try {
      // Check connectivity first
      final hasConnection = await _checkConnectivity();
      if (!hasConnection) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      
      print('Starting image upload for file: ${imageFile.path}');
      
      // Verify file exists
      final File file = File(imageFile.path);
      if (!await file.exists()) {
        throw Exception('Image file does not exist at path: ${imageFile.path}');
      }
      
      final int fileSize = await file.length();
      print('File size: ${fileSize} bytes');
      
      if (fileSize == 0) {
        throw Exception('Image file is empty or corrupted');
      }
      
      if (fileSize > 10 * 1024 * 1024) { // 10MB limit
        throw Exception('Image file too large. Maximum size is 10MB.');
      }
      
      // Generate unique filename with timestamp to avoid conflicts
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}.jpg';
      print('Generated filename: $fileName');
      
      // Create storage reference
      final Reference ref = _storage.ref().child('$folder/$fileName');
      print('Created storage reference: ${ref.fullPath}');
      print('Storage bucket: ${ref.bucket}');
      
      // Create metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_by': 'renty_app',
          'upload_timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      print('Starting file upload...');
      final UploadTask uploadTask = ref.putFile(file, metadata);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print('Upload progress: ${(progress * 100).toStringAsFixed(1)}% (${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes)');
        },
        onError: (error) {
          print('Upload stream error: $error');
        },
      );
      
      final TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(minutes: 5), // Increased timeout
        onTimeout: () {
          print('Upload timed out after 5 minutes');
          throw Exception('Upload timed out. Please check your internet connection and try again.');
        },
      );
      
      print('Upload completed successfully');
      print('Upload state: ${snapshot.state}');
      print('Bytes transferred: ${snapshot.totalBytes}');
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Download URL obtained: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      print('Error type: ${e.runtimeType}');
      
      if (e.toString().contains('object-not-found') || e.toString().contains('404')) {
        throw Exception('Firebase Storage bucket not configured. Please set up Firebase Storage in your Firebase project console and ensure proper security rules are configured.');
      } else if (e.toString().contains('permission-denied') || e.toString().contains('403')) {
        throw Exception('Permission denied. Please check Firebase Storage security rules allow uploads.');
      } else if (e.toString().contains('network') || e.toString().contains('timeout')) {
        throw Exception('Network error. Please check your internet connection and try again.');
      } else if (e.toString().contains('invalid-argument')) {
        throw Exception('Invalid file format. Please select a valid image file.');
      } else if (e.toString().contains('quota-exceeded')) {
        throw Exception('Storage quota exceeded. Please contact support.');
      }
      
      throw Exception('Failed to upload image: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Upload multiple images to Firebase Storage with parallel processing
  static Future<List<String>> uploadMultipleImages(
    List<XFile> imageFiles, 
    String folder, 
    {Function(int, int)? onProgress}
  ) async {
    try {
      print('Starting upload of ${imageFiles.length} images to folder: $folder');
      
      // Check all files before starting upload
      for (int i = 0; i < imageFiles.length; i++) {
        final File file = File(imageFiles[i].path);
        final int fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) { // 10MB limit
          throw Exception('Image ${i + 1} is too large. Maximum size is 10MB.');
        }
      }
      
      final List<String> downloadUrls = [];
      
      // Upload images one by one for better progress tracking and error handling
      for (int i = 0; i < imageFiles.length; i++) {
        onProgress?.call(i + 1, imageFiles.length);
        print('Uploading image ${i + 1} of ${imageFiles.length}');
        
        final String url = await uploadImage(imageFiles[i], folder);
        downloadUrls.add(url);
        
        print('Successfully uploaded image ${i + 1}: $url');
      }
      
      print('All ${imageFiles.length} images uploaded successfully');
      return downloadUrls;
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Delete image from Firebase Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Log error but don't throw - image might already be deleted
      print('Warning: Could not delete image: $e');
    }
  }

  /// Delete multiple images from Firebase Storage
  static Future<void> deleteMultipleImages(List<String> imageUrls) async {
    for (final String url in imageUrls) {
      await deleteImage(url);
    }
  }

  /// Get image size in bytes
  static Future<int> getImageSize(XFile imageFile) async {
    final File file = File(imageFile.path);
    return await file.length();
  }

  /// Validate image file
  static bool isValidImage(XFile imageFile) {
    final String extension = imageFile.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }
}