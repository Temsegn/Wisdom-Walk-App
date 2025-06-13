import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/theme_provider.dart';
import 'package:wisdomwalk/utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Amharic', 'French'];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            color: AppTheme.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account section
          _buildSectionHeader('Account'),
          _buildSettingCard(
            title: 'Profile',
            subtitle: 'Edit your profile information',
            icon: Icons.person,
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
          _buildSettingCard(
            title: 'Privacy',
            subtitle: 'Manage your privacy settings',
            icon: Icons.lock,
            onTap: () {
              Navigator.pushNamed(context, '/privacy-settings');
            },
          ),
          _buildSettingCard(
            title: 'Notifications',
            subtitle: 'Configure notification preferences',
            icon: Icons.notifications,
            onTap: () {
              Navigator.pushNamed(context, '/notification-settings');
            },
          ),
          
          const SizedBox(height: 24),
          
          // Appearance section
          _buildSectionHeader('Appearance'),
          _buildSettingCard(
            title: 'Theme',
            subtitle: 'Light or dark mode',
            icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeColor: AppTheme.accentColor,
            ),
            onTap: () {
              themeProvider.toggleTheme();
            },
          ),
          _buildSettingCard(
            title: 'Language',
            subtitle: _selectedLanguage,
            icon: Icons.language,
            onTap: () {
              _showLanguageDialog();
            },
          ),
          _buildSettingCard(
            title: 'Text Size',
            subtitle: 'Adjust the text size',
            icon: Icons.text_fields,
            onTap: () {
              _showTextSizeDialog();
            },
          ),
          
          const SizedBox(height: 24),
          
          // Support section
          _buildSectionHeader('Support'),
          _buildSettingCard(
            title: 'Help Center',
            subtitle: 'Get help with WisdomWalk',
            icon: Icons.help,
            onTap: () {
              Navigator.pushNamed(context, '/help-center');
            },
          ),
          _buildSettingCard(
            title: 'Contact Us',
            subtitle: 'Reach out to our team',
            icon: Icons.email,
            onTap: () {
              Navigator.pushNamed(context, '/contact');
            },
          ),
          _buildSettingCard(
            title: 'Report a Problem',
            subtitle: 'Let us know if something isn\'t working',
            icon: Icons.bug_report,
            onTap: () {
              Navigator.pushNamed(context, '/report-problem');
            },
          ),
          
          const SizedBox(height: 24),
          
          // About section
          _buildSectionHeader('About'),
          _buildSettingCard(
            title: 'About WisdomWalk',
            subtitle: 'Learn more about our mission',
            icon: Icons.info,
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          _buildSettingCard(
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            icon: Icons.policy,
            onTap: () {
              Navigator.pushNamed(context, '/privacy-policy');
            },
          ),
          _buildSettingCard(
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            icon: Icons.description,
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
          ),
          
          const SizedBox(height: 24),
          
          // Logout button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      try {
                        await authProvider.logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to logout. Please try again.')),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App version
          Center(
            child: Text(
              'WisdomWalk v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Select Language',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              color: AppTheme.textDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((language) {
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                  // TODO: Implement language change
                },
                activeColor: AppTheme.accentColor,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTextSizeDialog() {
    double _textSize = 1.0; // Default text size multiplier
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Text Size',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  color: AppTheme.textDark,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Adjust the text size',
                    style: TextStyle(fontSize: 16 * _textSize),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _textSize,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    label: _textSize.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _textSize = value;
                      });
                    },
                    activeColor: AppTheme.accentColor,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('A', style: TextStyle(fontSize: 14)),
                      const Text('A', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Implement text size change
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
