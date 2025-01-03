import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/chat_section/chat_view_screen.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';

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

  OrganizerProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _profileService = UserOrganizerProfileService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
            content: Text(
              'Error fetching profile: $error',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.activeGreen))
              : _profile == null
                  ? const Center(child: Text('No profile found', style: TextStyle(color: Colors.white70)))
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildSliverAppBar(),
                        _buildProfileInfo(),
                        _buildPostsGrid(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (_profile?.imageUrl != null)
                  Stack(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5),
                          BlendMode.darken,
                        ),
                        child: Transform.scale(
                          scale: 2.4,
                          child: CachedNetworkImage(
                            imageUrl: _profile!.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _buildGradientContainer(),
                          ),
                        ),
                      ),
                      _buildGradientOverlay(),
                    ],
                  )
                else
                  _buildGradientContainer(),
                _buildProfileImage(constraints),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGradientContainer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.activeGreen.withOpacity(0.3),
            Colors.black,
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black87,
            Colors.black,
          ],
          stops: [0.4, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildProfileImage(BoxConstraints constraints) {
    final size = constraints.maxWidth * 0.45;
    return Positioned(
      top: 70,
      left: (constraints.maxWidth - size) / 2,
      child: Hero(
        tag: 'profile_image',
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.activeGreen.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: _profile?.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: _profile!.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.activeGreen,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: _buildProfileImagePlaceholder,
                  )
                : _buildProfileImagePlaceholder(context, '', null),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePlaceholder(BuildContext context, String url, dynamic error) {
    return Container(
      color: Colors.grey[850],
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildProfileInfo() {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  _profile?.name ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),
                
                if (_profile?.bio != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _profile!.bio,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                ],

                const SizedBox(height: 16),
                _buildLinks(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 24),
                _buildStats(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinks() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: (_profile?.links ?? []).map((link) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.activeGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            link,
            style: TextStyle(
              color: AppColors.activeGreen,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  GentlePageTransition(
                    page: UserChatScreen(organizerId: widget.organizerId),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.activeGreen),
                foregroundColor: AppColors.activeGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                // Follow functionality
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Follow',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn('Posts', _profile?.posts.length.toString() ?? '0'),
        _buildStatColumn('Followers', '0'),
        _buildStatColumn('Following', '0'),
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
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPostsGrid() {
    if (_profile?.posts == null || _profile!.posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No posts yet',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 15,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = _profile!.posts[index];
            return _PostThumbnail(post: post);
          },
          childCount: _profile!.posts.length,
        ),
      ),
    );
  }
}
class _PostThumbnail extends StatelessWidget {
  final Post post;

  const _PostThumbnail({required this.post});

  void _showImageViewer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (BuildContext context, _, __) {
          return _ImageViewerPage(post: post);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'post-${post.id}',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => _showImageViewer(context),
          child: Container(
            decoration: BoxDecoration(
              // color: Colors.grey[900],
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
            ]),
           child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: constraints.maxWidth,
                        width: constraints.maxWidth,
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[850],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.activeGreen,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[850],
                            child: const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      if (post.description != null && post.description!.isNotEmpty)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              post.description!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageViewerPage extends StatelessWidget {
  final Post post;

  const _ImageViewerPage({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            // Zoomable image
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Hero(
                  tag: 'post-${post.id}',
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: Colors.transparent,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.activeGreen,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.transparent,
                        child: const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Description overlay
            if (post.description != null && post.description!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from closing the viewer
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black87,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      post.description!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
