import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/modal/user_profile_modal.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/services/user_profile_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/Notification_section/Notification_page.dart';
import 'package:phuong/view/homepage/search_bar.dart';
import 'package:phuong/view/homepage/widgets/category_button.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/homepage/widgets/home_event_card.dart';
import 'package:phuong/view/homepage/widgets/event_carousel/event_carousel.dart';
import 'package:phuong/view/search_screen/search_design.dart';


class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  final UserProfileService _userProfileService = UserProfileService();
  String? _userCurrentLocation;
  int _selectedCategory = 0;
  final List<String> categories = [
    'My feed',
    'Rock',
    'Classical',
    'Pop',
    'Jazz'
  ];
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
    _initializeLocationAndEvents();

    // Fetch events when screen initializes
    _fetchEvents();
  }

  Future<void> _initializeLocationAndEvents() async {
    await _getUserLocation();
    await _fetchEvents();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await _userProfileService.getCurrentLocation();
      if (position != null) {
        // Get the address (city/area) from coordinates
        final address = await _userProfileService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (address != null) {
          setState(() {
            _userCurrentLocation = address;
          });

          // Update user's location in Firestore
          final userProfile = UserProfile(
            userId: _userProfileService.userId,
            latitude: position.latitude,
            longitude: position.longitude,
            address: address,
            name: '',
          );

          await _userProfileService.updateUserProfile(userProfile);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
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

  Widget _buildSectionTitle() {
    // This is the single source of truth for the title
    String title = _selectedCategory == 0
        ? 'Nearby Events'
        : '${categories[_selectedCategory]} Events';

    return AnimatedTextKit(
      key: ValueKey(title),
      animatedTexts: [
        TypewriterAnimatedText(
          title, // Using the title here
          textStyle: GoogleFonts.syne(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 210, 226, 174),
          ),
          speed: const Duration(milliseconds: 50),
        ),
      ],
      totalRepeatCount: 1,
      displayFullTextOnTap: true,
      stopPauseOnTap: true,
    );
  }

 void _filterEvents() {
  setState(() {
    // Filter logic based on selected category
    switch (_selectedCategory) {
      case 0: // My feed category
        if (_userCurrentLocation != null) {
          // Split user location into individual words
          List<String> userLocationWords = _userCurrentLocation!
              .toLowerCase()
              .replaceAll(',', ' ')
              .split(' ')
              .where((word) => word.isNotEmpty)
              .toList();

          _filteredEvents = _allEvents.where((event) {
            if (event.location == null) return false;

            // Split event location into words
            List<String> eventLocationWords = event.location!
                .toLowerCase()
                .replaceAll(',', ' ')
                .split(' ')
                .where((word) => word.isNotEmpty)
                .toList();

            // Check if any word from user location matches any word from event location
            return userLocationWords.any((userWord) => eventLocationWords.any(
                (eventWord) =>
                    eventWord.contains(userWord) ||
                    userWord.contains(eventWord)));
          }).toList();

          // Only show "No events found" message if location is available AND no events are found
          if (_filteredEvents.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              toastMessage(
                context: context, 
                message: 'No events found in your area'
              );
            });
          }
        }
 
        else {
          _filteredEvents = _allEvents;
        }
        break;
      case 1:
        _filteredEvents = _allEvents
            .where((event) => event.genreType?.toLowerCase() == 'rock')
            .toList();
        break;
      case 2:
        _filteredEvents = _allEvents
            .where((event) => event.genreType?.toLowerCase() == 'classical')
            .toList();
        break;
      case 3:
        _filteredEvents = _allEvents
            .where((event) => event.genreType?.toLowerCase() == 'pop')
            .toList();
        break;
      case 4:
        _filteredEvents = _allEvents
            .where((event) => event.genreType?.toLowerCase() == 'jazz')
            .toList();
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
  if (_scrollController.offset <= 150 && _isSearchBarSticky) {
      setState(() => _isSearchBarSticky = false);
      _animationController.reverse();
    }
  }
   void toastMessage({
  required BuildContext context,
  required String message,
  IconData icon = Icons.info_outline,
  Color backgroundColor = const Color(0xFF87B321),
  Duration duration = const Duration(seconds: 2),
  String? actionLabel,
  VoidCallback? onActionPressed,
  double? screenWidth,
}) {

  screenWidth ??= MediaQuery.of(context).size.width;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Text(
              message,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSans(
                color: Colors.black,
                fontWeight: FontWeight.w700
              ),
            ),
          ),
        ],
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor.withOpacity(0.9),
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
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
                          FadeIn(
                             duration: Duration(milliseconds: 800),child: _buildCategories()),
                          const SizedBox(height: 15),
                          if (!_isSearchBarSticky)
                            if (!_isSearchBarSticky)
                              const SearchBarHomeScreen(), // Remove the GestureDetector here since it's handled within the SearchBarHomeScreen
                        ],
                      ),
                    ),
                  ],
                ),

                // Upcoming Events Section
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: FadeIn( duration: Duration(milliseconds: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, top: 15),
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
                        FadeIn( duration: Duration(milliseconds: 700),child: const EventsCarousel()),
                      ],
                    ),
                  ),
                ),

                // Nearby Events Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeIn( duration: Duration(milliseconds: 700),child: _buildSectionTitle()),
                      const SizedBox(height: 20),

                      // Loading or No Events Handling
                     _isLoading
    ? Center(
        child: Lottie.asset(
            'assets/animations/Animation - 1736144056346.json',
            height: 170,
            width: 170))
    : _filteredEvents.isEmpty
        ? Center(
            child: Text(
              _selectedCategory == 0
                  ? (_userCurrentLocation == null
                      ? 'Please enable location services to see nearby events'
                      : 'No events found in your area')
                  : 'No ${categories[_selectedCategory].toLowerCase()} events are currently available.',
              style: GoogleFonts.syne(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
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

          // Sticky Search Bar with enhanced animation
          AnimatedBuilder(
            animation: _searchBarAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    0,
                    _isSearchBarSticky
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
             ) ]
              )    
       ) ]
        ));
              
  }

  Widget _buildHeader() {
    return FadeIn(
      duration: Duration(milliseconds: 700),
      child: Padding(
        padding:
            EdgeInsets.only(top: 40, left: 15, right: 15), 
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, 
          children: [
            Text('Discover',
                style: GoogleFonts.syne(
                    color: white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2)),
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
                      Icons.bubble_chart,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      // navigate to ai chat section
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: AppColors.white),
                    onPressed: () {
                      Navigator.of(context)
                          .push(GentlePageTransition(page: NotificationPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
