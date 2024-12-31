import 'package:phuong/modal/event_modal.dart';

abstract class EventsState {
  const EventsState();
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<EventModel> events;
  const EventsLoaded(this.events);
}

class EventsError extends EventsState {
  final String message;
  const EventsError(this.message);
}