import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/location.dart';
import 'package:wisdomwalk/providers/location_provider.dart';
import 'package:wisdomwalk/utils/app_theme.dart';
import 'package:wisdomwalk/widgets/church_card.dart';
import 'package:wisdomwalk/widgets/sister_location_card.dart';

class HerMoveScreen extends StatefulWidget {
  const HerMoveScreen({Key? key}) : super(key: key);

  @override
  State<HerMoveScreen> createState() => _HerMoveScreenState();
}

class _HerMoveScreenState extends State<HerMoveScreen> {
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  List<String> _recentSearches = [];
  List<Location> _searchResults = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final searches = await locationProvider.getRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _searchLocation() async {
    final query = _locationController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final results = await locationProvider.searchLocation(query);
      
      setState(() {
        _searchResults = results;
        if (!_recentSearches.contains(query) && results.isNotEmpty) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) {
            _recentSearches = _recentSearches.sublist(0, 5);
          }
          locationProvider.saveRecentSearch(query);
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to search location. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createLocationPost() {
    final location = _locationController.text.trim();
    if (location.isEmpty) return;

    Navigator.pushNamed(
      context, 
      '/create-post',
      arguments: {'location': location, 'type': 'location_help'}
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Her Move',
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
          // Search header with gradient background
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.backgroundLight,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Find Sisters & Churches",
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Moving or traveling? Connect with local sisters and churches.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: "I'm moving to...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: AppTheme.accentColor),
                      onPressed: _searchLocation,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onSubmitted: (_) => _searchLocation(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _createLocationPost,
                        icon: const Icon(Icons.help_outline),
                        label: const Text("Ask for Advice"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Recent searches
          if (!_hasSearched && _recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Searches",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _recentSearches.map((search) {
                      return ActionChip(
                        label: Text(search),
                        onPressed: () {
                          _locationController.text = search;
                          _searchLocation();
                        },
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[300]!),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Search results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : _hasSearched && _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try another location or ask for advice',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _hasSearched
                        ? ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              if (result.type == 'church') {
                                return ChurchCard(church: result);
                              } else {
                                return SisterLocationCard(sister: result);
                              }
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.travel_explore,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Search for a location to find sisters and churches",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
