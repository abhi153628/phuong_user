import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {}

class SearchChats extends ChatEvent {
  final String query;
  SearchChats(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadOrganizers extends ChatEvent {}