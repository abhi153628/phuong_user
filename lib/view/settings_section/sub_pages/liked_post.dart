import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phuong/services/likes_services.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_bloc.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_event.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_state.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/view/post_feed_page/post_feed_page.dart';

class LikedPostsPage extends StatelessWidget {
  final LikesService _likesService = LikesService();
  
  LikedPostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedBloc(
        likesService: _likesService,
        profileService: UserOrganizerProfileService(),
        showLikedPostsOnly: true,
        postsStream: _likesService.getLikedPosts(),
      )..add(LoadFeedEvent())..add(LoadOrganizersEvent()),
      child: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Only show loading indicator when initially loading the feed
                if (state is FeedLoading && state.isInitialLoad) 
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  FeedPage(
                    postsStream: _likesService.getLikedPosts(),
                    showLikedPostsOnly: true,
                  ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 5,
                  left: 10,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(9),
                      child: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}