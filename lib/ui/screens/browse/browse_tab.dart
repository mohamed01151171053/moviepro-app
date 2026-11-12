import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/services/yts_api_service.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/shimmer_loading.dart';

class BrowseTab extends StatefulWidget {
  final Function(MovieModel) onMovieSelect;

  const BrowseTab({super.key, required this.onMovieSelect});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  final YtsApiService _apiService = YtsApiService();

  List<MovieModel> _movies = [];
  bool _isLoading = true;
  String _selectedGenre = 'All';
  String _sortBy = 'rating';
  int _page = 1;

  final List<Map<String, String>> _sortOptions = [
    {'label': 'Rating', 'value': 'rating'},
    {'label': 'Latest', 'value': 'year'},
    {'label': 'Popularity', 'value': 'download_count'},
    {'label': 'Alphabetical', 'value': 'title'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true;
    });

    final movies = await _apiService.getMovies(
      limit: 20,
      page: _page,
      genre: _selectedGenre,
      sortBy: _sortBy,
    );

    if (mounted) {
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Movies 🍿'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Genre Chips Selector
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ApiConstants.genres.length,
              itemBuilder: (context, index) {
                final genre = ApiConstants.genres[index];
                return GenreChip(
                  label: genre,
                  isSelected: _selectedGenre == genre,
                  onTap: () {
                    if (_selectedGenre != genre) {
                      _selectedGenre = genre;
                      _page = 1;
                      _fetchMovies();
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Sorting Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Sort by: ',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sortOptions.length,
                      itemBuilder: (context, index) {
                        final option = _sortOptions[index];
                        final isSelected = _sortBy == option['value'];

                        return GestureDetector(
                          onTap: () {
                            if (_sortBy != option['value']) {
                              setState(() {
                                _sortBy = option['value']!;
                                _page = 1;
                              });
                              _fetchMovies();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryYellow.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryYellow
                                    : AppColors.divider,
                              ),
                            ),
                            child: Text(
                              option['label']!,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryYellow
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Movies Grid
          Expanded(
            child: _isLoading
                ? GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const ShimmerMovieCard(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.primaryYellow,
                    backgroundColor: AppColors.surface,
                    onRefresh: _fetchMovies,
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _movies.length,
                      itemBuilder: (context, index) {
                        final movie = _movies[index];
                        return MovieCard(
                          movie: movie,
                          width: double.infinity,
                          height: double.infinity,
                          onTap: () => widget.onMovieSelect(movie),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
