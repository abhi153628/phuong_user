// event_search_screen.dart
import 'package:flutter/material.dart';
import 'package:phuong/repository/search_provider.dart';
import 'package:phuong/view/demo_event_detailed_page.dart';
import 'package:provider/provider.dart';


class EventSearchScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Events'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: searchProvider.updateQuery,
                          decoration: InputDecoration(
                            hintText: searchProvider.searchType == SearchType.date
                                ? 'Select date range...'
                                : 'Search ${searchProvider.searchType.name}...',
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          readOnly: searchProvider.searchType == SearchType.date,
                          onTap: searchProvider.searchType == SearchType.date
                              ? () async {
                                  DateTimeRange? dateRange = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  searchProvider.setDateRange(dateRange);
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: SearchType.values.map((type) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(type.name.toUpperCase()),
                        selected: searchProvider.searchType == type,
                        onSelected: (selected) {
                          if (selected) {
                            searchProvider.setSearchType(type);
                            _searchController.clear();
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: searchProvider.filteredEvents.isEmpty
          ? const Center(child: Text('No events found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: searchProvider.filteredEvents.length,
              itemBuilder: (context, index) {
                return EventCard(event: searchProvider.filteredEvents[index]);
              },
            ),
    );
  }
}
