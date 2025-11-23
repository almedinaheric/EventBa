import 'dart:async';
import 'dart:convert';

import 'package:eventba_mobile/screens/category_events_screen.dart';
import 'package:eventba_mobile/screens/event_details_screen.dart';
import 'package:eventba_mobile/screens/private_events_screen.dart';
import 'package:eventba_mobile/screens/public_events_screen.dart';
import 'package:eventba_mobile/screens/recommended_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/text_link_button.dart';
import 'package:eventba_mobile/widgets/event_card.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/category_provider.dart';
import '../models/event/basic_event.dart';
import '../models/category/category_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<BasicEvent>> _recommendedEventsFuture;
  late Future<List<BasicEvent>> _publicEventsFuture;
  late Future<List<BasicEvent>> _privateEventsFuture;
  late Future<List<CategoryModel>> _categoriesFuture;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;
  List<BasicEvent> _searchResults = [];
  bool _isSearching = false;
  bool _isSearchLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _loadData() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Fetch different types of events from your API
    _recommendedEventsFuture = _fetchRecommendedEvents(eventProvider);
    _publicEventsFuture = _fetchPublicEvents(eventProvider);
    _privateEventsFuture = _fetchPrivateEvents(eventProvider);
    _categoriesFuture = _fetchCategories(categoryProvider);
  }

  Future<List<BasicEvent>> _fetchRecommendedEvents(
    EventProvider provider,
  ) async {
    try {
      // Assuming your provider has a method to get recommended events
      final result = await provider.getRecommendedEvents();
      return result; // Adjust based on your API response structure
    } catch (e) {
      print('Error fetching recommended events: $e');
      return [];
    }
  }

  Future<List<BasicEvent>> _fetchPublicEvents(EventProvider provider) async {
    try {
      final result = await provider.getPublicEvents();
      return result; // Adjust based on your API response structure
    } catch (e) {
      print('Error fetching public events: $e');
      return [];
    }
  }

  Future<List<BasicEvent>> _fetchPrivateEvents(EventProvider provider) async {
    try {
      final result = await provider.getPrivateEvents();
      return result; // Adjust based on your API response structure
    } catch (e) {
      print('Error fetching private events: $e');
      return [];
    }
  }

  Future<List<CategoryModel>> _fetchCategories(
    CategoryProvider provider,
  ) async {
    try {
      final result = await provider.get();
      return result.result; // Based on your existing code structure
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  void _handleSearchChange(String query) {
    _searchTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _isSearchLoading = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
    });

    _searchTimer = Timer(const Duration(seconds: 1), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String searchTerm) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    try {
      final results = await eventProvider.searchEvents(searchTerm);
      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
      });
    } catch (e) {
      print('Error searching events: $e');
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                if (_isSearching) ...[
                  _buildSearchResults(),
                ] else ...[
                  _buildSectionHeader(
                    "Recommended Events",
                    onViewAllTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const RecommendedEventsScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildRecommendedEvents(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    "Search by categories",
                    showViewAll: false,
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryChips(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    "Public Events",
                    onViewAllTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const PublicEventsScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPublicEvents(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    "Private Events",
                    onViewAllTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const PrivateEventsScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPrivateEvents(),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade600),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearchChange('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 16,
          ),
        ),
        onChanged: _handleSearchChange,
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    bool showViewAll = true,
    VoidCallback? onViewAllTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (showViewAll)
          TextLinkButton(linkText: "View All", onTap: onViewAllTap ?? () {}),
      ],
    );
  }

  Widget _buildRecommendedEvents() {
    return FutureBuilder<List<BasicEvent>>(
      future: _recommendedEventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingContainer(160);
        } else if (snapshot.hasError) {
          return _buildErrorContainer('Failed to load recommended events', 160);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyContainer('No recommended events found', 160);
        }

        final events = snapshot.data!;
        return SizedBox(
          height: 160,
          child: Row(
            children: [
              Expanded(child: _buildEventCard(events[0])),
              if (events.length > 1) ...[
                const SizedBox(width: 12),
                Expanded(child: _buildEventCard(events[1])),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPublicEvents() {
    return FutureBuilder<List<BasicEvent>>(
      future: _publicEventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingContainer(340);
        } else if (snapshot.hasError) {
          return _buildErrorContainer('Failed to load public events', 340);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyContainer('No public events found', 340);
        }

        final events = snapshot.data!;
        return Column(
          children: [
            _buildEventCard(events[0]),
            if (events.length > 1) ...[
              const SizedBox(height: 12),
              _buildEventCard(events[1]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPrivateEvents() {
    return FutureBuilder<List<BasicEvent>>(
      future: _privateEventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingContainer(340);
        } else if (snapshot.hasError) {
          return _buildErrorContainer('Failed to load private events', 340);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyContainer('No private events found', 340);
        }

        final events = snapshot.data!;
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildEventCard(events[0])),
                if (events.length > 1) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _buildEventCard(events[1])),
                ],
              ],
            ),
            if (events.length > 2) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildEventCard(events[2])),
                  if (events.length > 3) ...[
                    const SizedBox(width: 12),
                    Expanded(child: _buildEventCard(events[3])),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEventCard(BasicEvent event) {
    return EventCard(
      imageData: event.coverImage?.data,
      eventName: event.title,
      location: event.location ?? 'Location TBA',
      date: event.startDate,
      height: 160,

      //TODO: fix this
      isPaid: event.isPaid,
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => EventDetailsScreen(eventId: event.id),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    );
  }

  Widget _buildCategoryChips() {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load categories',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'No categories found',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        }

        final categories = snapshot.data!;
        categories.sort((a, b) => a.name.length.compareTo(b.name.length));
        return Center(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: categories
                .map((category) => _buildCategoryChip(category))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => CategoryEventsScreen(
              categoryId: category.id,
              categoryName: category.name,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF5B7CF6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          category.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContainer(double height) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorContainer(String message, double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _loadData();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContainer(String message, double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Results',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        if (_isSearchLoading)
          _buildLoadingContainer(200)
        else if (_searchResults.isEmpty)
          _buildEmptyContainer('No events found', 200)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildEventCard(_searchResults[index]);
            },
          ),
      ],
    );
  }
}
