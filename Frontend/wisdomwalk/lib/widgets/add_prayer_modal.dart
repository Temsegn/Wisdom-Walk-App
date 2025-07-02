import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';

class AddPrayerModal extends StatefulWidget {
  final bool isAnonymous;

  const AddPrayerModal({Key? key, this.isAnonymous = false}) : super(key: key);

  @override
  State<AddPrayerModal> createState() => _AddPrayerModalState();
}

class _AddPrayerModalState extends State<AddPrayerModal> {
  final _formKey = GlobalKey<FormState>(); // Added for validation
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false; // Changed to match first version
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _isAnonymous = widget.isAnonymous;
    print('AddPrayerModal initialized with isAnonymous: $_isAnonymous');
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPrayer() async {
    print('AddPrayerModal._submitPrayer called');
    if (_formKey.currentState!.validate()) {
      print('Form validation passed');
      setState(() {
        _isSubmitting = true;
      });

      try {
        final prayerProvider = Provider.of<PrayerProvider>(
          context,
          listen: false,
        );
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.currentUser;

        if (currentUser == null) {
          print('Error: No authenticated user found');
          throw Exception('You must be logged in to post a prayer request');
        }

        print('Submitting prayer with data:');
        print('User ID: ${currentUser.id}');
        print('Content: ${_contentController.text.trim()}');
        print('Is Anonymous: $_isAnonymous');
        print('User Name: ${_isAnonymous ? null : currentUser.fullName}');
        print('User Avatar: ${_isAnonymous ? null : currentUser.avatarUrl}');

        final success = await prayerProvider.addPrayer(
          userId: currentUser.id,
          content: _contentController.text.trim(),
          isAnonymous: _isAnonymous,
          userName: _isAnonymous ? null : currentUser.fullName,
          userAvatar: _isAnonymous ? null : currentUser.avatarUrl,
        );

        if (success) {
          print('Prayer posted successfully');
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Prayer request posted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('PrayerProvider.addPrayer failed: ${prayerProvider.error}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to post prayer request: ${prayerProvider.error ?? 'Unknown error'}',
                ),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: _submitPrayer,
                ),
              ),
            );
          }
        }
      } catch (e) {
        print('Error submitting prayer: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              action: SnackBarAction(label: 'Retry', onPressed: _submitPrayer),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          print('Submission process completed');
        }
      }
    } else {
      print('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey, // Added Form widget
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Share a Prayer Request',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Ask for Prayer',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              validator: (value) {
                print('Validating input: $value');
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your prayer request';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value;
                    });
                    print('Anonymous switch changed to: $_isAnonymous');
                  },
                  activeColor: const Color(0xFFE91E63),
                ),
                const SizedBox(width: 8),
                const Text('Post anonymously'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitPrayer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Share Prayer'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
