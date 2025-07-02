import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/prayer_provider.dart';

class AddPrayerButton extends StatelessWidget {
  final bool isAnonymous;

  const AddPrayerButton({Key? key, this.isAnonymous = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder:
              (context) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: AddPrayerModal(isAnonymous: isAnonymous),
              ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

class AddPrayerModal extends StatefulWidget {
  final bool isAnonymous;

  const AddPrayerModal({Key? key, this.isAnonymous = false}) : super(key: key);

  @override
  State<AddPrayerModal> createState() => _AddPrayerModalState();
}

class _AddPrayerModalState extends State<AddPrayerModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isAnonymous = false;
  String _selectedCategory = 'testimony'; // default

  @override
  void initState() {
    super.initState();
    _isAnonymous = widget.isAnonymous;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPrayer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final prayerProvider = Provider.of<PrayerProvider>(
          context,
          listen: false,
        );
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.currentUser;

        final success = await prayerProvider.addPrayer(
          userId: currentUser?.id ?? 'anonymous',
          content: _contentController.text.trim(),
          isAnonymous: _isAnonymous,
          category: _selectedCategory,
          userName: _isAnonymous ? null : currentUser?.fullName,
          userAvatar: _isAnonymous ? null : currentUser?.avatarUrl,
        );

        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prayer request posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to post prayer');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.8, // Limit modal height
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Share a Prayer Request',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Ask for Prayer...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your prayer request';
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
                  ),
                  items:
                      ['testimony', 'confession', 'struggle']
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category[0].toUpperCase() +
                                    category.substring(1),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() {
                        _selectedCategory = value!;
                      }),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please select a category'
                              : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: _isAnonymous,
                      onChanged:
                          (value) => setState(() {
                            _isAnonymous = value;
                          }),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
