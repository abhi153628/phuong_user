import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:phuong/view/chat_section/chat_listing_screen/chat_list_bloc/chat_listing_bloc.dart';
import 'package:phuong/view/chat_section/chat_listing_screen/chat_list_bloc/chat_listing_event.dart';
import 'package:phuong/view/chat_section/chat_listing_screen/chat_list_bloc/chat_listing_state.dart';
import 'package:phuong/view/chat_section/chat_view_screen.dart';
import 'package:phuong/view/event_organizer_view_page/event_organizer_view_page.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class UserChatListScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        chatService: ChatService(),
        profileService: UserOrganizerProfileService(),
      )..add(LoadChats()),
      child: _UserChatListView(searchController: _searchController),
    );
  }
}

class _UserChatListView extends StatelessWidget {
  final TextEditingController searchController;

  const _UserChatListView({
    Key? key,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatInitial || state is ChatLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.activeGreen),
              );
            }

            if (state is ChatError) {
              return Center(
                child: Text(
                  state.message,
                  style: GoogleFonts.notoSans(color: Colors.red),
                ),
              );
            }

            if (state is ChatLoaded) {
              return Column(
                children: [
                  _buildHeader(),
                  _buildOrganizerAvatars(state.filteredOrganizers),
                  _buildSearchBar(context),
                  Expanded(
                    child: _buildChatList(state.chatRooms),
                  ),
                ],
              );
            }

            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 20),
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

  Widget _buildSearchBar(BuildContext context) {
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
        controller: searchController,
        style: GoogleFonts.notoSans(color: Colors.white),
        onChanged: (query) {
          context.read<ChatBloc>().add(SearchChats(query));
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search chats...',
          hintStyle: GoogleFonts.notoSans(color: Colors.grey[600]),
          icon: Icon(Icons.search, color: AppColors.activeGreen),
        ),
      ),
    );
  }

  Widget _buildOrganizerAvatars(List<OrganizerProfile> organizers) {
    return Container(
      height: 90,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: organizers.length,
        itemBuilder: (context, index) {
          return _buildOrganizerAvatar(context, organizers[index]);
        },
      ),
    );
  }

  Widget _buildOrganizerAvatar(
      BuildContext context, OrganizerProfile organizer) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Hero(
            tag: 'avatar_${organizer.id}',
            child: GestureDetector(
              onTap: () {
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

  Widget _buildChatList(Stream<List<ChatRoom>> chatRooms) {
    return StreamBuilder<List<ChatRoom>>(
      stream: chatRooms,
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
            return _buildChatTile(context, snapshot.data![index]);
          },
        );
      },
    );
  }

  Widget _buildChatTile(BuildContext context, ChatRoom chatRoom) {
    return FutureBuilder<OrganizerProfile?>(
      future: UserOrganizerProfileService()
          .fetchOrganizerProfile(chatRoom.organizerId),
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
  final DateTime dateTime = timestamp.toDate().toLocal();
  final DateTime now = DateTime.now();

  final String dayOfWeek = DateFormat('EEE').format(dateTime);
  final String time = DateFormat('hh:mm a').format(dateTime);

  if (now.difference(dateTime).inDays == 0) {
    return '$dayOfWeek $time';
  } else if (now.difference(dateTime).inDays < 7) {
    return '$dayOfWeek $time';
  } else {
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  }
}

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