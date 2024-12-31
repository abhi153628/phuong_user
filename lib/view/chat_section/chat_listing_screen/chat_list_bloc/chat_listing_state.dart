import 'package:equatable/equatable.dart';
import 'package:phuong/modal/chat_modal.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<OrganizerProfile> organizers;
  final List<OrganizerProfile> filteredOrganizers;
  final Stream<List<ChatRoom>> chatRooms;

  ChatLoaded({
    required this.organizers,
    required this.filteredOrganizers,
    required this.chatRooms,
  });

  @override
  List<Object?> get props => [organizers, filteredOrganizers];
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
