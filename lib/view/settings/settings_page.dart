import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:phuong/main.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/modal/user_profile_modal.dart';
import 'package:phuong/services/user_profile_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/booked_events_page.dart';
import 'package:phuong/view/event_detail_screen/widgets/ph_no_authentication_botom_sheet.dart';
import 'package:phuong/view/homepage/homepage.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/saved_events/saved_events.dart';
import 'package:phuong/view/ticket_section/event_tickets.dart';
import 'package:phuong/view/social_feed/liked_post.dart';
import 'package:phuong/view/ticket_section/ticket_list.dart';
import 'package:shimmer/main.dart';

class SettingsPage extends StatefulWidget {
  EventModel? event;

  SettingsPage({Key? key, this.event}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserProfileService _userProfileService = UserProfileService();
  String _userName = 'User';
  String? _currentAddress = 'Location not set';
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUpdatingLocation = false;
  String? _userPhone;
  String? _userId; 

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    
  }
   Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProfile = await _userProfileService.getUserProfile();
      if (userProfile != null) {
        setState(() {
          _userName = userProfile.name;
          _nameController.text = userProfile.name;
          _currentAddress = userProfile.address ?? 'Location not set';
          _userPhone = userProfile.phoneNumber ?? 'Phone not set';
          _userId = userProfile.userId; // Store the user ID
        });
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String defaultName = user.email?.split('@').first ?? 'User';
          setState(() {
            _userName = defaultName;
            _nameController.text = defaultName;
            _userId = user.uid; // Store Firebase user ID as fallback
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLocation(StateSetter setModalState) async {
    setModalState(() {
      _isUpdatingLocation = true;
    });

    try {
      final position = await _userProfileService.getCurrentLocation();
      if (position == null) {
        _showErrorSnackBar('Unable to get current location');
        return;
      }

      final address = await _userProfileService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setModalState(() {
        _currentAddress = address ?? 'Location not found';
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      String errorMessage = 'Error updating location';
      if (e.toString().contains('disabled')) {
        errorMessage =
            'Please enable location services in your device settings';
      } else if (e.toString().contains('denied')) {
        errorMessage =
            'Please grant location permission in your device settings';
      }
      _showErrorSnackBar(errorMessage);
    } finally {
      setModalState(() {
        _isUpdatingLocation = false;
      });
    }
  }

void _showUpdatePhoneBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,

   
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    builder: (context) => PhoneAuthBottomSheet(
      onPhoneVerified: (String phoneNumber) {
        setState(() {
          _userPhone = phoneNumber;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    ),
  );
}



  Future<void> _saveProfile(BuildContext context) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _showErrorSnackBar('Name cannot be empty');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.activeGreen.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.activeGreen,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Updating Profile...',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Get current location data if available
      final position = await _userProfileService.getCurrentLocation();
      final address = position != null
          ? await _userProfileService.getAddressFromCoordinates(
              position.latitude,
              position.longitude,
            )
          : null;

      final userId = _userProfileService.userId; // Get the actual user ID

      await _userProfileService.updateUserProfile(
        UserProfile(
          name: newName,
          userId: userId,
          latitude: position?.latitude,
          longitude: position?.longitude,
          address: address ?? _currentAddress,
        ),
      );

      // Update UI
      setState(() {
        _userName = newName;
        if (address != null) _currentAddress = address;
      });

      // Close loading dialog
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close bottom sheet

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog on error
      Navigator.pop(context);
      _showErrorSnackBar('Failed to update profile: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.activeGreen),
              )
            : SingleChildScrollView( // Wrap with SingleChildScrollView to prevent overflow
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card
                      _buildProfileCard(),
                      const SizedBox(height: 30),
                      // Settings Options
                      _buildSettingsOptions(),
                      const SizedBox(height: 40),
                      // Sign Out Button
                      _buildSignOutButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.activeGreen.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar and Name Row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.activeGreen,
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                  style: GoogleFonts.syne(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // User Name with Animation
              Expanded(
                child: AnimatedTextKit(
                  key: ValueKey(_userName),
                  animatedTexts: [
                    TypewriterAnimatedText(
                      _userName,
                      textStyle: GoogleFonts.syne(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      speed: const Duration(milliseconds: 200),
                    ),
                  ],
                  totalRepeatCount: 1,
                  isRepeatingAnimation: false,
                ),
              ),
              // Edit Profile Button
              IconButton(
                onPressed: _showEditProfileBottomSheet,
                icon: const Icon(Icons.edit, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Location Information
          _buildInfoRow(
            Icons.location_on_outlined,
            'Location',
            _currentAddress ?? 'Location not set',
          ),
          
          const SizedBox(height: 15),
          
          // Phone Information
          _buildInfoRow(
            Icons.phone_outlined,
            'Phone',
            _userPhone ?? 'Phone not set',
            onEdit: _showUpdatePhoneBottomSheet,
          ),
        ],
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(IconData icon, String title, String value, {VoidCallback? onEdit}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.notoSans(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: AppColors.grey, size: 20),
          ),
      ],
    );
  }

  // Settings Options List
Widget _buildSettingsOptions() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          trailing: Switch(
            value: true,
            onChanged: (value) {},
            activeColor: AppColors.activeGreen,
          ),
        ),
        _buildSettingsTile(
          icon: Icons.library_music,
          title: 'Booked Events',
          onTap: () => Navigator.of(context)
              .push(GentlePageTransition(page: UserBookingsPage())),
        ),
        _buildSettingsTile(
          icon: Icons.local_activity_outlined,
          title: 'Tickets',
          onTap: ()=> Navigator.of(context)
              .push(GentlePageTransition(page: TicketListPage())),
        ),
        _buildSettingsTile(
          icon: Icons.favorite_outline,
          title: 'Liked Posts',
          onTap: () => Navigator.of(context)
              .push(GentlePageTransition(page: LikedPostsPage())),
        ),
        _buildSettingsTile(
          icon: Icons.save,
          title: 'Saved Events',
          onTap: () {
            if (_userId != null) {
              Navigator.of(context).push(
                GentlePageTransition(
                  page: SavedEventsPage(userId: _userId!),
                ),
              );
            } else {
              _showErrorSnackBar('Unable to load saved events. Please try again.');
            }
          },
        ),
      ],
    );
  }

  // Helper method to build settings tiles
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.grey),
      title: Text(
        title,
        style: GoogleFonts.notoSans(color: Colors.white),
      ),
      trailing: trailing ?? const Icon(
        Icons.arrow_forward_ios_outlined,
        color: AppColors.activeGreen,
        size: 20,
      ),
    );
  }

