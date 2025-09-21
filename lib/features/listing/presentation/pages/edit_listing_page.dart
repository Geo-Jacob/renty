import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/image_service.dart';
import '../../../../shared/providers/listing_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/listing_entity.dart';

class EditListingPage extends ConsumerStatefulWidget {
  final ListingEntity listing;
  
  const EditListingPage({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends ConsumerState<EditListingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _hourlyPriceController;
  late final TextEditingController _dailyPriceController;
  late final TextEditingController _depositController;
  
  late String _selectedCategory;
  late ItemCondition _selectedCondition;
  List<String> _existingImageUrls = [];
  List<XFile> _newImages = [];
  bool _isLoading = false;
  bool _isUploadingImages = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.listing.title);
    _descriptionController = TextEditingController(text: widget.listing.description);
    _locationController = TextEditingController(text: widget.listing.location);
    _hourlyPriceController = TextEditingController(text: widget.listing.hourlyPrice.toString());
    _dailyPriceController = TextEditingController(text: widget.listing.dailyPrice.toString());
    _depositController = TextEditingController(text: widget.listing.depositAmount.toString());
    
    _selectedCategory = widget.listing.category;
    _selectedCondition = widget.listing.condition;
    _existingImageUrls = List.from(widget.listing.imageUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _hourlyPriceController.dispose();
    _dailyPriceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildPricingSection(),
            const SizedBox(height: 24),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update photos for your listing',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Existing images
              ..._existingImageUrls.map((imageUrl) => _buildExistingImageCard(imageUrl)),
              // New images
              ..._newImages.map((image) => _buildNewImageCard(image)),
              // Add button
              _buildAddImageCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImageCard(String imageUrl) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _existingImageUrls.remove(imageUrl);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewImageCard(XFile imageFile) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(File(imageFile.path)),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _newImages.remove(imageFile);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageCard() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Enter the title of your listing',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe your listing in detail',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'Enter the location',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a location';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
            DropdownMenuItem(value: 'Books', child: Text('Books')),
            DropdownMenuItem(value: 'Sports', child: Text('Sports')),
            DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
            DropdownMenuItem(value: 'Fashion', child: Text('Fashion')),
            DropdownMenuItem(value: 'Tools', child: Text('Tools')),
            DropdownMenuItem(value: 'Vehicles', child: Text('Vehicles')),
            DropdownMenuItem(value: 'Others', child: Text('Others')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ItemCondition>(
          value: _selectedCondition,
          decoration: const InputDecoration(
            labelText: 'Condition',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.grade_outlined),
          ),
          items: const [
            DropdownMenuItem(value: ItemCondition.newItem, child: Text('New')),
            DropdownMenuItem(value: ItemCondition.good, child: Text('Good')),
            DropdownMenuItem(value: ItemCondition.fair, child: Text('Fair')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCondition = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _hourlyPriceController,
                decoration: const InputDecoration(
                  labelText: 'Hourly Price (₹)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _dailyPriceController,
                decoration: const InputDecoration(
                  labelText: 'Daily Price (₹)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _depositController,
          decoration: const InputDecoration(
            labelText: 'Security Deposit (₹)',
            hintText: '0.00',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.security),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a deposit amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (_isLoading || _isUploadingImages) ? null : _updateListing,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading || _isUploadingImages
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(_isUploadingImages ? 'Uploading Images...' : 'Updating Listing...'),
                ],
              )
            : const Text(
                'Update Listing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImageService.pickSingleImage();
      if (image != null && ImageService.isValidImage(image)) {
        setState(() {
          _newImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authStateProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to update this listing')),
      );
      return;
    }

    // Check if user owns this listing
    if (widget.listing.ownerId != authState.user!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only edit your own listings')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> finalImageUrls = List.from(_existingImageUrls);
      
      // Upload new images if any
      if (_newImages.isNotEmpty) {
        setState(() {
          _isUploadingImages = true;
        });
        
        print('Starting upload of ${_newImages.length} new images');
        
        // Test storage connection first
        print('Testing Firebase Storage connection...');
        final storageConnected = await ImageService.testStorageConnection();
        if (!storageConnected) {
          throw Exception('Firebase Storage is not properly configured. Please enable Firebase Storage in your Firebase Console:\n\n'
              '1. Go to https://console.firebase.google.com/\n'
              '2. Select your project: renty-65844\n'
              '3. Click on "Storage" in the sidebar\n'
              '4. Click "Get started" to enable Storage\n'
              '5. Set up security rules to allow uploads\n\n'
              'Check the console logs for detailed error information.');
        }
        print('✅ Firebase Storage connection verified!');
        
        final newImageUrls = await ImageService.uploadMultipleImages(
          _newImages,
          'listings',
          onProgress: (current, total) {
            print('Uploading image $current of $total');
            // Update UI with progress
            if (mounted) {
              setState(() {
                // Could add progress percentage here if needed
              });
            }
          },
        );
        
        print('Successfully uploaded ${newImageUrls.length} images');
        finalImageUrls.addAll(newImageUrls);
        
        setState(() {
          _isUploadingImages = false;
        });
      }

      print('Updating listing with ${finalImageUrls.length} total images');
      
      await ref.read(listingsProvider.notifier).updateListing(
        listingId: widget.listing.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        hourlyPrice: double.parse(_hourlyPriceController.text.trim()),
        dailyPrice: double.parse(_dailyPriceController.text.trim()),
        depositAmount: double.parse(_depositController.text.trim()),
        location: _locationController.text.trim(),
        category: _selectedCategory,
        condition: _selectedCondition,
        imageUrls: finalImageUrls,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error updating listing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating listing: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingImages = false;
        });
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Listing'),
          content: const Text(
            'Are you sure you want to delete this listing? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteListing();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteListing() async {
    final authState = ref.read(authStateProvider);
    if (authState.user == null || widget.listing.ownerId != authState.user!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own listings')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(listingsProvider.notifier).deleteListing(widget.listing.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting listing: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}