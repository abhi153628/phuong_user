// event_service.dart
import 'package:flutter/material.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';

// Utility function to parse a time string (e.g., "14:30") into a TimeOfDay object
TimeOfDay timeOfDayFromString(String timeString) {
  final parts = timeString.split(":");
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  return TimeOfDay(hour: hour, minute: minute);
}

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({
    Key? key,
    required this.event,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              SizedBox(
                height: 200,
                width: double.infinity,
                child: event.imageUrl?.isNotEmpty == true
                    ? Image.network(
                        event.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventName ?? 'Untitled Event',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (event.organizerName?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        'By ${event.organizerName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (event.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (event.location?.isNotEmpty == true)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Expanded(child: Text(event.location!)),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          event.date != null
                              ? '${event.date!.day}/${event.date!.month}/${event.date!.year}'
                              : 'Date TBA',
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          event.time != null
                              ? '${event.time!.hour}:${event.time!.minute.toString().padLeft(2, '0')}'
                              : 'Time TBA',
                        ),
                      ],
                    ),
                    if (event.eventDurationTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.timelapse, size: 16),
                          const SizedBox(width: 4),
                          Text('Duration: ${event.eventDurationTime} hours'),
                        ],
                      ),
                    ],
                    if (event.ticketPrice != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Ticket Price: \$${event.ticketPrice!.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                    if (event.seatAvailabilityCount != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event_seat, size: 16),
                          const SizedBox(width: 4),
                          Text(
                              'Available Seats: ${event.seatAvailabilityCount!.toInt()}'),
                        ],
                      ),
                    ],
                    if (event.genreType?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.category, size: 16),
                          const SizedBox(width: 4),
                          Text('Genre: ${event.genreType}'),
                        ],
                      ),
                    ],
                    // Social Media Links
                    if (event.instagramLink?.isNotEmpty == true ||
                        event.facebookLink?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (event.instagramLink?.isNotEmpty == true)
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () {
                                // Add Instagram link handling
                              },
                            ),
                          if (event.facebookLink?.isNotEmpty == true)
                            IconButton(
                              icon: const Icon(Icons.facebook),
                              onPressed: () {
                                // Add Facebook link handling
                              },
                            ),
                        ],
                      ),
                    ],
                    // Event Rules Preview
                    if (event.eventRules?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      ExpansionTile(
                        title: const Text('Event Rules'),
                        children: event.eventRules!
                            .map((rule) => ListTile(
                                  leading: const Icon(Icons.rule),
                                  title: Text(rule),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  late Future<List<EventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _eventService.getEvents();
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _eventsFuture = _eventService.getEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEvents,
        child: FutureBuilder<List<EventModel>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No events found'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                return EventCard(
                  event: event,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