  // Sign Out Button
  Widget _buildSignOutButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DiscoverScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[900],
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Sign Out',
          style: GoogleFonts.syne(
            color: AppColors.activeGreen,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Modified Bottom Sheet
  void _showEditProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView( // Wrap with SingleChildScrollView
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.activeGreen.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.syne(
                          color: AppColors.activeGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Name TextField
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.notoSans(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Enter your name',
                        hintStyle: GoogleFonts.notoSans(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Location Section
                    _buildLocationSection(setModalState),
                    const SizedBox(height: 20),
                    // Action Buttons
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Location Section in Bottom Sheet
  Widget _buildLocationSection(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Location',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentAddress ?? 'Location not set',
            style: GoogleFonts.notoSans(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton.icon(
              onPressed: _isUpdatingLocation
                  ? null
                  : () => _updateLocation(setModalState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isUpdatingLocation
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.location_on, color: Colors.black),
              label: Text(
                _isUpdatingLocation ? 'Updating...' : 'Update Location',
                style: GoogleFonts.notoSans(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action Buttons in Bottom Sheet
  Widget _buildActionButtons(BuildContext context) {
    return _isSaving
        ? Center(child: CircularProgressIndicator(color: AppColors.activeGreen))
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.notoSans(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => _saveProfile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.activeGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.notoSans(color: Colors.black),
                ),
              ),
            ],
          );
  }
}