import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/booking_model.dart';
import 'package:wisdomwalk/services/booking_service.dart';

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
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24,
      ),
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
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _category = val),
              decoration: InputDecoration(labelText: 'Category'),
              validator: (val) => val == null ? 'Select a category' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onChanged: (val) => _description = val,
              validator:
                  (val) =>
                      val == null || val.isEmpty ? 'Enter a description' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Contact (email or phone)',
              ),
              onChanged: (val) => _contact = val,
              validator:
                  (val) =>
                      val == null || val.isEmpty
                          ? 'Enter your contact info'
                          : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Preferred Mentor (optional)',
              ),
              onChanged: (val) => _preferredMentor = val,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    child: Text(
                      _selectedDate == null
                          ? 'Pick Date'
                          : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    child: Text(
                      _selectedTime == null
                          ? 'Pick Time'
                          : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedDate != null && _selectedTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected: '
                  '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')} '
                  'at ${_selectedTime!.format(context)}',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(height: 12),
            SwitchListTile(
              value: _virtualSession,
              onChanged: (val) => setState(() => _virtualSession = val),
              title: Text('Virtual Session?'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Additional Notes (optional)',
              ),
              maxLines: 2,
              onChanged: (val) => _additionalNotes = val,
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Color(0xFFD4A017),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                    child: Text('Submit'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
