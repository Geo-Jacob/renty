import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../providers/booking_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BookingPage extends ConsumerStatefulWidget {
  final ListingEntity listing;

  const BookingPage({super.key, required this.listing});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  DateTime? startDate;
  DateTime? endDate;
  bool isHourlyBooking = false;
  int duration = 1;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.listing.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.listing.imageUrls[0],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        widget.listing.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Condition: ${widget.listing.condition.toString().split('.').last}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${widget.listing.location}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Booking Type Selection
              Text(
                'Booking Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Daily'),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Hourly'),
                  ),
                ],
                selected: {isHourlyBooking},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    isHourlyBooking = selection.first;
                    duration = 1;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Date Selection
              Text(
                'Select Dates',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      onTap: () => _selectStartDate(context),
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: startDate != null
                            ? DateFormat('MMM dd, yyyy').format(startDate!)
                            : '',
                      ),
                      validator: (value) {
                        if (startDate == null) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      onTap: () => _selectEndDate(context),
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: endDate != null
                            ? DateFormat('MMM dd, yyyy').format(endDate!)
                            : '',
                      ),
                      validator: (value) {
                        if (endDate == null) {
                          return 'Please select an end date';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Duration Selection (for hourly bookings)
              if (isHourlyBooking) ...[
                Text(
                  'Duration (hours)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: duration,
                  items: List.generate(12, (index) => index + 1)
                      .map((hours) => DropdownMenuItem(
                            value: hours,
                            child: Text('$hours ${hours == 1 ? 'hour' : 'hours'}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      duration = value ?? 1;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Price Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Breakdown',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Rental Price:'),
                          Text(
                            '₹${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Security Deposit:'),
                          Text(
                            '₹${widget.listing.depositAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${(totalPrice + widget.listing.depositAmount).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: _submitBooking,
            child: const Text('Confirm Booking'),
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date first')),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: startDate!,
      firstDate: startDate!,
      lastDate: startDate!.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  double _calculateTotalPrice() {
    if (startDate == null || (endDate == null && !isHourlyBooking)) {
      return 0.0;
    }

    if (isHourlyBooking) {
      return widget.listing.hourlyPrice * duration;
    } else {
      final days = endDate!.difference(startDate!).inDays + 1;
      return widget.listing.dailyPrice * days;
    }
  }

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final totalPrice = _calculateTotalPrice();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await ref.read(bookingProvider.notifier).createBooking(
            listingId: widget.listing.id,
            userId: ref.read(authStateProvider).user!.id,
            startDate: startDate!,
            endDate: endDate!,
            isHourlyBooking: isHourlyBooking,
            duration: isHourlyBooking ? duration : null,
            totalPrice: totalPrice,
            depositAmount: widget.listing.depositAmount,
          );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Return to previous screen
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create booking: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
