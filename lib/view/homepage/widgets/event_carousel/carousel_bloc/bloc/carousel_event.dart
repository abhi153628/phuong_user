import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/view/homepage/widgets/event_carousel/carousel_bloc/bloc/carousel_bloc.dart';
import 'package:phuong/view/homepage/widgets/event_carousel/carousel_bloc/bloc/carousel_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventService _eventService;

  EventsBloc(this._eventService) : super(EventsInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<RefreshEvents>(_onRefreshEvents);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final events = await _eventService.getEvents();
      final now = DateTime.now();
      final filteredEvents = events
          .where((event) => 
              event.date != null && 
              event.date!.isAfter(now.subtract(const Duration(days: 1))))
          .toList()
        ..sort((a, b) => 
            (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
      emit(EventsLoaded(filteredEvents));
    } catch (e) {
      emit(EventsError('Failed to load events: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshEvents(RefreshEvents event, Emitter<EventsState> emit) async {
    try {
      final events = await _eventService.getEvents();
      final now = DateTime.now();
      final filteredEvents = events
          .where((event) => 
              event.date != null && 
              event.date!.isAfter(now.subtract(const Duration(days: 1))))
          .toList()
        ..sort((a, b) => 
            (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
      emit(EventsLoaded(filteredEvents));
    } catch (e) {
      emit(EventsError('Failed to refresh events: ${e.toString()}'));
    }
  }
}