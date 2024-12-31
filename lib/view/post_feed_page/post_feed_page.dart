import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:phuong/constants/colors.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/likes_services.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/utils/cstm_transition.dart';
import 'package:phuong/view/event_organizer_view_page/event_organizer_view_page.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_bloc.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_event.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_state.dart';
import 'package:phuong/view/settings_section/sub_pages/liked_post.dart';

import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedPage extends StatelessWidget {
  final bool showLikedPostsOnly;
  final Stream<List<Post>> postsStream;

  const FeedPage({
    Key? key,
    required this.postsStream,
    this.showLikedPostsOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedBloc(
        likesService: LikesService(),
        profileService: UserOrganizerProfileService(),
        showLikedPostsOnly: showLikedPostsOnly,
        postsStream: postsStream,
      )..add(LoadFeedEvent())..add(LoadOrganizersEvent()),
      child: _FeedPageContent(showLikedPostsOnly: showLikedPostsOnly),
    );
  }
}

class _FeedPageContent extends StatelessWidget {
  final bool showLikedPostsOnly;

  const _FeedPageContent({
    Key? key,
    required this.showLikedPostsOnly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Padding(
          padding: const EdgeInsets.only(top: 40, left: 20),
          child: Text(
            showLikedPostsOnly ? 'Liked Posts' : 'Band Feed',
            style: GoogleFonts.syne(
              color: const Color(0xFFAFEB2B),
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state is FeedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is PostLikeUpdated && !state.isLiked && showLikedPostsOnly) {
            context.read<FeedBloc>().add(LoadFeedEvent());
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildOrganizerAvatars(context, state, screenWidth),
              Expanded(
                child: _buildFeedContent(context, state, screenWidth, screenHeight),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrganizerAvatars(BuildContext context, FeedState state, double screenWidth) {
    if (state is! FeedLoaded) {
      return Container(
        height: 90,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) => _buildShimmerAvatar(),
        ),
      );
    }

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.organizers.length,
        itemBuilder: (context, index) {
          return _buildOrganizerAvatar(context, state.organizers[index], screenWidth);
        },
      ),
    );
  }

  Widget _buildOrganizerAvatar(BuildContext context, OrganizerProfile organizer, double screenWidth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Hero(
            tag: 'avatar_${organizer.id}',
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserOrganizerProfileScreen(
                      organizerId: organizer.id,
                    ),
                  ),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.black, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: grey,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.activeGreen.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: CachedNetworkImage(
                    imageUrl: organizer.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: grey,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            organizer.name,
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 10,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent(BuildContext context, FeedState state, double screenWidth, double screenHeight) {
    if (state is FeedLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => _buildShimmerEffect(screenHeight),
      );
    }

    if (state is FeedLoaded) {
      if (state.posts.isEmpty) {
        return _buildEmptyState(screenWidth);
      }

      return ListView.builder(
        itemCount: state.posts.length,
        itemBuilder: (context, index) => _PostCard(
          post: state.posts[index],
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          onLikeChanged: (postId, isLiked) {
            context.read<FeedBloc>().add(
              LikePostEvent(postId: postId, isLiked: isLiked),
            );
          },
          showLikedPostsOnly: showLikedPostsOnly,
        ),
      );
    }

    if (state is FeedError) {
      return _buildErrorState(context, screenWidth);
    }

    return const SizedBox.shrink();
  }

  Widget _buildShimmerEffect(double screenHeight) {
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
            height: screenHeight * 0.4,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showLikedPostsOnly ? Icons.favorite_border : Icons.post_add,
            color: Colors.grey[400],
            size: screenWidth * 0.12,
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            showLikedPostsOnly ? 'No liked posts yet' : 'No posts available',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Unable to load ${showLikedPostsOnly ? 'liked posts' : 'feed'}',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          TextButton(
            onPressed: () => context.read<FeedBloc>().add(LoadFeedEvent()),
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
}

class _PostCard extends StatelessWidget {
  final Post post;
  final double screenWidth;
  final double screenHeight;
  final Function(String, bool) onLikeChanged;
  final bool showLikedPostsOnly;

  const _PostCard({
    Key? key,
    required this.post,
    required this.screenWidth,
    required this.screenHeight,
    required this.onLikeChanged,
    required this.showLikedPostsOnly,
  }) : super(key: key);

  void _showLikeToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white),
            SizedBox(width: screenWidth * 0.02),
            const Expanded(
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
            Navigator.of(context).push(GentlePageTransition(page:  LikedPostsPage()));
          },
        ),
      ),
    );
  }

  Future<void> _handleLike(BuildContext context, bool isLiked) async {
    HapticFeedback.mediumImpact();
    try {
      onLikeChanged(post.id, isLiked);
      if (!isLiked) {
        _showLikeToast(context);
      }
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
    final double imageHeight = screenHeight * 0.4;
    final double avatarSize = screenWidth * 0.1;

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
                  stream: context.read<FeedBloc>().watchPostLikeStatus(post.id),
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
                    stream: context.read<FeedBloc>().watchPostLikeStatus(post.id),
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

// Extension to add post like status monitoring to FeedBloc
extension PostLikeStatusMonitoring on FeedBloc {
  Stream<bool> watchPostLikeStatus(String postId) {
    final LikesService likesService = LikesService();
    return likesService.isPostLiked(postId);
  }
}