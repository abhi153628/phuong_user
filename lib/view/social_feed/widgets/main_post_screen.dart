import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/likes_services.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/event_organizer_view_page/event_organizer_view_page.dart';
import 'package:phuong/view/social_feed/liked_post.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:timeago/timeago.dart' as timeago;

class FeedPage extends StatefulWidget {
  final bool showLikedPostsOnly;
  final Stream<List<Post>> postsStream;

  const FeedPage({
    Key? key, 
    required this.postsStream,
    this.showLikedPostsOnly = false,
  }) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final LikesService _likesService = LikesService();
  late Stream<List<Post>> _finalPostsStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _finalPostsStream = widget.showLikedPostsOnly 
      ? _likesService.getLikedPosts()
      : widget.postsStream;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = mediaQuery.padding;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.showLikedPostsOnly ? 'Liked Posts' : 'Band Feed',
          style: GoogleFonts.syne(
            color: const Color(0xFFAFEB2B),
            fontSize: screenWidth * 0.06, // Responsive font size
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<Post>>(
          stream: _finalPostsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(screenWidth);
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            final posts = snapshot.data ?? [];
            
            if (posts.isEmpty) {
              return _buildEmptyState(screenWidth);
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) => _PostCard(
                post: posts[index],
                likesService: _likesService,
                onLikeChanged: widget.showLikedPostsOnly ? _handleLikeChanged : null,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Unable to load ${widget.showLikedPostsOnly ? 'liked posts' : 'feed'}',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          TextButton(
            onPressed: () => setState(() => _initializeStream()),
            child: Text(
              'Retry',
              style: GoogleFonts.notoSans(
                color: const Color(0xFFAFEB2B),
                fontSize: screenWidth * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => _buildShimmerEffect(),
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.showLikedPostsOnly ? Icons.favorite_border : Icons.post_add,
            color: Colors.grey[400],
            size: screenWidth * 0.12,
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            widget.showLikedPostsOnly 
              ? 'No liked posts yet'
              : 'No posts available',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLikeChanged(Post post, bool isLiked) {
    if (!isLiked) {
      setState(() => _initializeStream());
    }
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final LikesService likesService;
  final Function(Post, bool)? onLikeChanged;
  final double screenWidth;
  final double screenHeight;

  const _PostCard({
    Key? key,
    required this.post,
    required this.likesService,
    required this.screenWidth,
    required this.screenHeight,
    this.onLikeChanged,
  }) : super(key: key);

  void _showLikeToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: Text(
                'Post added to your likes!',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF87B321),
        action: SnackBarAction(
          label: 'View Likes',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(GentlePageTransition(page: LikedPostsPage()));
          },
        ),
      ),
    );
  }

  Future<void> _handleLike(BuildContext context, bool isLiked) async {
    HapticFeedback.mediumImpact();
    try {
      if (isLiked) {
        await likesService.unlikePost(post.id);
      } else {
        await likesService.likePost(post.id);
        _showLikeToast(context);
      }
      onLikeChanged?.call(post, !isLiked);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update like status',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = screenHeight * 0.4; // Responsive image height
    final double avatarSize = screenWidth * 0.1; // Responsive avatar size
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              post.organizerImageUrl.isNotEmpty
                  ? InkWell(
                      onTap: () => Navigator.of(context).push(
                        GentlePageTransition(
                          page: UserOrganizerProfileScreen(organizerId: post.organizerId),
                        ),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: post.organizerImageUrl,
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildAvatarPlaceholder(),
                          errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
                        ),
                      ),
                    )
                  : _buildAvatarPlaceholder(),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.organizerName,
                      style: GoogleFonts.syne(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      timeago.format(post.timestamp),
                      style: GoogleFonts.notoSans(
                        color: Colors.grey[400],
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
            child: Stack(
              children: [
                StreamBuilder<bool>(
                  stream: likesService.isPostLiked(post.id),
                  initialData: post.isLiked,
                  builder: (context, snapshot) {
                    final isLiked = snapshot.data ?? false;
                    return GestureDetector(
                      onDoubleTap: () {
                        if (!isLiked) {
                          _handleLike(context, isLiked);
                        }
                      },
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: imageHeight,
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFAFEB2B),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: imageHeight,
                          color: Colors.grey[900],
                          child: Icon(
                            Icons.error,
                            color: const Color(0xFFAFEB2B),
                            size: screenWidth * 0.1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                Positioned(
                  bottom: screenHeight * 0.02,
                  right: screenWidth * 0.04,
                  child: StreamBuilder<bool>(
                    stream: likesService.isPostLiked(post.id),
                    initialData: post.isLiked,
                    builder: (context, snapshot) {
                      final isLiked = snapshot.data ?? false;
                      return LikeButton(
                        size: screenWidth * 0.08,
                        isLiked: isLiked,
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? const Color(0xFFAFEB2B) : Colors.white,
                            size: screenWidth * 0.08,
                          );
                        },
                        onTap: (isLiked) async {
                          await _handleLike(context, isLiked);
                          return !isLiked;
                        },
                        bubblesSize: screenWidth * 0.12,
                        circleSize: screenWidth * 0.2,
                        padding: EdgeInsets.zero,
                        circleColor: const CircleColor(
                          start: Color(0xFFAFEB2B),
                          end: Color(0xFF87B321),
                        ),
                        bubblesColor: const BubblesColor(
                          dotPrimaryColor: Color(0xFFAFEB2B),
                          dotSecondaryColor: Color(0xFF87B321),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Text(
              '#${post.description!}',
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.038,
                color: white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return CircleAvatar(
      radius: screenWidth * 0.05,
      backgroundColor: const Color(0xFFAFEB2B),
      child: Text(
        post.organizerName[0].toUpperCase(),
        style: GoogleFonts.syne(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.04,
        ),
      ),
    );
  }
}