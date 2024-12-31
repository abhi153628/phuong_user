import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/likes_services.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_event.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_state.dart';


// Bloc


class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final LikesService _likesService;
  final UserOrganizerProfileService _profileService;
  final bool showLikedPostsOnly;
  final Stream<List<Post>> postsStream;

  FeedBloc({
    required LikesService likesService,
    required UserOrganizerProfileService profileService,
    required this.showLikedPostsOnly,
    required this.postsStream,
  })  : _likesService = likesService,
        _profileService = profileService,
        super(FeedInitial()) {
    on<LoadFeedEvent>(_onLoadFeed);
    on<LoadOrganizersEvent>(_onLoadOrganizers);
    on<LikePostEvent>(_onLikePost);
  }

  Future<void> _onLoadFeed(LoadFeedEvent event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      final Stream<List<Post>> finalStream = showLikedPostsOnly
          ? _likesService.getLikedPosts()
          : postsStream;

      await emit.forEach(
        finalStream,
        onData: (List<Post> posts) => FeedLoaded(
          posts: posts,
          organizers: (state is FeedLoaded)
              ? (state as FeedLoaded).organizers
              : [],
        ),
      );
    } catch (e) {
      emit(FeedError('Failed to load feed: $e'));
    }
  }

  Future<void> _onLoadOrganizers(
      LoadOrganizersEvent event, Emitter<FeedState> emit) async {
    try {
      final organizers = await _profileService.getAllOrganizers();
      if (state is FeedLoaded) {
        emit(FeedLoaded(
          posts: (state as FeedLoaded).posts,
          organizers: organizers,
        ));
      }
    } catch (e) {
      emit(FeedError('Failed to load organizers: $e'));
    }
  }

  Future<void> _onLikePost(LikePostEvent event, Emitter<FeedState> emit) async {
    try {
      if (event.isLiked) {
        await _likesService.unlikePost(event.postId);
      } else {
        await _likesService.likePost(event.postId);
      }
      emit(PostLikeUpdated(
        postId: event.postId,
        isLiked: !event.isLiked,
      ));
    } catch (e) {
      emit(FeedError('Failed to update like status: $e'));
    }
  }
}
