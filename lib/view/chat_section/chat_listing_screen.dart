// user_chat_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/chat_services/chat_service.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/view/chat_section/chat_view_screen.dart';

class UserChatListScreen extends StatelessWidget {
  final ChatService _chatService = ChatService();
  final UserOrganizerProfileService _profileService =
      UserOrganizerProfileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Chats'),
      ),
      body: StreamBuilder(
        stream: _chatService.getUserChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No active chats'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final chatRoom = snapshot.data![index];

              return FutureBuilder(
                future:
                    _profileService.fetchOrganizerProfile(chatRoom.organizerId),
                builder: (context, profileSnapshot) {
                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  return ListTile(
                    
                      title: FutureBuilder<OrganizerProfile?>(
                    future: _profileService
                        .fetchOrganizerProfile(chatRoom.organizerId),
                    builder: (BuildContext context,
                        AsyncSnapshot<OrganizerProfile?> profileSnapshot) {
                      if (profileSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Text('Loading...');
                      }

                      if (profileSnapshot.hasError ||
                          !profileSnapshot.hasData ||
                          profileSnapshot.data == null) {
                        return Text('Unknown Organizer');
                      }

                      // Successfully fetched organizer profile
                      final organizerProfile = profileSnapshot.data!;
                      return   ListTile(
          title: Text(organizerProfile.name),
          subtitle: Text('Tap to chat'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserChatScreen(
              organizerId: organizerProfile.id,
                ),
              ),
            );
          },
        );
      },
    )
                );  },
                  );});
                },
     ) );
            }
        
        }
     

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    if (now.difference(dateTime).inDays == 0) {
      // Today's messages
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(dateTime).inDays < 7) {
      // This week
      return [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ][dateTime.weekday - 1];
    } else {
      // Older messages
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

