// user_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/chat_services/chat_service.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';


class UserChatScreen extends StatefulWidget {
  final String organizerId;

  const UserChatScreen({Key? key, required this.organizerId}) : super(key: key);

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final UserOrganizerProfileService _profileService = UserOrganizerProfileService();
  String? _chatRoomId;
  
  @override
  void initState() {
    super.initState();
    _initializeChatRoom();
  }

  Future<void> _initializeChatRoom() async {
    try {
      final chatRoomId = await _chatService.createChatRoom(widget.organizerId);
      setState(() {
        _chatRoomId = chatRoomId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing chat: $e')),
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _chatRoomId == null) return;

    _chatService.sendMessage(
      chatRoomId: _chatRoomId!,
      receiverId: widget.organizerId,
      content: _messageController.text.trim(),
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<OrganizerProfile?>(
          future: _profileService.fetchOrganizerProfile(widget.organizerId),
          builder: (context, snapshot) {
            return Text(
              snapshot.data?.name ?? 'Organizer Chat',
              style: TextStyle(fontSize: 18),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatRoomId == null
                ? Center(child: CircularProgressIndicator())
                : StreamBuilder(
                    stream: _chatService.getMessages(_chatRoomId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No messages yet'));
                      }

                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final message = snapshot.data![index];
                          final isCurrentUser = 
                              message.senderId == FirebaseAuth.instance.currentUser?.uid;

                          return Align(
                            alignment: isCurrentUser 
                              ? Alignment.centerRight 
                              : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCurrentUser 
                                  ? Colors.blue[100] 
                                  : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(message.content),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}