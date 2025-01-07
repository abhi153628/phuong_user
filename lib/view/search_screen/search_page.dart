import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phuong/repository/search_provider.dart';
import 'package:phuong/view/search_screen/search_event_card_widget.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:provider/provider.dart';

class EventSearchScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), 
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        backgroundColor: Colors.black,
        title: Text(
          'Event Explorer',
          style: GoogleFonts.syne(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchSection(context, searchProvider, colorScheme),
          Expanded(
            child: searchProvider.isLoading
                ?  Center(
                    child:Lottie.asset('assets/animations/Animation - 1736144056346.json',height: 170,width: 170)
                  )
                : searchProvider.filteredEvents.isEmpty
                    ? _buildNoResultsWidget()
                    : _buildEventsList(searchProvider, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(
    BuildContext context, 
    SearchProvider searchProvider, 
    ColorScheme colorScheme
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(context, searchProvider),
          const SizedBox(height: 12),
          _buildSearchTypeChips(searchProvider),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context, 
    SearchProvider searchProvider
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.activeGreen.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: searchProvider.updateQuery,
        style: GoogleFonts.notoSans(color: Colors.white),
        decoration: InputDecoration(
          hintText: searchProvider.searchType == SearchType.date
              ? 'Select date range...'
              : 'Search ${searchProvider.searchType.name}...',
          hintStyle: GoogleFonts.notoSans(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: AppColors.activeGreen),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        readOnly: searchProvider.searchType == SearchType.date,
        onTap: searchProvider.searchType == SearchType.date
            ? () async {
                DateTimeRange? dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppColors.activeGreen,
                          surface: Colors.black,
                          onSurface: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                searchProvider.setDateRange(dateRange);
              }
            : null,
      ),
    );
  }

  Widget _buildSearchTypeChips(SearchProvider searchProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SearchType.values.map((type) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                type.name.toUpperCase(),
                style: GoogleFonts.notoSans(
                  color: searchProvider.searchType == type 
                    ? Colors.black 
                    : AppColors.activeGreen,
                    fontWeight: FontWeight.w500
                ),
              ),
              selected: searchProvider.searchType == type,
              selectedColor: AppColors.activeGreen,
              backgroundColor: Colors.grey.shade800,
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
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 100,
            color: AppColors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          // todo : add an empty field showing animation
          Text(
            'No events found',
            style: GoogleFonts.syne(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(
    SearchProvider searchProvider, 
    ColorScheme colorScheme
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchProvider.filteredEvents.length,
      itemBuilder: (context, index) {
        return EventCard(event: searchProvider.filteredEvents[index]);
      },
    );
  }
}

