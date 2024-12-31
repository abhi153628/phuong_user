// home_page_state.dart
import 'package:phuong/modal/event_modal.dart';

abstract class HomePageState {}

class HomePageInitial extends HomePageState {}

class HomePageLoading extends HomePageState {}

class HomePageLoaded extends HomePageState {
  final List<EventModel> events;
  final int selectedCategory;

  HomePageLoaded(this.events, this.selectedCategory);
}

class HomePageError extends HomePageState {
  final String message;

  HomePageError(this.message);
}