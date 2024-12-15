import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/chat_modal.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/chat_services/chat_service.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/chat_section/chat_view_screen.dart';
import 'package:phuong/view/event_organizer_view_page/event_organizer_view_page.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class UserChatListScreen extends StatefulWidget {
  @override
  _UserChatListScreenState createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  final ChatService _chatService = ChatService();
  final UserOrganizerProfileService _profileService =
      UserOrganizerProfileService();
  final TextEditingController _searchController = TextEditingController();
  List<OrganizerProfile> _allOrganizers = [];
  List<OrganizerProfile> _filteredOrganizers = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizers();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadOrganizers() async {
    _allOrganizers = await _profileService.getAllOrganizers();
    setState(() {
      _filteredOrganizers = _allOrganizers;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrganizers = _allOrganizers
          .where((organizer) => organizer.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildOrganizerAvatars(),
            _buildSearchBar(),
            Expanded(
              child: _buildChatList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder(
      stream: _chatService.getUserChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.activeGreen),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No active chats',
              style: GoogleFonts.notoSans(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemBuilder: (context, index) {
            final chatRoom = snapshot.data![index];
            return _buildChatTile(chatRoom);
          },
        );
      },
    );
  }

 Widget _buildChatTile(ChatRoom chatRoom) {
  return FutureBuilder<OrganizerProfile?>( 
    future: _profileService.fetchOrganizerProfile(chatRoom.organizerId),
    builder: (context, profileSnapshot) {
      if (profileSnapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingTile();
      }

      if (!profileSnapshot.hasData || profileSnapshot.data == null) {
        return SizedBox.shrink();
      }

      final profile = profileSnapshot.data!;
      return Hero(
        tag: 'chat_${profile.id}',
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: grey, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: CachedNetworkImage(
                  imageUrl: profile.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            title: Text(
              profile.name,
              style: GoogleFonts.syne(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              chatRoom.lastMessage,
              style: GoogleFonts.notoSans(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimestamp(chatRoom.lastMessageTimestamp),
                  style: GoogleFonts.notoSans(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap to chat',
                  style: GoogleFonts.notoSans(
                    color: AppColors.activeGreen,
                    fontSize: 12,
                  ),
                )
              ],
            ),
            onTap: () => Navigator.of(context).push(
              GentlePageTransition(
                page: UserChatScreen(
                  organizerId: profile.id,
                  organizerProfile: profile,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Chats',
            style: GoogleFonts.syne(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
       
        ],
      ),
    );
  }

  Widget _buildOrganizerAvatars() {
    return Container(
      height: 90,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredOrganizers.length,
        itemBuilder: (context, index) {
          final organizer = _filteredOrganizers[index];
          return _buildOrganizerAvatar(organizer);
        },
      ),
    );
  }

  Widget _buildOrganizerAvatar(OrganizerProfile organizer) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 6),
    child: Column(
      children: [
        Hero(
          tag: 'avatar_${organizer.id}',
          child: GestureDetector(
            onTap: () {
              // Navigate to Organizer Details Page
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UserOrganizerProfileScreen(
                    organizerId: organizer.id,
                    
                  ),
                ),
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: grey,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.activeGreen.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: CachedNetworkImage(
                  imageUrl: organizer.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: grey,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          organizer.name,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.activeGreen.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.notoSans(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search chats...',
          hintStyle: GoogleFonts.notoSans(color: Colors.grey[600]),
          icon: Icon(Icons.search, color: AppColors.activeGreen),
        ),
      ),
    );
  }

  Widget _buildLoadingTile() {
    return ListTile(
      leading: ShimmerWidget(
        width: 56,
        height: 56,
        borderRadius: 28,
      ),
      title: ShimmerWidget(
        width: double.infinity,
        height: 16,
        borderRadius: 8,
      ),
      subtitle: ShimmerWidget(
        width: 100,
        height: 14,
        borderRadius: 8,
      ),
    );
  }


}

String _formatTimestamp(Timestamp timestamp) {
  final DateTime dateTime =
      timestamp.toDate().toLocal(); // Ensure local timezone
  final DateTime now = DateTime.now();

  final String dayOfWeek =
      DateFormat('EEE').format(dateTime); // Day of the week (e.g., Wed)
  final String time = DateFormat('hh:mm a')
      .format(dateTime); // Time in 12-hour format with AM/PM

  if (now.difference(dateTime).inDays == 0) {
    // Same day: return time only
    return '$dayOfWeek $time';
  } else if (now.difference(dateTime).inDays < 7) {
    // Less than a week ago: return day of the week and time
    return '$dayOfWeek $time';
  } else {
    // More than a week ago: return full date and time
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  }
}

// ... (previous ShimmerWidget class remains the same)
class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerWidget({
    required this.width,
    required this.height,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
