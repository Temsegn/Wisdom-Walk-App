import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/booking_model.dart';
import 'package:wisdomwalk/services/booking_service.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Add this import

class BookingForm extends StatefulWidget {
  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  String _description = '';
  String _contact = '';
  String _preferredMentor = '';
  String _additionalNotes = '';
  bool _virtualSession = false;
  bool _isLoading = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<String> _categories = [
    'Single & Purposeful',
    'Marriage & Ministry',
    'Healing & Forgiveness',
    'Mental Health & Faith',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.04, // Responsive padding
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
                value: _category,
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
                onChanged: (val) => setState(() => _category = val),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val == null ? 'Select a category' : null,
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                onChanged: (val) => _description = val,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Enter a description'
                            : null,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contact (email or phone)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) => _contact = val,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Enter your contact info'
                            : null,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Preferred Mentor (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) => _preferredMentor = val,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.03,
                        ),
                      ),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          lastDate: now.add(Duration(days: 365)),
                        );
                        if (picked != null)
                          setState(() => _selectedDate = picked);
                      },
                      child: AutoSizeText(
                        _selectedDate == null
                            ? 'Pick Date'
                            : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                        maxLines: 1,
                        minFontSize: 12,
                        maxFontSize: 14,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.03,
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null)
                          setState(() => _selectedTime = picked);
                      },
                      child: AutoSizeText(
                        _selectedTime == null
                            ? 'Pick Time'
                            : _selectedTime!.format(context),
                        maxLines: 1,
                        minFontSize: 12,
                        maxFontSize: 14,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedDate != null && _selectedTime != null)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  child: AutoSizeText(
                    'Selected: '
                    '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')} '
                    'at ${_selectedTime!.format(context)}',
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    minFontSize: 12,
                    maxFontSize: 14,
                  ),
                ),
              SizedBox(height: screenHeight * 0.02),
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
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Additional Notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                onChanged: (val) => _additionalNotes = val,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.03),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    height: screenWidth * 0.12, // Responsive button height
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
                          setState(() => _isLoading = true);
                          final booking = BookingRequest(
                            category: _category!,
                            description: _description,
                            createdAt: DateTime.now(),
                            contact: _contact,
                            preferredMentor:
                                _preferredMentor.isNotEmpty
                                    ? _preferredMentor
                                    : null,
                            additionalNotes:
                                _additionalNotes.isNotEmpty
                                    ? _additionalNotes
                                    : null,
                            virtualSession: _virtualSession,
                            date: _selectedDate,
                            time: _selectedTime,
                          );
                          await BookingService().submitBooking(booking);
                          setState(() => _isLoading = false);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Booking submitted!')),
                          );
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
