import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/themes/app_theme.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  // Prayer Preferences
  bool _publicPrayerRequests = true;
  bool _prayerNotifications = true;

  // App Settings
  bool _darkMode = false;
  bool _pushNotifications = true;
  String _selectedLanguage = 'English';

  // Circle Interests
  final List<String> _availableInterests = [
    'Marriage',
    'Single Life',
    'Motherhood',
    'Career',
    'Healing',
    'Ministry',
    'Fitness',
    'Finance',
    'Friendship',
    'Family',
  ];

  List<String> _selectedInterests = ['Marriage', 'Career', 'Healing'];

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Portuguese',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _nameController.text = user.fullName;
      _locationController.text = '${user.city ?? ''}, ${user.country ?? ''}';
      _selectedInterests = List.from(user.wisdomCircleInterests);
    }

    _darkMode = authProvider.themeMode == ThemeMode.dark;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.lightTaupe, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Profile & Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Profile Section
                      _buildProfileSection(),
                      const SizedBox(height: 32),

                      // Prayer Preferences
                      _buildPrayerPreferencesSection(),
                      const SizedBox(height: 32),

                      // Circle Interests
                      _buildCircleInterestsSection(),
                      const SizedBox(height: 32),

                      // App Settings
                      _buildAppSettingsSection(),
                      const SizedBox(height: 40),

                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Profile Picture
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 40, color: Colors.grey),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(onPressed: _changePhoto, child: const Text('Change Photo')),
        const SizedBox(height: 24),

        // Name Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter your name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Bio Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bio',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tell us about yourself...',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Location Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'City, State'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrayerPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.favorite_outline, size: 20),
            SizedBox(width: 8),
            Text(
              'Prayer Preferences',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildToggleItem(
          'Public prayer requests',
          _publicPrayerRequests,
          (value) => setState(() => _publicPrayerRequests = value),
        ),
        const SizedBox(height: 12),
        _buildToggleItem(
          'Prayer notifications',
          _prayerNotifications,
          (value) => setState(() => _prayerNotifications = value),
        ),
      ],
    );
  }

  Widget _buildCircleInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.people_outline, size: 20),
            SizedBox(width: 8),
            Text(
              'Circle Interests',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _availableInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return GestureDetector(
                  onTap: () => _toggleInterest(interest),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFE91E63)
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAppSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.settings_outlined, size: 20),
            SizedBox(width: 8),
            Text(
              'App Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildToggleItem('Dark mode', _darkMode, (value) {
          setState(() => _darkMode = value);
          Provider.of<AuthProvider>(context, listen: false).toggleThemeMode();
        }),
        const SizedBox(height: 12),
        _buildToggleItem(
          'Push notifications',
          _pushNotifications,
          (value) => setState(() => _pushNotifications = value),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(),
              items:
                  _languages.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFE91E63),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _signOut,
            child: const Text(
              'Sign Out',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _changePhoto() {
    // Implement photo change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo change functionality coming soon!'),
        backgroundColor: Color(0xFFE91E63),
      ),
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.updateProfile(
        fullName: _nameController.text,
        wisdomCircleInterests: _selectedInterests,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close settings
                  Provider.of<AuthProvider>(context, listen: false).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }
}
