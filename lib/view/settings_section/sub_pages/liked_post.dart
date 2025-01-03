// liked_posts_page.dart
import 'package:flutter/material.dart';
import 'package:phuong/services/likes_services.dart';
import 'package:phuong/view/post_feed_page/post_feed_page.dart';



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
