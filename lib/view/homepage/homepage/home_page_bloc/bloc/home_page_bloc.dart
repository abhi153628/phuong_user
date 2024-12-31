import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/view/homepage/homepage/home_page_bloc/bloc/home_page_event.dart';
import 'package:phuong/view/homepage/homepage/home_page_bloc/bloc/home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final EventService _eventService;
  List<EventModel> _allEvents = [];
  final List<String> categories = ['My feed', 'Rock', 'Classical', 'Pop', 'Jazz'];

  HomePageBloc(this._eventService) : super(HomePageInitial()) {
    on<LoadHomeEvents>(_onLoadEvents);
    on<FilterHomeEventsByCategory>(_onFilterEventsByCategory);
  }

  Future<void> _onLoadEvents(LoadHomeEvents event, Emitter<HomePageState> emit) async {
    emit(HomePageLoading());
    try {
      _allEvents = await _eventService.getEvents();
      emit(HomePageLoaded(_allEvents, 0));
    } catch (e) {
      emit(HomePageError('Failed to load events: $e'));
    }
  }

  Future<void> _onFilterEventsByCategory(
      FilterHomeEventsByCategory event, Emitter<HomePageState> emit) async {
    List<EventModel> filteredEvents = [];

    switch (event.categoryIndex) {
      case 0: // My feed
        if (event.userLocation != null) {
          List<String> userLocationWords = event.userLocation!
              .toLowerCase()
              .replaceAll(',', ' ')
              .split(' ')
              .where((word) => word.isNotEmpty)
              .toList();

          filteredEvents = _allEvents.where((event) {
            if (event.location == null) return false;
            List<String> eventLocationWords = event.location!
                .toLowerCase()
                .replaceAll(',', ' ')
                .split(' ')
                .where((word) => word.isNotEmpty)
                .toList();

            return userLocationWords.any((userWord) => eventLocationWords
                .any((eventWord) =>
                    eventWord.contains(userWord) || userWord.contains(eventWord)));
          }).toList();
        }
        break;
      case 1:
        filteredEvents = _allEvents
            .where((event) => event.genreType?.toLowerCase() == 'rock')
            .toList();
        break;
      case 2:
        filteredEvents = _allEvents
            .where((event) => event.genreType?.toLowerCase() == 'classical')
            .toList();
        break;
      case 3:
        filteredEvents = _allEvents
            .where((event) => event.genreType?.toLowerCase() == 'pop')
            .toList();
        break;
      case 4:
        filteredEvents = _allEvents
            .where((event) => event.genreType?.toLowerCase() == 'jazz')
            .toList();
        break;
      default:
        filteredEvents = _allEvents;
    }

    emit(HomePageLoaded(filteredEvents, event.categoryIndex));
  }
}