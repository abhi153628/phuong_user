import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:phuong/main.dart';
import 'package:phuong/modal/user_profile_modal.dart';
import 'package:phuong/services/user_profile_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/booked_events_page.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/social_feed/liked_post.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
        });
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String defaultName = user.email?.split('@').first ?? 'User';
          setState(() {
            _userName = defaultName;
            _nameController.text = defaultName;
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
      errorMessage = 'Please enable location services in your device settings';
    } else if (e.toString().contains('denied')) {
      errorMessage = 'Please grant location permission in your device settings';
    }
    _showErrorSnackBar(errorMessage);
  } finally {
    setModalState(() {
      _isUpdatingLocation = false;
    });
  }
}
  void _showEditProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
              children: [
                Text(
                  'Edit Profile',
                  style: GoogleFonts.syne(
                    color: AppColors.activeGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
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
                //! Location Section
                Container(width: 400,
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
                      Center(
                        child: Text(
                          _currentAddress ?? 'Location not set',
                          style: GoogleFonts.notoSans(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
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
                ),
                const SizedBox(height: 20),
                _isSaving
                    ? CircularProgressIndicator(
                        color: AppColors.activeGreen,
                      )
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
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
Future<void> _saveProfile(BuildContext context) async {
  final newName = _nameController.text.trim();
  if (newName.isEmpty) {
    _showErrorSnackBar('Name cannot be empty');
    return;
  }

  // Show loading dialog with circular progress indicator
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
                child: CircularProgressIndicator(
                  color: AppColors.activeGreen,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section with Updated Name
                    Container(
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
                      child: Row(
                        children: [
                          //! Circular avatar Icon Name
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.activeGreen,
                            child: Text(
                              _userName.isNotEmpty
                                  ? _userName[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.syne(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //! User Name
                                AnimatedTextKit(
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
                                  repeatForever: false,
                                  isRepeatingAnimation: false,
                                ),
                                //User location
                                Text(
                                  _currentAddress ?? 'Location not set',
                                  style: GoogleFonts.notoSans(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _showEditProfileBottomSheet,
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.activeGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    //! List of Function pages
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined,
                          color: AppColors.activeGreen),
                      title: Text(
                        'Notifications',
                        style: GoogleFonts.notoSans(color: Colors.white),
                      ),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppColors.activeGreen,
                      ),
                    ),

                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .push(GentlePageTransition(page: UserBookingsPage())),
                      //! booked events page
                      child: ListTile(
                          leading: const Icon(Icons.library_music,
                              color: AppColors.activeGreen),
                          title: Text(
                            'Booked Events',
                            style: GoogleFonts.notoSans(color: Colors.white),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios_outlined,
                              color: AppColors.activeGreen)),
                    ),
                    ListTile(
                        leading: const Icon(Icons.local_activity_outlined,
                            color: AppColors.activeGreen),
                        title: Text(
                          'Tickets',
                          style: GoogleFonts.notoSans(color: Colors.white),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_outlined,
                            color: AppColors.activeGreen)),
                            //
                            GestureDetector(
                                onTap: () => Navigator.of(context)
                          .push(GentlePageTransition(page: LikedPostsPage())),
                              child: ListTile(
                                                      leading: const Icon(Icons.local_activity_outlined,
                              color: AppColors.activeGreen),
                                                      title: Text(
                                                        'Liked ',
                                                        style: GoogleFonts.notoSans(color: Colors.white),
                                                      ),
                                                      trailing: Icon(Icons.arrow_forward_ios_outlined,
                              color: AppColors.activeGreen)),
                            ),

                    const Spacer(),

                    // Sign Out Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          // Navigate to login page
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[900],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        //! SignOut
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.syne(
                            color: AppColors.activeGreen,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
