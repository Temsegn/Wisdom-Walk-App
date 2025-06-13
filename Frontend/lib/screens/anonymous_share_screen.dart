import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/confession.dart';
import 'package:wisdomwalk/providers/confession_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/utils/app_theme.dart';
import 'package:wisdomwalk/widgets/confession_card.dart';

class AnonymousShareScreen extends StatefulWidget {
  const AnonymousShareScreen({Key? key}) : super(key: key);

  @override
  State<AnonymousShareScreen> createState() => _AnonymousShareScreenState();
}

class _AnonymousShareScreenState extends State<AnonymousShareScreen> {
  final TextEditingController _confessionController = TextEditingController();
  String _selectedCategory = 'Confession';
  bool _isLoading = false;
  final List<String> _categories = ['Confession', 'Testimony', 'Struggle'];

  @override
  void initState() {
    super.initState();
    _loadConfessions();
    
    // Listen for real-time confession updates
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket?.on('new_confession', (_) {
      _loadConfessions();
    });
    socketProvider.socket?.on('confession_update', (_) {
      _loadConfessions();
    });
  }

  Future<void> _loadConfessions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final confessionProvider = Provider.of<ConfessionProvider>(context, listen: false);
      await confessionProvider.fetchConfessions();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load confessions. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitConfession() async {
    if (_confessionController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final confessionProvider = Provider.of<ConfessionProvider>(context, listen: false);
      
      await confessionProvider.createConfession(
        content: _confessionController.text.trim(),
        category: _selectedCategory,
      );
      
      _confessionController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your anonymous share has been posted')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final confessionProvider = Provider.of<ConfessionProvider>(context);
    final confessions = confessionProvider.confessions;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Anonymous Share',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            color: AppTheme.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Anonymous share input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondaryColor.withOpacity(0.2),
                  AppTheme.secondaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock, color: AppTheme.accentColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Share Anonymously',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'A safe space to share your heart without revealing your identity',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confessionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'What would you like to share anonymously?',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitConfession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: confessionProvider.selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      confessionProvider.filterByCategory(null);
                    }
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: confessionProvider.selectedCategory == null
                        ? AppTheme.primaryColor
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                ..._categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: confessionProvider.selectedCategory == category,
                      onSelected: (selected) {
                        if (selected) {
                          confessionProvider.filterByCategory(category);
                        }
                      },
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: confessionProvider.selectedCategory == category
                            ? AppTheme.primaryColor
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Confessions list
          Expanded(
            child: _isLoading && confessions.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : confessions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No anonymous shares yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to share anonymously',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadConfessions,
                        color: AppTheme.primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: confessions.length,
                          itemBuilder: (context, index) {
                            final confession = confessions[index];
                            return ConfessionCard(confession: confession);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
