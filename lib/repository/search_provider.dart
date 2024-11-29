import 'package:flutter/material.dart';
import 'package:phuong/modal/event_modal.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';

enum SearchType { name, date, location, genre, organizer }

class SearchProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  SearchType _searchType = SearchType.name;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isLoading = true;

  List<EventModel> get filteredEvents => _filteredEvents;
  SearchType get searchType => _searchType;
  bool get isLoading => _isLoading;

  SearchProvider() {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      _isLoading = true;
      notifyListeners();

      final events = await _eventService.getEvents();
      _allEvents = events;
      _filteredEvents = events;
      
      // Simulate a minimum loading time to prevent flash
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading events: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchType(SearchType type) {
    _searchType = type;
    _selectedStartDate = null;
    _selectedEndDate = null;
    _filterEvents('');
    notifyListeners();
  }

  void _filterEvents(String query) {
    if (query.isEmpty && _searchType != SearchType.date) {
      _filteredEvents = _allEvents;
      notifyListeners();
      return;
    }

    _filteredEvents = _allEvents.where((event) {
      switch (_searchType) {
        case SearchType.name:
          return event.eventName?.toLowerCase().contains(query.toLowerCase()) ?? false;
        case SearchType.location:
          return event.location?.toLowerCase().contains(query.toLowerCase()) ?? false;
        case SearchType.genre:
          return event.genreType?.toLowerCase().contains(query.toLowerCase()) ?? false;
        case SearchType.organizer:
          return event.organizerName?.toLowerCase().contains(query.toLowerCase()) ?? false;
        case SearchType.date:
          if (_selectedStartDate == null) return true;
          if (event.date == null) return false;
          if (_selectedEndDate == null) {
            return event.date!.isAfter(_selectedStartDate!) ||
                event.date!.isAtSameMomentAs(_selectedStartDate!);
          }
          return event.date!.isAfter(_selectedStartDate!) &&
              event.date!.isBefore(_selectedEndDate!);
      }
    }).toList();

    notifyListeners();
  }

  Future<void> setDateRange(DateTimeRange? dateRange) async {
    if (dateRange != null) {
      _selectedStartDate = dateRange.start;
      _selectedEndDate = dateRange.end;
      _filterEvents('');
      notifyListeners();
    }
  }

  void updateQuery(String query) {
    _filterEvents(query);
  }
}