import 'package:equatable/equatable.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';

abstract class FeedState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Post> posts;
  final List<OrganizerProfile> organizers;

  FeedLoaded({
    required this.posts,
    required this.organizers,
  });

  @override
  List<Object?> get props => [posts, organizers];
}

class FeedError extends FeedState {
  final String message;

  FeedError(this.message);

  @override
  List<Object?> get props => [message];
}

class PostLikeUpdated extends FeedState {
  final String postId;
  final bool isLiked;

  PostLikeUpdated({required this.postId, required this.isLiked});

  @override
  List<Object?> get props => [postId, isLiked];
}
