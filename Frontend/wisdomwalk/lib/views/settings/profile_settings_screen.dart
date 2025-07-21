// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wisdomwalk/models/user_model.dart';
// import 'package:wisdomwalk/providers/auth_provider.dart';
// import 'package:wisdomwalk/themes/app_theme.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileSettingsScreen extends StatefulWidget {
//   const ProfileSettingsScreen({Key? key}) : super(key: key);

//   @override
//   State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
// }

// class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _bioController = TextEditingController();
//   final _locationController = TextEditingController();
//   String? _profileImagePath;

//   // Prayer Preferences
//   bool _publicPrayerRequests = true;
//   bool _prayerNotifications = true;

//   // App Settings
//   bool _darkMode = false;
//   bool _pushNotifications = true;
//   String _selectedLanguage = 'English';

//   // Circle Interests
//   final List<String> _availableInterests = [
//     'Marriage',
//     'Single Life',
//     'Motherhood',
//     'Career',
//     'Healing',
//     'Ministry',
//     'Friendship',
//     'Family',
//   ];

//   List<String> _selectedInterests = ['Marriage', 'Career', 'Healing'];

//   final List<String> _languages = [
//     'English',
//     'Spanish',
//     'French',
//     'German',
//     'Portuguese',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _loadProfileImage();
//   }

//   Future<void> _loadProfileImage() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _profileImagePath = prefs.getString('profile_image_path');
//     });
//   }

//   Future<void> _saveProfileImage(String path) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('profile_image_path', path);
//     setState(() {
//       _profileImagePath = path;
//     });
//   }

//   void _loadUserData() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final user = authProvider.currentUser;

//     if (user != null) {
//       _nameController.text = user.fullName;
//       _locationController.text = '${user.city ?? ''}, ${user.country ?? ''}';
//       _selectedInterests = List.from(user.wisdomCircleInterests);
//     }

//     _darkMode = authProvider.themeMode == ThemeMode.dark;
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _bioController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.currentUser;

//     return Scaffold(
//       backgroundColor: Colors.black.withOpacity(0.5),
//       body: Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           height: MediaQuery.of(context).size.height * 0.9,
//           decoration: BoxDecoration(
//             color: Theme.of(context).scaffoldBackgroundColor,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(color: AppTheme.lightTaupe, width: 1),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     const Expanded(
//                       child: Text(
//                         'Profile & Settings',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close),
//                       style: IconButton.styleFrom(
//                         backgroundColor: Colors.grey.shade100,
//                         shape: const CircleBorder(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Content
//               Expanded(
//                 child: Form(
//                   key: _formKey,
//                   child: ListView(
//                     padding: const EdgeInsets.all(20),
//                     children: [
//                       // Profile Section
//                       _buildProfileSection(user),
//                       const SizedBox(height: 32),

//                       // Prayer Preferences
//                       _buildPrayerPreferencesSection(),
//                       const SizedBox(height: 32),

//                       // Circle Interests
//                       _buildCircleInterestsSection(),
//                       const SizedBox(height: 32),

//                       // App Settings
//                       _buildAppSettingsSection(),
//                       const SizedBox(height: 40),

//                       // Action Buttons
//                       _buildActionButtons(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileSection(UserModel? user) {
//     return Column(
//       children: [
//         // Profile Picture
//         Stack(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 shape: BoxShape.circle,
//                 image:
//                     _profileImagePath != null
//                         ? DecorationImage(
//                           image: FileImage(File(_profileImagePath!)),
//                           fit: BoxFit.cover,
//                         )
//                         : null,
//               ),
//               child:
//                   _profileImagePath == null
//                       ? const Icon(Icons.person, size: 40, color: Colors.grey)
//                       : null,
//             ),
//             if (user != null && user.isVerified)
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.check, color: Colors.white, size: 12),
//                       SizedBox(width: 4),
//                       Text(
//                         'Verified',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         TextButton(onPressed: _changePhoto, child: const Text('Change Photo')),
//         const SizedBox(height: 24),

//         // Name Field
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Name',
//               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _nameController,
//               decoration: const InputDecoration(hintText: 'Enter your name'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your name';
//                 }
//                 return null;
//               },
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),

//         // Bio Field
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Bio',
//               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _bioController,
//               maxLines: 3,
//               decoration: const InputDecoration(
//                 hintText: 'Tell us about yourself...',
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),

