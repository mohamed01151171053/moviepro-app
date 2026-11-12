import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/services/watchlist_service.dart';
import '../../widgets/movie_card.dart';

class WatchlistTab extends StatelessWidget {
  final Function(MovieModel) onMovieSelect;

  const WatchlistTab({super.key, required this.onMovieSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Watchlist 🔖'),
        automaticallyImplyLeading: false,
      ),
      body: AnimatedBuilder(
        animation: WatchlistService(),
        builder: (context, child) {
          final watchlist = WatchlistService().watchlist;

          if (watchlist.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        size: 60,
                        color: AppColors.primaryYellow,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your Watchlist is Empty',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Save movies you want to watch later by tapping the bookmark icon on any poster.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Saved Movies (${watchlist.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: watchlist.length,
                    itemBuilder: (context, index) {
                      final movie = watchlist[index];
                      return MovieCard(
                        movie: movie,
                        width: double.infinity,
                        height: double.infinity,
                        onTap: () => onMovieSelect(movie),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
