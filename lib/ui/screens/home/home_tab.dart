import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/yts_api_service.dart';
import '../../widgets/featured_carousel.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/shimmer_loading.dart';

class HomeTab extends StatefulWidget {
  final Function(int) onNavigateToTab;
  final Function(MovieModel) onMovieSelect;

  const HomeTab({
    super.key,
    required this.onNavigateToTab,
    required this.onMovieSelect,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final YtsApiService _apiService = YtsApiService();

  List<MovieModel> _featuredMovies = [];
  List<MovieModel> _popularMovies = [];
  List<MovieModel> _topRatedMovies = [];
  List<MovieModel> _genreMovies = [];

  String _selectedGenre = 'Action';
  bool _isLoadingFeatured = true;
  bool _isLoadingPopular = true;
  bool _isLoadingTopRated = true;
  bool _isLoadingGenre = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    _loadFeatured();
    _loadPopular();
    _loadTopRated();
    _loadGenreMovies(_selectedGenre);
  }

  Future<void> _loadFeatured() async {
    final movies = await _apiService.getMovies(limit: 5, sortBy: 'download_count');
    if (mounted) {
      setState(() {
        _featuredMovies = movies;
        _isLoadingFeatured = false;
      });
    }
  }

  Future<void> _loadPopular() async {
    final movies = await _apiService.getMovies(limit: 10, sortBy: 'like_count');
    if (mounted) {
      setState(() {
        _popularMovies = movies;
        _isLoadingPopular = false;
      });
    }
  }

  Future<void> _loadTopRated() async {
    final movies = await _apiService.getMovies(limit: 10, minimumRating: 8.0, sortBy: 'rating');
    if (mounted) {
      setState(() {
        _topRatedMovies = movies;
        _isLoadingTopRated = false;
      });
    }
  }

  Future<void> _loadGenreMovies(String genre) async {
    setState(() {
      _isLoadingGenre = true;
      _selectedGenre = genre;
    });

    final movies = await _apiService.getMovies(limit: 10, genre: genre);
    if (mounted) {
      setState(() {
        _genreMovies = movies;
        _isLoadingGenre = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return RefreshIndicator(
      color: AppColors.primaryYellow,
      backgroundColor: AppColors.surface,
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar Greeting
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceVariant,
                        border: Border.all(color: AppColors.primaryYellow, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryYellow,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back 👋',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          user?.name ?? 'Youssef Medhat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => widget.onNavigateToTab(2), // Jump to Search
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryYellow,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Featured Hero Carousel
            if (_isLoadingFeatured)
              const SizedBox(
                height: 340,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryYellow),
                ),
              )
            else
              FeaturedCarousel(
                movies: _featuredMovies,
                onMovieTap: widget.onMovieSelect,
              ),

            const SizedBox(height: 28),

            // Popular Movies Section
            _buildSectionHeader('Popular Movies 🔥', () => widget.onNavigateToTab(1)),
            const SizedBox(height: 14),
            _buildHorizontalMovieList(_popularMovies, _isLoadingPopular),

            const SizedBox(height: 28),

            // Top Rated Movies Section
            _buildSectionHeader('Top Rated 🌟', () => widget.onNavigateToTab(1)),
            const SizedBox(height: 14),
            _buildHorizontalMovieList(_topRatedMovies, _isLoadingTopRated),

            const SizedBox(height: 28),

            // Category Chips Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Browse by Genre 🍿',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ApiConstants.genres.length,
                itemBuilder: (context, index) {
                  final genre = ApiConstants.genres[index];
                  return GenreChip(
                    label: genre,
                    isSelected: _selectedGenre == genre,
                    onTap: () => _loadGenreMovies(genre),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Filtered Genre Movies Horizontal List
            _buildHorizontalMovieList(_genreMovies, _isLoadingGenre),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(
                color: AppColors.primaryYellow,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalMovieList(List<MovieModel> movies, bool isLoading) {
    if (isLoading) {
      return SizedBox(
        height: 210,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerMovieCard(),
        ),
      );
    }

    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieCard(
            movie: movie,
            onTap: () => widget.onMovieSelect(movie),
          );
        },
      ),
    );
  }
}
