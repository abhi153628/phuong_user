import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';

import 'package:phuong/view/homepage/search_bar.dart';
import 'package:phuong/view/homepage/widgets/category_button.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/homepage/widgets/home_event_card.dart';

import 'package:phuong/view/homepage/widgets/event_carousel.dart';

import 'package:phuong/view/search_screen/search_design.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  int _selectedCategory = 0;
  final List<String> categories = ['My feed', 'Rock', 'Classical', 'Pop', 'Jazz'];
  final ScrollController _scrollController = ScrollController();
  bool _isSearchBarSticky = false;
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;

  // Events and loading state
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  bool _isLoading = true;
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _searchBarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    // Fetch events when screen initializes
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch all events
      _allEvents = await _eventService.getEvents();
      
      // Initially show all events or apply default filter
      _filterEvents();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching events: $e')),
      );
    }
  }

  void _filterEvents() {
    setState(() {
      // Filter logic based on selected category
      switch (_selectedCategory) {
        case 0: 
          _filteredEvents = _allEvents;
          break;
        case 1: 
          _filteredEvents = _allEvents.where((event) => event.genreType == 'Rock').toList();
          break;
        case 2: 
          _filteredEvents = _allEvents.where((event) => event.genreType == 'Classical').toList();
          break;
        case 3: 
          _filteredEvents = _allEvents.where((event) => event.genreType == 'Pop').toList();
          break;
        case 4: 
          _filteredEvents = _allEvents.where((event) => event.genreType == 'Jazz').toList();
          break;
        default:
          _filteredEvents = _allEvents;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 150 && !_isSearchBarSticky) {
      setState(() => _isSearchBarSticky = true);
      _animationController.forward();
    } else if (_scrollController.offset <= 150 && _isSearchBarSticky) {
      setState(() => _isSearchBarSticky = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Top Section with Gradient
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF424f51), Color(0xFF26344c)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      height: 280,
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 15),
                          _buildCategories(),
                          const SizedBox(height: 15),
                          if (!_isSearchBarSticky) 
                            const SearchBarHomeScreen(),
                        ],
                      ),
                    ),
                  ],
                ),

                // Upcoming Events Section
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Upcoming Events',
                          style: GoogleFonts.syne(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 210, 226, 174),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const EventsCarousel(),
                    ],
                  ),
                ),

                // Nearby Events Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby Events',
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 210, 226, 174),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Loading or No Events Handling
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredEvents.isEmpty
                              ? Center(
                                  child: Text(
                                    'No events found in this category',
                                    style: GoogleFonts.syne(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _filteredEvents.map((event) {
                                    return Column(
                                      children: [
                                        HomeEventCard(event: event),
                                        const SizedBox(height: 20),
                                      ],
                                    );
                                  }).toList(),
                                ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky Search Bar with enhanced animation
          AnimatedBuilder(
            animation: _searchBarAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _isSearchBarSticky 
                  ? 0 
                  : -100 * (1 - _searchBarAnimation.value)),
                child: Container(
                  color: Colors.transparent,
                  child: SafeArea(
                    bottom: false,
                    child: Opacity(
                      opacity: _searchBarAnimation.value,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomSearchBar(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Other existing methods remain the same (_buildHeader(), _buildCategories())
   Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Discover',
              style: GoogleFonts.syne(
                color: white,
                fontSize: 33,
              )),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: white,
                    ),
                    borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.wifi_tethering,
                        color: AppColors.white,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: AppColors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          categories.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CategoryButton(
              text: categories[index],
              isActive: _selectedCategory == index,
              onTap: () {
                setState(() => _selectedCategory = index);
                _filterEvents(); // Apply filter when category changes
              },
            ),
          ),
        ),
      ),
    );
  }
}