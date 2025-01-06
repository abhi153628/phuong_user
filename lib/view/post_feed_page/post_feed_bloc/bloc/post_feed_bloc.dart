import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/likes_services.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_event.dart';
import 'package:phuong/view/post_feed_page/post_feed_bloc/bloc/post_feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final LikesService likesService;
  final UserOrganizerProfileService profileService;
  final bool showLikedPostsOnly;
  final Stream<List<Post>> postsStream;
  StreamSubscription<List<Post>>? _postsSubscription;

  FeedBloc({
    required this.likesService,
    required this.profileService,
    required this.showLikedPostsOnly,
    required this.postsStream,
  }) : super(FeedInitial()) {
    on<LoadFeedEvent>(_onLoadFeed);
    on<LoadOrganizersEvent>(_onLoadOrganizers);
    on<ToggleLikeEvent>(_onToggleLike);
  }

  Future<void> _onLoadFeed(LoadFeedEvent event, Emitter<FeedState> emit) async {
    emit(FeedLoading(
      isInitialLoad: state is FeedInitial,
      currentPosts: state.posts,
      currentOrganizers: state.organizers,
    ));

    await _postsSubscription?.cancel();
    _postsSubscription = postsStream.listen(
      (posts) {
        add(LoadOrganizersEvent());
        emit(FeedLoaded(
          posts: posts,
          organizers: state.organizers,
        ));
      },
      onError: (error) {
        emit(FeedError(
          error: error.toString(),
          currentPosts: state.posts,
          currentOrganizers: state.organizers,
        ));
      },
    );
  }

  Future<void> _onLoadOrganizers(
    LoadOrganizersEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      final organizers = await profileService.getAllOrganizers();
      emit(FeedLoaded(
        posts: state.posts,
        organizers: organizers,
      ));
    } catch (e) {
      emit(FeedError(
        error: e.toString(),
        currentPosts: state.posts,
        currentOrganizers: state.organizers,
      ));
    }
  }

  Future<void> _onToggleLike(
    ToggleLikeEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await likesService.toggleLike(event.postId, event.currentLikeStatus);
      // No need to emit a new state here as the stream will update automatically
    } catch (e) {
      emit(FeedError(
        error: e.toString(),
        currentPosts: state.posts,
        currentOrganizers: state.organizers,
      ));
    }
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}