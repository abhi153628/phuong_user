import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/chat_modal.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/chat_services/chat_service.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/event_organizer_view_page/event_organizer_view_page.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';


class UserChatScreen extends StatefulWidget {
  final String organizerId;
  final OrganizerProfile? organizerProfile;

  const UserChatScreen({Key? key, required this.organizerId, this.organizerProfile }) : super(key: key);

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final UserOrganizerProfileService _profileService = UserOrganizerProfileService();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _animationController;
  late Animation<double> _sendButtonAnimation;
  
  String? _chatRoomId;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
     if (widget.organizerProfile != null) {
  } else {
    _fetchOrganizerProfile();
  }
    _initializeChatRoom();
    _setupAnimations();
    _messageController.addListener(_onTypingChanged);
  }

Future<void> _fetchOrganizerProfile() async {
  try {
    final profile = await _profileService.fetchOrganizerProfile(widget.organizerId);
    if (profile != null) {
      setState(() {
      });
    } else {
      // Handle case where profile can't be fetched
      _showErrorSnackBar('Could not fetch organizer profile');
      // Optionally, create a placeholder profile or handle the error
    }
  } catch (e) {
    _showErrorSnackBar('Error fetching organizer profile: $e');
    // Optionally, create a placeholder profile or handle the error
  }
}

  Future<void> _initializeChatRoom() async {
    try {
      final chatRoomId = await _chatService.createChatRoom(widget.organizerId);
      setState(() {
        _chatRoomId = chatRoomId;
      });
    } catch (e) {
      _showErrorSnackBar('Error initializing chat: $e');
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onTypingChanged() {
    final isTyping = _messageController.text.isNotEmpty;
    if (_isTyping != isTyping) {
      setState(() => _isTyping = isTyping);
      isTyping ? _animationController.forward() : _animationController.reverse();
    }
  }

  void _sendMessage() {
    final trimmedMessage = _messageController.text.trim();
    if (trimmedMessage.isEmpty || _chatRoomId == null) return;

    _chatService.sendMessage(
      chatRoomId: _chatRoomId!,
      receiverId: widget.organizerId,
      content: trimmedMessage,
    );

    _messageController.clear();
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

   void _showDeleteMessageDialog(ChatMessage message) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCurrentUserSender = message.senderId == currentUserId;

    // If the message is not sent by the current user, show a snackbar
 if (!isCurrentUserSender) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can only delete messages you have sent.',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: Duration(seconds: 2), // Reduced visibility duration
  
    ),
  );
  return;
}


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Message',
          style: GoogleFonts.syne(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeleteOption(
              icon: Icons.delete_forever,
              text: 'Delete for everyone',
              onTap: () {
                _chatService.deleteMessageForEveryone(_chatRoomId!, message);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.notoSans(
                color: AppColors.activeGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDeleteOption({
    required IconData icon, 
    required String text, 
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon, 
        color: red,
      ),
      title: Text(
        text,
        style: GoogleFonts.notoSans(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(onTap: () => Navigator.of(context).push(GentlePageTransition(page: OrganizerProfileViewScreen(organizerId: widget.organizerId,))),child: _buildOrganizerTitle()),
     
    
    );
  }

 Widget _buildOrganizerTitle() {
  return StreamBuilder<List<ChatMessage>>(
    stream: _chatRoomId != null ? _chatService.getMessages(_chatRoomId!) : null,
    builder: (context, messageSnapshot) {
      return FutureBuilder<OrganizerProfile?>(
        future: _profileService.fetchOrganizerProfile(widget.organizerId),
        builder: (context, profileSnapshot) {
          if (!profileSnapshot.hasData) return const SizedBox.shrink();
          
          // Get the last message timestamp if available
          Timestamp? lastMessageTimestamp;
          if (messageSnapshot.hasData && messageSnapshot.data!.isNotEmpty) {
            lastMessageTimestamp = messageSnapshot.data!.first.timestamp;
          }

          return Row(
            children: [
              Hero(
                tag: 'avatar_${widget.organizerId}',
                child: _buildProfileAvatar(profileSnapshot.data!.imageUrl),
              ),
              const SizedBox(width: 12),
              _buildOrganizerDetails(profileSnapshot.data!, lastMessageTimestamp),
            ],
          );
        },
      );
    },
  );
}

  Widget _buildProfileAvatar(String imageUrl) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white.withOpacity(0.5), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLoadingPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: CircularProgressIndicator(
                          color: grey,
                        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Icon(Icons.person, color: Colors.grey);
  }

Widget _buildOrganizerDetails(OrganizerProfile profile, Timestamp? lastSeenTimestamp) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        profile.name,
        style: GoogleFonts.syne(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        lastSeenTimestamp != null 
          ? _formatLastSeen(lastSeenTimestamp)
          : 'Offline',
        style: GoogleFonts.notoSans(
          color: AppColors.activeGreen,
          fontSize: 12,
        ),
      ),
    ],
  );
}
String _formatLastSeen(Timestamp timestamp) {
  final DateTime lastSeen = timestamp.toDate().toUtc().add(const Duration(hours: 5, minutes: 30)); // Convert to IST
  final DateTime now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)); // Ensure now is also in IST
  final difference = now.difference(lastSeen);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return 'Last seen ${difference.inMinutes} min ago';
  } else if (difference.inHours < 24) {
    return 'Last seen ${difference.inHours} hr ago';
  } else {
    return DateFormat('dd/MM/yyyy').format(lastSeen); // Format in IST
  }
}


  void _showChatOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.clear_all, color: AppColors.activeGreen),
              title: Text('Clear Chat', style: GoogleFonts.notoSans()),
              onTap: () {
                // Implement clear chat functionality
                Navigator.pop(context);
              },
            ),
            // Add more options as needed
          ],
        ),
      ),
    );
  }
  

  Widget _buildMessageList() {
    return _chatRoomId == null
        ? Center(
            child: Lottie.asset('assets/animations/Animation - 1736144056346.json',height: 170,width: 170),
          )
        : StreamBuilder<List<ChatMessage>>(
            stream: _chatService.getMessages(_chatRoomId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Lottie.asset('assets/animations/Animation - 1736144056346.json',height: 170,width: 170),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'Start a conversation',
                    style: GoogleFonts.notoSans(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final message = snapshot.data![index];
                  return _buildMessageBubble(message);
                },
              );
            },
          );
  }

    
  Widget _buildMessageBubble(ChatMessage message) {
    final isCurrentUser = message.senderId == FirebaseAuth.instance.currentUser?.uid;

    return GestureDetector(
      onLongPress: () => _showDeleteMessageDialog(message),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppColors.activeGreen.withOpacity(0.1)
                  : Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrentUser
                    ? AppColors.activeGreen.withOpacity(0.1)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: isCurrentUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: GoogleFonts.notoSans(
                    color: isCurrentUser ? AppColors.activeGreen : Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.timestamp),
                  style: GoogleFonts.notoSans(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatMessageTime(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
           
            Expanded(
              child: _buildMessageTextField(),
            ),
            const SizedBox(width: 8),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

Widget _buildMessageTextField() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: AppColors.activeGreen.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _messageController,
                  builder: (context, value, child) {
                    // Show the animation only if the TextField is empty
                    if (value.text.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                        child: AnimatedTextKit(
                          repeatForever: false,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Type a message...',
                              textStyle: GoogleFonts.notoSans(color: Colors.grey),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      );
                    }
                    return const SizedBox.shrink(); // Empty space when text is entered
                  },
                ),
              ),
              TextField(
                controller: _messageController,
                style: GoogleFonts.notoSans(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '',
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  

  Widget _buildSendButton() {
    return ScaleTransition(
      scale: _sendButtonAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.activeGreen,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.send, color: Colors.white, size: 20),
          onPressed: _sendMessage,
        ),
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _animationController.dispose();
    _scrollController.dispose();}}