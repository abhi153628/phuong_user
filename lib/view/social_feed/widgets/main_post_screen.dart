import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/likes_services.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/event_organizer_view_page/event_organizer_view_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/services.dart' show HapticFeedback;

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
    if (widget.showLikedPostsOnly) {
      _finalPostsStream = _likesService.getLikedPosts();
    } else {
      _finalPostsStream = widget.postsStream;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.showLikedPostsOnly ? 'Liked Posts' : 'Band Feed',
          style: GoogleFonts.syne(
            color: const Color(0xFFAFEB2B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<List<Post>>(
        stream: _finalPostsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Unable to load ${widget.showLikedPostsOnly ? 'liked posts' : 'feed'}',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _initializeStream();
                      });
                    },
                    child: Text(
                      'Retry',
                      style: GoogleFonts.notoSans(
                        color: const Color(0xFFAFEB2B),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => _buildShimmerEffect(),
            );
          }

          final posts = snapshot.data ?? [];
          
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.showLikedPostsOnly ? Icons.favorite_border : Icons.post_add,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.showLikedPostsOnly 
                      ? 'No liked posts yet'
                      : 'No posts available',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return AnimatedList(
            initialItemCount: posts.length,
            itemBuilder: (context, index, animation) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(0, 0.5),
                    end: const Offset(0, 0),
                  ).chain(CurveTween(curve: Curves.easeOutCubic))
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: _PostCard(
                    post: posts[index],
                    likesService: _likesService,
                    onLikeChanged: widget.showLikedPostsOnly ? _handleLikeChanged : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleLikeChanged(Post post, bool isLiked) {
    if (!isLiked) {
      // Refresh the stream when a post is unliked in the liked posts view
      setState(() {
        _initializeStream();
      });
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

  const _PostCard({
    Key? key,
    required this.post,
    required this.likesService,
    this.onLikeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              post.organizerImageUrl.isNotEmpty
                  ? InkWell(
                      onTap: () => Navigator.of(context).push(
                        GentlePageTransition(
                          page: UserOrganizerProfileScreen(
                            organizerId: post.organizerId,
                          ),
                        ),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: post.organizerImageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildOrganizerAvatar(),
                          errorWidget: (context, url, error) =>
                              _buildOrganizerAvatar(),
                        ),
                      ),
                    )
                  : _buildOrganizerAvatar(),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.organizerName,
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timeago.format(post.timestamp),
                    style: GoogleFonts.notoSans(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Hero(
              tag: 'post-${post.id}',
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    placeholder: (context, url) => Container(
                      height: 300,
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFAFEB2B),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: Colors.grey[900],
                      child: const Icon(Icons.error, color: Color(0xFFAFEB2B)),
                    ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: _buildLikeButton(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFAFEB2B),
      child: Text(
        post.organizerName[0].toUpperCase(),
        style: GoogleFonts.syne(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.all(8),
      child: StreamBuilder<bool>(
        stream: likesService.isPostLiked(post.id),
        builder: (context, snapshot) {
          final isLiked = snapshot.data ?? false;
          
          return LikeButton(
            size: 32,
            isLiked: isLiked,
            circleColor: const CircleColor(
              start: Color(0xFFAFEB2B),
              end: Color(0xFFCCFF33),
            ),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color(0xFFAFEB2B),
              dotSecondaryColor: Color(0xFFCCFF33),
              dotThirdColor: Colors.white,
              dotLastColor: Color(0xFFE6FF99),
            ),
            likeBuilder: (bool isLiked) {
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isLiked ? 0.8 : 1.0,
                  end: isLiked ? 1.0 : 0.8,
                ),
                duration: const Duration(milliseconds: 200),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? const Color(0xFFAFEB2B) : Colors.white,
                      size: 32,
                    ),
                  );
                },
              );
            },
            onTap: (isLiked) async {
              HapticFeedback.mediumImpact();
              
              try {
                await likesService.toggleLike(post);
                onLikeChanged?.call(post, !isLiked);
                return !isLiked;
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update like status'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return isLiked;
              }
            },
          );
        },
      ),
    );
  }
}