import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/event_detail_screen/widgets/fields_event_details_widget.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class EventsCarousel extends StatefulWidget {
  const EventsCarousel({Key? key}) : super(key: key);

  @override
  State<EventsCarousel> createState() => _EventsCarouselState();
}

class _EventsCarouselState extends State<EventsCarousel> {
  late Future<List<EventModel>> _eventsFuture;
  final EventService _eventService = EventService();
  late PageController _pageController;
  double _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _isLoading = true;
  List<EventModel> _cachedEvents = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85)
      ..addListener(_onPageChanged);
    _loadEvents();
  }

  void _onPageChanged() {
    if (mounted) {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    }
  }

  Future<void> _loadEvents() async {
    try {
      setState(() => _isLoading = true);
      final events = await _eventService.getEvents();
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          // Filter out past events and sort by newest date first
          _cachedEvents = events
              .where((event) => 
                  event.date != null && 
                  event.date!.isAfter(now.subtract(const Duration(days: 1))))
              .toList()
            ..sort((a, b) => 
                (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
          _isLoading = false;
        });
        _setupAutoScroll();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setupAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _cachedEvents.isNotEmpty) {
        final nextPage = (_currentPage + 1) % _cachedEvents.length;
        _pageController.animateToPage(
          nextPage.toInt(),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_cachedEvents.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(
          child: Text(
            'No upcoming events',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _cachedEvents.length,
        itemBuilder: (context, index) {
          final event = _cachedEvents[index];
          double difference = (index - _currentPage).abs().clamp(0.0, 1.0);
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                GentlePageTransition(
                  page: EventDetailsPage(event: event),
                ),
              );
            },
            child: ParallaxEventCard(
              event: event,
              pageOffset: difference,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ShimmerEventCard(),
          );
        },
      ),
    );
  }
}

class ShimmerEventCard extends StatelessWidget {
  const ShimmerEventCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Shimmer.fromColors(
        period: const Duration(milliseconds: 1500),
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey[900]!,
                        Colors.grey[800]!,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 240,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).shimmer(duration: 1500.ms);
  }
}

class ParallaxEventCard extends StatelessWidget {
  final EventModel event;
  final double pageOffset;

  const ParallaxEventCard({
    Key? key,
    required this.event,
    required this.pageOffset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: pageOffset * 20,
      ),
      // height: 260, // Fixed height instead of responsive
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, pageOffset * 10),
                blurRadius: 15,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image with Parallax
              Transform.translate(
                offset: Offset(-30 * pageOffset, 0),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ShimmerEventCard(),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: Icon(Icons.error_outline,
                        color: Colors.red[400], size: 32),
                  ),
                ),
              ),

              // Date Container (Top Right)
              Positioned(
                top: 16,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 4, bottom: 4, left: 12, right: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.activeGreen.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            event.date != null
                                ? DateFormat('dd').format(event.date!)
                                : '--',
                            style: GoogleFonts.notoSans(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            event.date != null
                                ? DateFormat('MMM').format(event.date!)
                                : '---',
                            style: GoogleFonts.syne(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Gradient
              Positioned(
                bottom: -0.99,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                  //  Content

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 1,
                        sigmaY: 3,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (event.eventName != null &&
                                      event.eventName!.isNotEmpty)
                                  ? '${event.eventName![0].toUpperCase()}${event.eventName!.substring(1)}'
                                  : 'No name',
                              style: GoogleFonts.syne(
                                color: AppColors.activeGreen,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.white70,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                event.location ?? 'No location',
                                                style: GoogleFonts.syne(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                                if (event.ticketPrice != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.activeGreen
                                            .withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      formatter.format(event.ticketPrice),
                                      style: GoogleFonts.syne(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}
