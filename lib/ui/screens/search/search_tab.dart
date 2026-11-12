import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/services/yts_api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/shimmer_loading.dart';

class SearchTab extends StatefulWidget {
  final Function(MovieModel) onMovieSelect;

  const SearchTab({super.key, required this.onMovieSelect});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final YtsApiService _apiService = YtsApiService();
  final TextEditingController _searchController = TextEditingController();

  List<MovieModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  final List<String> _popularQueries = [
    'Batman',
    'Matrix',
    'Interstellar',
    'Avengers',
    'Spiderman',
    'Joker',
    'Action',
  ];

  @override
  void initState() {
    super.initState();
    _performSearch('Batman');
  }

  void _onSearchChanged(String query) {
    setState(() {}); // Update clear icon state instantly

    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      _performSearch('Batman');
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    final searchTerm = query.trim().isEmpty ? 'Batman' : query.trim();

    setState(() {
      _isLoading = true;
    });

    final results = await _apiService.getMovies(queryTerm: searchTerm, limit: 20);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Movies 🔍'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Search Input Box
            CustomTextField(
              controller: _searchController,
              hintText: 'Search by title, actor, or genre...',
              prefixIcon: Icons.search_rounded,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onFieldSubmitted: (term) => _performSearch(term),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('Batman');
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryYellow),
                    onPressed: () => _performSearch(_searchController.text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Tag Chips
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _popularQueries.length,
                itemBuilder: (context, index) {
                  final tag = _popularQueries[index];
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = tag;
                      _performSearch(tag);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        '# $tag',
                        style: const TextStyle(
                          color: AppColors.primaryYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Search Results Summary
            Row(
              children: [
                const Text(
                  'Results',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_searchResults.length})',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Results Grid
            Expanded(
              child: _isLoading
                  ? GridView.builder(
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
                  : _searchResults.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 70,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Movies Found',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Try searching for another title or actor.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final movie = _searchResults[index];
                            return MovieCard(
                              movie: movie,
                              width: double.infinity,
                              height: double.infinity,
                              onTap: () => widget.onMovieSelect(movie),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