//         // Location Field
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Location',
//               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _locationController,
//               decoration: const InputDecoration(hintText: 'City, State'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildPrayerPreferencesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Row(
//           children: [
//             Icon(Icons.favorite_outline, size: 20),
//             SizedBox(width: 8),
//             Text(
//               'Prayer Preferences',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _buildToggleItem(
//           'Public prayer requests',
//           _publicPrayerRequests,
//           (value) => setState(() => _publicPrayerRequests = value),
//         ),
//         const SizedBox(height: 12),
//         _buildToggleItem(
//           'Prayer notifications',
//           _prayerNotifications,
//           (value) => setState(() => _prayerNotifications = value),
//         ),
//       ],
//     );
//   }

//   Widget _buildCircleInterestsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Row(
//           children: [
//             Icon(Icons.people_outline, size: 20),
//             SizedBox(width: 8),
//             Text(
//               'Circle Interests',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children:
//               _availableInterests.map((interest) {
//                 final isSelected = _selectedInterests.contains(interest);
//                 return GestureDetector(
//                   onTap: () => _toggleInterest(interest),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color:
//                           isSelected
//                               ? const Color(0xFFE91E63)
//                               : Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       interest,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.black87,
//                         fontWeight:
//                             isSelected ? FontWeight.w500 : FontWeight.normal,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildAppSettingsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Row(
//           children: [
//             Icon(Icons.settings_outlined, size: 20),
//             SizedBox(width: 8),
//             Text(
//               'App Settings',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _buildToggleItem('Dark mode', _darkMode, (value) {
//           setState(() => _darkMode = value);
//           Provider.of<AuthProvider>(context, listen: false).toggleThemeMode();
//         }),
//         const SizedBox(height: 12),
//         _buildToggleItem(
//           'Push notifications',
//           _pushNotifications,
//           (value) => setState(() => _pushNotifications = value),
//         ),
//         const SizedBox(height: 20),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Language',
//               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: _selectedLanguage,
//               decoration: const InputDecoration(),
//               items:
//                   _languages.map((language) {
//                     return DropdownMenuItem(
//                       value: language,
//                       child: Text(language),
//                     );
//                   }).toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() => _selectedLanguage = value);
//                 }
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildToggleItem(
//     String title,
//     bool value,
//     ValueChanged<bool> onChanged,
//   ) {
//     return Row(
//       children: [
//         Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
//         Switch(
//           value: value,
//           onChanged: onChanged,
//           activeColor: const Color(0xFFE91E63),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: _saveChanges,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE91E63),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text(
//               'Save Change',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           child: TextButton(
//             onPressed: _signOut,
//             child: const Text(
//               'Sign Out',
//               style: TextStyle(fontSize: 16, color: Colors.black87),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _toggleInterest(String interest) {
//     setState(() {
//       if (_selectedInterests.contains(interest)) {
//         _selectedInterests.remove(interest);
//       } else {
//         _selectedInterests.add(interest);
//       }
//     });
//   }

//   void _changePhoto() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     if (image != null) {
//       await _saveProfileImage(image.path);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Profile photo updated successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   void _saveChanges() async {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);

//       final success = await authProvider.updateProfile(
//         firstName: _nameController.text.split(' ').first,
//         lastName:
//             _nameController.text.split(' ').length > 1
//                 ? _nameController.text.split(' ').sublist(1).join(' ')
//                 : null,
//         bio: _bioController.text,
//         city: _locationController.text.split(',').first.trim(),
//         country:
//             _locationController.text.split(',').length > 1
//                 ? _locationController.text
//                     .split(',')
//                     .sublist(1)
//                     .join(',')
//                     .trim()
//                 : null,
//         avatarPath: _profileImagePath,
//       );

//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile updated successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(authProvider.error ?? 'Failed to update profile'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _signOut() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Sign Out'),
//             content: const Text('Are you sure you want to sign out?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   final authProvider = Provider.of<AuthProvider>(
//                     context,
//                     listen: false,
//                   );
//                   final success = await authProvider.logout(context: context);
//                   if (success && context.mounted) {
//                     Navigator.pop(context); // Close dialog
//                     Navigator.pop(context); // Close settings screen
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Signed out successfully'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   } else if (context.mounted && authProvider.error != null) {
//                     Navigator.pop(context); // Close dialog
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(authProvider.error!),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Sign Out'),
//               ),
//             ],
//           ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/user_model.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/themes/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

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
      _bioController.text = user.id ?? '';
      _locationController.text = '${user.city ?? ''}, ${user.country ?? ''}';
      _selectedInterests = List.from(user.wisdomCircleInterests);
      debugPrint('Loaded user avatarUrl: ${user.avatarUrl}');
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

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
                      _buildProfileSection(user),
                      const SizedBox(height: 32),
                      _buildPrayerPreferencesSection(),
                      const SizedBox(height: 32),
                      _buildCircleInterestsSection(),
                      const SizedBox(height: 32),
                      _buildAppSettingsSection(),
                      const SizedBox(height: 40),
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

  Widget _buildProfileSection(UserModel? user) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                image:
                    user?.avatarUrl != null
                        ? DecorationImage(
                          image: NetworkImage(
                            '${user!.avatarUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
                          ),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            debugPrint(
                              'Failed to load profile image: $exception',
                            );
                          },
                        )
                        : null,
              ),
              child:
                  user?.avatarUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
            ),
            if (user != null && user.isVerified)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
              'Save Change',
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

  Future<void> _changePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final compressedImage = await _compressImage(image);
      if (compressedImage == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to compress image. Please try another image.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final success = await _uploadProfilePicture(compressedImage);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        String errorMessage =
            authProvider.error ??
            'Failed to update profile photo. Please try again.';
        if (authProvider.error == null) {
          authProvider.error = errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<XFile?> _compressImage(XFile image) async {
    try {
      final filePath = image.path;
      final lastIndex = filePath.lastIndexOf('.');
      final extension = filePath.substring(lastIndex).toLowerCase();
      final tempDir = Directory.systemTemp;
      final compressedFilePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}$extension';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        compressedFilePath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );

      if (compressedFile == null) {
        debugPrint('Image compression failed');
        Provider.of<AuthProvider>(context, listen: false).error =
            'Image compression failed';
        return null;
      }

      // Check file size
      final fileSize = await compressedFile.length();
      debugPrint('Compressed image size: ${fileSize / 1024 / 1024} MB');
      if (fileSize > 2 * 1024 * 1024) {
        debugPrint('Compressed image too large: ${fileSize / 1024 / 1024} MB');
        Provider.of<AuthProvider>(context, listen: false).error =
            'Image size exceeds 2MB limit after compression';
        return null;
      }

      return XFile(compressedFile.path);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      Provider.of<AuthProvider>(context, listen: false).error =
          'Error compressing image: $e';
      return null;
    }
  }

  Future<bool> _uploadProfilePicture(XFile image) async {
    try {
      final token = await LocalStorageService().getAuthToken();
      if (token == null) {
        debugPrint('No auth token found');
        Provider.of<AuthProvider>(context, listen: false).error =
            'No auth token found';
        return false;
      }

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(
          'https://wisdom-walk-app.onrender.com/api/users/profile/photo',
        ),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        image.path,
        filename: image.name,
      );
      request.files.add(multipartFile);
      debugPrint('Uploading file with field name: file');
      debugPrint('File path: ${image.path}, File name: ${image.name}');

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );
      final responseBody = await http.Response.fromStream(response);

      debugPrint('Upload profile picture response: ${response.statusCode}');
      debugPrint('Response body: ${responseBody.body}');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody.body);
        final newAvatarUrl = data['data']['profilePicture'];
        debugPrint('New avatar URL: $newAvatarUrl');
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).updateUserAvatar(newAvatarUrl);
        Provider.of<AuthProvider>(context, listen: false).error = null;
        return true;
      } else {
        final errorData = json.decode(responseBody.body);
        final errorMessage =
            errorData['message'] ?? 'Failed to update profile photo';
        debugPrint('Upload failed: ${responseBody.body}');
        Provider.of<AuthProvider>(context, listen: false).error = errorMessage;
        return false;
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      Provider.of<AuthProvider>(context, listen: false).error =
          'Error uploading profile picture: $e';
      return false;
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.updateProfile(
        firstName: _nameController.text.split(' ').first,
        lastName:
            _nameController.text.split(' ').length > 1
                ? _nameController.text.split(' ').sublist(1).join(' ')
                : null,
        bio: _bioController.text,
        city: _locationController.text.split(',').first.trim(),
        country:
            _locationController.text.split(',').length > 1
                ? _locationController.text
                    .split(',')
                    .sublist(1)
                    .join(',')
                    .trim()
                : null,
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
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final success = await authProvider.logout(context: context);
                  if (success && context.mounted) {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close settings screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signed out successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (context.mounted && authProvider.error != null) {
                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.error!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
