import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/services/watchlist_service.dart';
import '../../../data/services/yts_api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/movie_card.dart';

class MovieDetailsScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final YtsApiService _apiService = YtsApiService();
  MovieModel? _fullMovieDetails;
  List<MovieModel> _suggestions = [];
  bool _isSynopsisExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadDetailsAndSuggestions();
  }

  Future<void> _loadDetailsAndSuggestions() async {
    final details = await _apiService.getMovieDetails(widget.movie.id);
    final suggestions = await _apiService.getMovieSuggestions(widget.movie.id);

    if (mounted) {
      setState(() {
        _fullMovieDetails = details ?? widget.movie;
        _suggestions = suggestions;
      });
    }
  }

  void _playTrailer(String trailerCode) async {
    if (trailerCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trailer not available for this movie.')),
      );
      return;
    }

    final Uri youtubeUri = Uri.parse('https://www.youtube.com/watch?v=$trailerCode');
    if (await canLaunchUrl(youtubeUri)) {
      await launchUrl(youtubeUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch trailer link.')),
      );
    }
  }

  void _downloadTorrent(String url) async {
    if (url.isEmpty) return;
    final Uri torrentUri = Uri.parse(url);
    if (await canLaunchUrl(torrentUri)) {
      await launchUrl(torrentUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = _fullMovieDetails ?? widget.movie;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header Backdrop Poster SliverAppBar
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.6),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              AnimatedBuilder(
                animation: WatchlistService(),
                builder: (context, child) {
                  final isFav = WatchlistService().isFavorite(movie.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isFav ? AppColors.primaryYellow : Colors.white,
                        ),
                        onPressed: () {
                          WatchlistService().toggleFavorite(movie);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  CachedNetworkImage(
                    imageUrl: movie.largeCoverImage.isNotEmpty
                        ? movie.largeCoverImage
                        : movie.mediumCoverImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.surface),
                    errorWidget: (context, url, err) => Container(color: AppColors.surface),
                  ),

                  // Gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x40000000),
                          Color(0x80121312),
                          Color(0xFF121312),
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // Center Play Trailer Button
                  Center(
                    child: GestureDetector(
                      onTap: () => _playTrailer(movie.ytTrailerCode),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryYellow.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 42,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Poster Details Summary
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Badges Row
                        Row(
                          children: [
                            _buildBadge('⭐ ${movie.rating}'),
                            const SizedBox(width: 8),
                            _buildBadge('⏱️ ${movie.runtime}m'),
                            const SizedBox(width: 8),
                            _buildBadge('📅 ${movie.year}'),
                            const SizedBox(width: 8),
                            _buildBadge(movie.mpaRating.isNotEmpty ? movie.mpaRating : 'PG-13'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Watch Trailer Button
                  CustomButton(
                    text: 'Watch Official Trailer 🎬',
                    icon: Icons.play_circle_fill_rounded,
                    onPressed: () => _playTrailer(movie.ytTrailerCode),
                  ),
                  const SizedBox(height: 24),

                  // Genres List
                  if (movie.genres.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.genres.map((g) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            g,
                            style: const TextStyle(
                              color: AppColors.primaryYellow,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Plot Synopsis
                  const Text(
                    'Synopsis & Plot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.synopsis.isNotEmpty ? movie.synopsis : movie.descriptionFull,
                    maxLines: _isSynopsisExpanded ? null : 4,
                    overflow: _isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSynopsisExpanded = !_isSynopsisExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _isSynopsisExpanded ? 'Show Less' : 'Read More...',
                        style: const TextStyle(
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Cast Carousel
                  if (movie.cast.isNotEmpty) ...[
                    const Text(
                      'Top Cast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movie.cast.length,
                        itemBuilder: (context, index) {
                          final actor = movie.cast[index];
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 14),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.surface,
                                  backgroundImage: actor.urlSmallImage.isNotEmpty
                                      ? NetworkImage(actor.urlSmallImage)
                                      : null,
                                  child: actor.urlSmallImage.isEmpty
                                      ? const Icon(Icons.person, color: AppColors.textMuted)
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  actor.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  actor.characterName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Download Torrents Quality Links
                  if (movie.torrents.isNotEmpty) ...[
                    const Text(
                      'Download Torrents',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: movie.torrents.map((t) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryYellow.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primaryYellow),
                                ),
                                child: Text(
                                  t.quality,
                                  style: const TextStyle(
                                    color: AppColors.primaryYellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${t.type.toUpperCase()} • ${t.size}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Seeds: ${t.seeds}  |  Peers: ${t.peers}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.download_rounded, color: AppColors.primaryYellow),
                                onPressed: () => _downloadTorrent(t.url),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Recommended / Similar Movies
                  if (_suggestions.isNotEmpty) ...[
                    const Text(
                      'You Might Also Like 🍿',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 210,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return MovieCard(
                            movie: suggestion,
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/movie-details',
                                arguments: suggestion,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
