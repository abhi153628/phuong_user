import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:phuong/main.dart';
import 'package:phuong/modal/user_profile_modal.dart';
import 'package:phuong/services/user_profile_firebase_service.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserProfileService _userProfileService = UserProfileService();
  String _userName = 'User';
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

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
      if (userProfile != null && userProfile.name.isNotEmpty) {
        setState(() {
          _userName = userProfile.name;
          _nameController.text = userProfile.name;
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

  void _showEditNameBottomSheet() {
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
                  'Edit Profile Name',
                  style: GoogleFonts.syneMono(
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
                            onPressed: () => _saveUserName(context),
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

  Future<void> _saveUserName(BuildContext context) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _showErrorSnackBar('Name cannot be empty');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _userProfileService.updateUserProfile(
        UserProfile(name: newName, userId: ''),
      );

      // Immediately update the UI
      setState(() {
        _userName = newName;
      });

      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to update name: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
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
                                  key: ValueKey(
                                      _userName), 
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
                                Text(
                                  'Band Booking Member',
                                  style: GoogleFonts.notoSans(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _showEditNameBottomSheet,
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

                    ListTile(
                      leading: const Icon(Icons.library_music,
                          color: AppColors.activeGreen),
                      title: Text(
                        'Booked Events',
                        style: GoogleFonts.notoSans(color: Colors.white),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_outlined,color: AppColors.activeGreen
                      )
                    ),
                      ListTile(
                      leading: const Icon(Icons.local_activity_outlined,
                          color: AppColors.activeGreen),
                      title: Text(
                        'Tickets',
                        style: GoogleFonts.notoSans(color: Colors.white),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_outlined,color: AppColors.activeGreen
                      )
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
