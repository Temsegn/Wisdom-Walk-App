import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdomwalk/providers/her_move_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/models/location_request_model.dart';
import 'package:wisdomwalk/widgets/location_request_card.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationRequestModel> _filteredRequests = [];
  List<LocationRequestModel> _allRequests = [];
  String _selectedFilter = 'All';
  DateTimeRange? _selectedDateRange;
  bool _isSearching = false;

  final List<String> _filterOptions = ['All', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadRequests() async {
    final herMoveProvider = Provider.of<HerMoveProvider>(
      context,
      listen: false,
    );
    await herMoveProvider.fetchRequests();
    setState(() {
      _allRequests = herMoveProvider.requests;
      _filteredRequests = _allRequests;
    });
  }

  void _onSearchChanged() {
    _performSearch();
  }

  void _performSearch() {
    setState(() {
      _isSearching = true;
    });

    final query = _searchController.text.toLowerCase();
    List<LocationRequestModel> results = _allRequests;

    // Text search
    if (query.isNotEmpty) {
      results =
          results.where((request) {
            return (request.toCity?.toLowerCase().contains(query) ?? false) ||
                (request.toCountry?.toLowerCase().contains(query) ?? false) ||
                (request.fromCity?.toLowerCase().contains(query) ?? false) ||
                (request.fromCountry?.toLowerCase().contains(query) ?? false) ||
                (request.description?.toLowerCase().contains(query) ?? false) ||
                (request.firstName?.toLowerCase().contains(query) ?? false);
          }).toList();
    }

    // Apply filters
    results = _applyFilters(results);

    setState(() {
      _filteredRequests = results;
      _isSearching = false;
    });
  }

  List<LocationRequestModel> _applyFilters(
    List<LocationRequestModel> requests,
  ) {
    switch (_selectedFilter) {
      case 'This Week':
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        return requests
            .where((r) => (r.createdAt ?? DateTime.now()).isAfter(weekAgo))
            .toList();
      case 'This Month':
        final monthAgo = DateTime.now().subtract(const Duration(days: 30));
        return requests
            .where((r) => (r.createdAt ?? DateTime.now()).isAfter(monthAgo))
            .toList();
      default:
        return requests;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filter Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Time Period',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                            Navigator.pop(context);
                            _performSearch();
                          },
                          selectedColor: const Color(
                            0xFFE91E63,
                          ).withOpacity(0.2),
                          checkmarkColor: const Color(0xFFE91E63),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Custom Date Range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _showDateRangePicker,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _selectedDateRange != null
                        ? '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}'
                        : 'Select Date Range',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE91E63),
                    side: const BorderSide(color: Color(0xFFE91E63)),
                  ),
                ),
                if (_selectedDateRange != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                      Navigator.pop(context);
                      _performSearch();
                    },
                    child: const Text(
                      'Clear Date Range',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFFE91E63)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _selectedFilter = 'All'; // Reset filter when using custom date range
      });
      Navigator.pop(context);
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Search Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by city, country, or description...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFE91E63),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFFE91E63)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: Stack(
                    children: [
                      const Icon(Icons.filter_list, color: Color(0xFFE91E63)),
                      if (_selectedFilter != 'All' ||
                          _selectedDateRange != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE91E63),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_selectedFilter != 'All' || _selectedDateRange != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const Text(
                    'Active filters: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (_selectedFilter != 'All')
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedFilter,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'All';
                              });
                              _performSearch();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_selectedDateRange != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDateRange = null;
                              });
                              _performSearch();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child:
                _isSearching
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE91E63),
                      ),
                    )
                    : _filteredRequests.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Start typing to search'
                                : 'No requests found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Search by city, country, or description'
                                : 'Try adjusting your search or filters',
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = _filteredRequests[index];
                        final currentUserId =
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).currentUser?.id ??
                            '';

                        return LocationRequestCard(
                          request: request,
                          currentUserId: currentUserId,
                          onTap: () {
                            context.push(
                              '/location-request-detail/${request.id ?? ''}',
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
