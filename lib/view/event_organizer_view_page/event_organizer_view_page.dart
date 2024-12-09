import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';


class UserOrganizerProfileScreen extends StatefulWidget {
  final String organizerId;

  const UserOrganizerProfileScreen({
    Key? key,
    required this.organizerId,
  }) : super(key: key);

  @override
  State<UserOrganizerProfileScreen> createState() =>
      _UserOrganizerProfileScreenState();
}

class _UserOrganizerProfileScreenState extends State<UserOrganizerProfileScreen> {
  late final UserOrganizerProfileService _profileService;
  OrganizerProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {  _profileService = UserOrganizerProfileService();
  log('data calling from screen page');
    _fetchOrganizerProfile();
    super.initState();
  
  }

  Future<void> _fetchOrganizerProfile() async {
    try {
      log('data calling from screen page 1');
      log(widget.organizerId);
      final profile = await _profileService.fetchOrganizerProfile(widget.organizerId);
      log('Profile fetched successfully: $profile');
      print('object');
      if (profile != null) {
  if (profile.name != null) log('Profile name: ${profile.name}');
  if (profile.links != null) log('Profile links: ${profile.links}');
} else {
  log('Profile is null');
}
          // 
        //  log('data printing from screen profil image ${_profile!.imageUrl}'); 
        //  log('data printing from screen profil image ${_profile!.links}');
         log('data calling from screen page 2');
      if (mounted) {
        if(profile?.name!=null&&profile?.links!=null){
          
          _profile = profile;
          _isLoading = false;
        }
        setState(() {

        });
      }
    } catch (apiError) {
      log('kooi');
      log('data calling from screen page 3 $apiError');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching organizer profile: $apiError')),
        );
        throw apiError;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
// return Scaffold(
  // body: Column(
  //   children: [
  //     Text(_profile?.name??'___'),


  //   ],
  // ),
// );

      // return const Scaffold(
      //   body: Center(
      //     child: CircularProgressIndicator(),
      //   ),
      // );
    //}

   

    return Scaffold(
      appBar: AppBar(
        title: Text(_profile!.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_profile?.imageUrl != null)
            Center(
              child: ClipOval(
                child: Image.network(
                  _profile!.imageUrl!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 16.0),
          Text(
            _profile!.name??"__",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          if (_profile!.bio != null) Text(_profile!.bio!),
          const SizedBox(height: 16.0),
          if (_profile!.links != null && _profile!.links!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Links:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                ..._profile!.links!.map((link) => Text(link)),
              ],
            ),
          const SizedBox(height: 16.0),
          Text(
            'Posts (${_profile!.posts?.length ?? 0}):',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8.0),
          if (_profile!.posts != null && _profile!.posts!.isNotEmpty)
            Column(
              children: _profile!.posts!.map((post) => _PostWidget(post)).toList(),
            )
          else
            const Text('No posts found'),
        ],
      ),
    );
  }
}

class _PostWidget extends StatelessWidget {
  final Post post;

  const _PostWidget(this.post, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            post.imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(post.description),
        const SizedBox(height: 8.0),
        Text(
          'Posted on ${post.createdAt.toString()}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Divider(),
      ],
    );
  }
}










