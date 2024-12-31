// home_page_event.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phuong/modal/event_modal.dart';

abstract class HomePageEvent {}

class LoadHomeEvents extends HomePageEvent {}

class FilterHomeEventsByCategory extends HomePageEvent {
  final int categoryIndex;
  final String? userLocation;

  FilterHomeEventsByCategory(this.categoryIndex, this.userLocation);
}