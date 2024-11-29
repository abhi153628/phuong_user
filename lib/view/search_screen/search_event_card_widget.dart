import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/view/event_detail_screen/widgets/fields_event_details_widget.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsPage(event: event),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 120,
          
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          
          ),
          child: Row(
            children: [
              _buildEventImage(),
              Expanded(
                child: _buildEventInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius:BorderRadius.circular(20),
        child: event.imageUrl?.isNotEmpty == true
            ? CachedNetworkImage(
              //!  E V E N T   I M A G E
                imageUrl: event.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.white.withOpacity(0.3),
                      size: 30,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.error),
                ),
              )
            : Container(
                color: Colors.grey[900],
                child: Icon(
                  Icons.image,
                  color: Colors.white.withOpacity(0.3),
                  size: 30,
                ),
              ),
      ),
    );
  }

  Widget _buildEventInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //! E V E N T  N A M E
          Text(
            event.eventName ?? 'Untitled Event',
            style: GoogleFonts.syne(
              color: AppColors.activeGreen,
              fontSize: 20,
              fontWeight: FontWeight.w600,letterSpacing: 1
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white.withOpacity(0.7),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                event.time != null
                    ? '${event.time!.hour}:${event.time!.minute.toString().padLeft(2, '0')}'
                    : 'Time TBA',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withOpacity(0.7),
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.location ?? 'Location TBA',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
