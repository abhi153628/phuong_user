

abstract class HomePageEvent {}

class LoadHomeEvents extends HomePageEvent {}

class FilterHomeEventsByCategory extends HomePageEvent {
  final int categoryIndex;
  final String? userLocation;

  FilterHomeEventsByCategory(this.categoryIndex, this.userLocation);
}