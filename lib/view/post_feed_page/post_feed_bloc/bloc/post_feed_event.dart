import 'package:equatable/equatable.dart';


abstract class FeedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFeedEvent extends FeedEvent {}

class LoadOrganizersEvent extends FeedEvent {}

class LikePostEvent extends FeedEvent {
  final String postId;
  final bool isLiked;

  LikePostEvent({required this.postId, required this.isLiked});

  @override
  List<Object?> get props => [postId, isLiked];
}

class FilterOrganizersEvent extends FeedEvent {
  final String query;

  FilterOrganizersEvent(this.query);

  @override
  List<Object?> get props => [query];
}