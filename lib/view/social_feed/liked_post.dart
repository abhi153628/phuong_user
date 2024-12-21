// liked_posts_page.dart
import 'package:flutter/material.dart';
import 'package:phuong/services/likes_services.dart';

import 'package:phuong/view/social_feed/widgets/main_post_screen.dart';

class LikedPostsPage extends StatelessWidget {
  final LikesService _likesService = LikesService();

  LikedPostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FeedPage(
      postsStream: _likesService.getLikedPosts(),
      showLikedPostsOnly: true,
    );
  }
}
