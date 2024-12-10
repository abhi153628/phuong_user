// organizer_profile_view_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:shimmer/shimmer.dart';

class UserOrganizerProfileScreen extends StatefulWidget {
  final String organizerId;

  const UserOrganizerProfileScreen({
    Key? key,
    required this.organizerId,
  }) : super(key: key);

  @override
  State<UserOrganizerProfileScreen> createState() => _UserOrganizerProfileScreenState();
}

class _UserOrganizerProfileScreenState extends State<UserOrganizerProfileScreen> 
    with SingleTickerProviderStateMixin {
  late final UserOrganizerProfileService _profileService;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  
  OrganizerProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _profileService = UserOrganizerProfileService();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    
    _fetchOrganizerProfile();
  }

  Future<void> _fetchOrganizerProfile() async {
    try {
      final profile = await _profileService.fetchOrganizerProfile(widget.organizerId);
      
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          _profile?.name ?? 'Profile',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.greenAccent),
            onPressed: () {
              // Implement message functionality
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const _LoadingView()
          : _profile == null 
              ? const Text('data')
              : _ProfileView(profile: _profile!, fadeAnimation: _fadeAnimation),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: const _LoadingPlaceholder(),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile image placeholder
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Name placeholder
        Container(
          height: 24,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        // Bio placeholder
        Container(
          height: 16,
          color: Colors.white,
        ),
      ],
    );
  }
}

class _ProfileView extends StatelessWidget {
  final OrganizerProfile profile;
  final Animation<double> fadeAnimation;

  const _ProfileView({
    Key? key,
    required this.profile,
    required this.fadeAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildProfileStats(),
                const SizedBox(height: 20),
                _buildBio(),
                const SizedBox(height: 20),
                _buildLinks(),
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          ),
          _buildPostsGrid(),
        ],
      ),
    );
  }
  // Inside _ProfileView class, add these missing methods:

Widget _buildProfileStats() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildStatColumn('Posts', profile.posts?.length.toString() ?? '0'),
      _buildStatColumn('Followers', '0'), // Replace with actual followers count
      _buildStatColumn('Following', '0'), // Replace with actual following count
    ],
  );
}

Widget _buildStatColumn(String label, String count) {
  return Column(
    children: [
      Text(
        count,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    ],
  );
}

Widget _buildBio() {
  if (profile.bio == null || profile.bio!.isEmpty) return const SizedBox();
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      profile.bio!,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget _buildLinks() {
  if (profile.links == null || profile.links!.isEmpty) return const SizedBox();

  return Column(
    children: profile.links!.map((link) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          // Implement link handling
        },
        child: Text(
          link,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    )).toList(),
  );
}

Widget _buildActionButtons(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              // Implement message functionality
            },
            child: const Text('Message'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.greenAccent),
              foregroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              // Implement follow functionality
            },
            child: const Text('Follow'),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildProfileHeader() {
    return Hero(
      tag: 'profile-${profile.id}',
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.greenAccent, width: 2),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profile.imageUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.person,
              color: Colors.greenAccent,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }

Widget _buildPostsGrid() {
  if (profile.posts.isEmpty) {
  return SliverToBoxAdapter(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'No posts yet',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}


  return SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    ),
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final post = profile.posts![index];
        return _PostThumbnail(post: post);
      },
      childCount: profile.posts!.length,
    ),
  );
  
}
}

class _PostThumbnail extends StatelessWidget {
  final Post post;

  const _PostThumbnail({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'post-${post.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Implement post detail view
          },
          child: CachedNetworkImage(
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[900],
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[900],
              child: const Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
