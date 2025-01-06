import 'package:equatable/equatable.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';

abstract class FeedState extends Equatable {
  final List<Post> posts;
  final List<OrganizerProfile> organizers;
  final bool isInitialLoad;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.organizers = const [],
    this.isInitialLoad = true,
    this.error,
  });

  @override
  List<Object?> get props => [posts, organizers, isInitialLoad, error];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {
  const FeedLoading({
    required bool isInitialLoad,
    List<Post> currentPosts = const [],
    List<OrganizerProfile> currentOrganizers = const [],
  }) : super(
          posts: currentPosts,
          organizers: currentOrganizers,
          isInitialLoad: isInitialLoad,
        );
}

class FeedLoaded extends FeedState {
  const FeedLoaded({
    required List<Post> posts,
    required List<OrganizerProfile> organizers,
  }) : super(
          posts: posts,
          organizers: organizers,
          isInitialLoad: false,
        );
}

class FeedError extends FeedState {
  const FeedError({
    required String error,
    List<Post> currentPosts = const [],
    List<OrganizerProfile> currentOrganizers = const [],
  }) : super(
          error: error,
          posts: currentPosts,
          organizers: currentOrganizers,
          isInitialLoad: false,
        );
}
