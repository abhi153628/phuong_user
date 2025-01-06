// post_feed_event.dart
import 'package:equatable/equatable.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedEvent extends FeedEvent {}

class LoadOrganizersEvent extends FeedEvent {}

class ToggleLikeEvent extends FeedEvent {
  final String postId;
  final bool currentLikeStatus;

  const ToggleLikeEvent({
    required this.postId,
    required this.currentLikeStatus,
  });

  @override
  List<Object?> get props => [postId, currentLikeStatus];
}