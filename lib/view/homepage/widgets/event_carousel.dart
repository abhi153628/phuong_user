import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/event_detail_screen/widgets/fields_event_details_widget.dart';
import 'package:phuong/view/new_event_detailed_page.dart';
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
        setState(() {
          _cachedEvents = events
            ..sort((a, b) =>
                (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
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
            'No events found',
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
//! N A V I G A T I O N = E V E N T   D E T A I L   P A G E
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                GentlePageTransition(
                  page:EventDetailsPage(event: event), 
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
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.7),
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
                    width: 200,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 90,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[100]!,
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: pageOffset * 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, pageOffset * 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(-30 * pageOffset, 0),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
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
                  Text(
                    event.eventName ?? 'No name',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
