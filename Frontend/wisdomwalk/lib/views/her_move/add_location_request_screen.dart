import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/her_move_provider.dart';

class AddLocationRequestScreen extends StatefulWidget {
  const AddLocationRequestScreen({Key? key}) : super(key: key);

  @override
  State<AddLocationRequestScreen> createState() =>
      _AddLocationRequestScreenState();
}

class _AddLocationRequestScreenState extends State<AddLocationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _fromCityController = TextEditingController();
  final _fromCountryController = TextEditingController();
  final _toCityController = TextEditingController();
  final _toCountryController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _fromCityController.dispose();
    _fromCountryController.dispose();
    _toCityController.dispose();
    _toCountryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Travel Request')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share your travel plans',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let others know about your upcoming move',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _fromCityController,
                  label: 'From City',
                  hint: 'Enter the city you\'re moving from (optional)',
                  required: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _fromCountryController,
                  label: 'From Country',
                  hint: 'Enter the country you\'re moving from (optional)',
                  required: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _toCityController,
                  label: 'To City',
                  hint: 'Enter the city you\'re moving to',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _toCountryController,
                  label: 'To Country',
                  hint: 'Enter the country you\'re moving to',
                ),
                const SizedBox(height: 16),
                _DatePickerTile(
                  date: _selectedDate,
                  onPressed: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                _PrivacyNoticeCard(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Share Travel Request'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator:
          required
              ? (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'Please enter $label'.toLowerCase()
                      : null
              : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText:
            'Tell us about your move and what kind of information you\'re seeking...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        if (value.trim().length < 20) {
          return 'Please provide more details (at least 20 characters)';
        }
        return null;
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Please select a move date'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final herMoveProvider = context.read<HerMoveProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a request'),
          backgroundColor: Colors.red,
        ),
      );
      context.go('/login');
      return;
    }

    setState(() => _isSaving = true);

    final success = await herMoveProvider.addLocationRequest(
      userId: user.id,
      userName: user.fullName,
      userAvatar: user.avatarUrl,
      toCity: _toCityController.text.trim(),
      toCountry: _toCountryController.text.trim(),
      description: _descriptionController.text.trim(),
      moveDate: _selectedDate!,
      fromCity:
          _fromCityController.text.trim().isNotEmpty
              ? _fromCityController.text.trim()
              : null,
      fromCountry:
          _fromCountryController.text.trim().isNotEmpty
              ? _fromCountryController.text.trim()
              : null,
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      context.push('/her-move-search'); // Navigate to the list of requests
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Travel request shared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(herMoveProvider.error ?? 'Failed to share request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({required this.date, required this.onPressed});

  final DateTime? date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Text(
              date == null
                  ? 'Select move date'
                  : 'Moving on ${date!.day}/${date!.month}/${date!.year}',
              style: TextStyle(
                color:
                    date == null
                        ? Colors.grey[600]
                        : Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNoticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Privacy Notice',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your request will be visible to all WisdomWalk members. Only share information you\'re comfortable making public.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
