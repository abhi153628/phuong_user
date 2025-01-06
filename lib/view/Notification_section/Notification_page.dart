import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phuong/view/Notification_section/compensation_ticket_section/compensation_page.dart';
import 'package:phuong/services/user_profile_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/Notification_section/widgets/bottom_sheet_notification_deletion.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_animate/flutter_animate.dart';

String get userId {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('No authenticated user found');
  }
  return user.uid;
}

class NotificationPage extends StatelessWidget {
  final UserProfileService _userProfileService = UserProfileService();

  NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: GoogleFonts.syne(
              color: AppColors.white, // Neon green
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, // iOS-style back arrow
            color: Colors.white, // Set icon color to black for visibility
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
          actions: [
            
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.activeGreen),
              onPressed: () {
                // Add pull-to-refresh animation
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        NotificationPage(),
                    transitionDuration: Duration(milliseconds: 500),
                    reverseTransitionDuration: Duration(milliseconds: 500),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: NotificationList(userProfileService: _userProfileService),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final UserProfileService userProfileService;

  const NotificationList({
    Key? key,
    required this.userProfileService,
  }) : super(key: key);

  Stream<QuerySnapshot> _getNotifications() {
    return FirebaseFirestore.instance
        .collection('userNotifications')
        .where('userId', isEqualTo: userProfileService.userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('userNotifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Widget _buildNotificationIcon(String type, bool isRead) {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (type) {
      case 'event_cancellation':
        iconData = Icons.event_busy;
        iconColor = isRead ? Colors.grey : Colors.red;
        backgroundColor =
            isRead ? Colors.grey.withOpacity(0.1) : Colors.red.withOpacity(0.1);
        break;
      default:
        iconData = Icons.notifications;
        iconColor = isRead ? Colors.grey : AppColors.activeGreen;
        backgroundColor = isRead
            ? Colors.grey.withOpacity(0.1)
            : AppColors.activeGreen.withOpacity(0.1);
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: [
          if (!isRead)
            BoxShadow(
              color: iconColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getNotifications(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'Error loading notifications',
                  style: GoogleFonts.notoSans(color: Colors.grey),
                ),
              ],
            ),
          ).animate().fadeIn(duration: Duration(milliseconds: 500));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child:Lottie.asset('assets/animations/Animation - 1736144056346.json',height: 170,width: 170)
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined,
                    color: Colors.grey, size: 48),
                SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: GoogleFonts.notoSans(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: Duration(milliseconds: 500));
        }

        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final notification = snapshot.data!.docs[index];
            final data = notification.data() as Map<String, dynamic>;

            final isRead = data['isRead'] ?? false;
            final type = data['type'] ?? 'default';
            final title = data['title'] ?? 'Notification';
            final message = data['message'] ?? '';
            final eventName = data['eventName'] ?? 'Unknown Event';
            final bookingId = data['bookingId'] ?? 'Unknown Booking Id';

            final timestamp = data['timestamp'];
            final double amount = (data['totalAmount'] as num).toDouble();
            final int seats = (data['seatsBooked'] as num).toInt();

            return Dismissible(
              key: Key(notification.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red.withOpacity(0.8),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => ConfirmDeleteSheet(
                    onConfirm: () async {
                      Navigator.pop(context);
                      await FirebaseFirestore.instance
                          .collection('userNotifications')
                          .doc(notification.id)
                          .delete();
                    },
                    onCancel: () => Navigator.pop(context),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[900],
                elevation: isRead ? 0 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isRead
                        ? Colors.transparent
                        : AppColors.activeGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    _markAsRead(notification.id).then(
                      (value) => Navigator.of(context).push(
                        GentlePageTransition(
                          page: CompensationPage(
                            bookingId: bookingId,
                            eventName: eventName,
                            seatsBooked: seats,
                            totalAmount: amount,
                            timestamp: (timestamp as Timestamp).toDate(),
                          ),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNotificationIcon(type, isRead),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: GoogleFonts.syne(
                                        fontWeight: isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                        color: isRead
                                            ? Colors.grey
                                            : AppColors.activeGreen,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppColors.activeGreen,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.activeGreen
                                                .withOpacity(0.3),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                message,
                                style: GoogleFonts.notoSans(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                timeago.format(timestamp.toDate()),
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: Colors.grey[500],
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
            ).animate().fadeIn(duration: Duration(milliseconds: 500)).slideX(
                  begin: 0.2,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
          },
        );
      },
    );
  }
}
