import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/booking_model.dart';
import 'package:wisdomwalk/services/booking_service.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class BookingForm extends StatefulWidget {
  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  String? _issueTitle;
  String _issueDescription = '';
  String _phoneNumber = '';
  String _email = '';
  bool _virtualSession = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Single and Purposeful',
    'Marriage and Ministry',
    'Healing and Forgiveness',
    'Mental Health and Faith',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
        bottom: MediaQuery.of(context).viewInsets.bottom + screenHeight * 0.02,
        top: screenHeight * 0.03,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _issueTitle,
                items:
                    _categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: AutoSizeText(
                              cat,
                              maxLines: 1,
                              minFontSize: 12,
                              maxFontSize: 16,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _issueTitle = val),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val == null ? 'Select a category' : null,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Description
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                onChanged: (val) => _issueDescription = val,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Enter a description'
                            : null,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Phone Number
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) => _phoneNumber = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter your phone number';
                  }
                  final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]{10,15}$');
                  if (!phoneRegex.hasMatch(val)) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
                style: TextStyle(fontSize: screenWidth * 0.04),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Email
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) => _email = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter your email address';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(val)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                style: TextStyle(fontSize: screenWidth * 0.04),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Virtual Session
              SwitchListTile(
                value: _virtualSession,
                onChanged: (val) => setState(() => _virtualSession = val),
                title: AutoSizeText(
                  'Virtual Session?',
                  maxLines: 1,
                  minFontSize: 12,
                  maxFontSize: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    height: screenWidth * 0.12,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Color(0xFFD4A017),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05,
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (currentUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please log in first')),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);
                          final booking = BookingRequest(
                            issueTitle: _issueTitle!,
                            issueDescription: _issueDescription,
                            userId: currentUser.id,
                            createdAt: DateTime.now(),
                            phoneNumber: _phoneNumber,
                            email: _email,
                            virtualSession: _virtualSession,
                          );

                          try {
                            await BookingService().submitBooking(booking);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Booking submitted successfully!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            if (mounted) Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to submit booking: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                      child: AutoSizeText(
                        'Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        minFontSize: 12,
                        maxFontSize: 16,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
