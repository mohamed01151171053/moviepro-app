import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/movie_model.dart';

class YtsApiService {
  static final YtsApiService _instance = YtsApiService._internal();
  factory YtsApiService() => _instance;
  YtsApiService._internal();

  // Cache fetched movies
  final Map<int, MovieModel> _movieDetailsCache = {};

  // Fetch list of movies (with filters, pagination, genre, query_term, sort_by)
  Future<List<MovieModel>> getMovies({
    int limit = 20,
    int page = 1,
    String? quality,
    double? minimumRating,
    String? queryTerm,
    String? genre,
    String sortBy = 'date_added',
    String orderBy = 'desc',
  }) async {
    try {
      final Map<String, String> params = {
        'limit': limit.toString(),
        'page': page.toString(),
        'sort_by': sortBy,
        'order_by': orderBy,
      };

      if (quality != null && quality.isNotEmpty) params['quality'] = quality;
      if (minimumRating != null && minimumRating > 0) {
        params['minimum_rating'] = minimumRating.toString();
      }
      if (queryTerm != null && queryTerm.trim().isNotEmpty) {
        params['query_term'] = queryTerm.trim();
      }
      if (genre != null && genre.isNotEmpty && genre != 'All') {
        params['genre'] = genre;
      }

      final uri = Uri.parse(ApiConstants.listMovies).replace(queryParameters: params);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok' && data['data'] != null) {
          if (data['data']['movies'] != null) {
            final List moviesJson = data['data']['movies'];
            final List<MovieModel> movies =
                moviesJson.map((json) => MovieModel.fromJson(json)).toList();
            
            for (var movie in movies) {
              _movieDetailsCache[movie.id] = movie;
            }
            return movies;
          } else {
            // YTS API returned 0 matching movies for this search query
            return [];
          }
        }
      }
    } catch (e) {
      // Return fallback movies if network fails or API is slow
    }
    return _getFallbackMovies(queryTerm: queryTerm, genre: genre);
  }

  // Fetch Movie Details
  Future<MovieModel?> getMovieDetails(int movieId) async {
    if (_movieDetailsCache.containsKey(movieId) &&
        _movieDetailsCache[movieId]!.cast.isNotEmpty) {
      return _movieDetailsCache[movieId];
    }

    try {
      final uri = Uri.parse(
        '${ApiConstants.movieDetails}?movie_id=$movieId&with_images=true&with_cast=true',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok' && data['data']['movie'] != null) {
          final movie = MovieModel.fromJson(data['data']['movie']);
          _movieDetailsCache[movieId] = movie;
          return movie;
        }
      }
    } catch (e) {
      // Fallback
    }

    return _movieDetailsCache[movieId] ??
        _getFallbackMovies().firstWhere(
          (m) => m.id == movieId,
          orElse: () => _getFallbackMovies().first,
        );
  }

  // Fetch Movie Suggestions / Recommendations
  Future<List<MovieModel>> getMovieSuggestions(int movieId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.movieSuggestions}?movie_id=$movieId',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok' && data['data']['movies'] != null) {
          final List moviesJson = data['data']['movies'];
          return moviesJson.map((json) => MovieModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      // Fallback suggestions
    }
    return _getFallbackMovies().take(4).toList();
  }

  // Fallback Movies Dataset (for instant UI previews and zero-network availability)
  List<MovieModel> _getFallbackMovies({String? queryTerm, String? genre}) {
    final list = [
      MovieModel(
        id: 1001,
        url: 'https://yts.mx',
        imdbCode: 'tt0816692',
        title: 'Interstellar',
        titleEnglish: 'Interstellar',
        year: 2014,
        rating: 8.7,
        runtime: 169,
        genres: ['Adventure', 'Drama', 'Sci-Fi'],
        summary:
            'When Earth becomes uninhabitable in the future, a farmer and ex-NASA pilot, Joseph Cooper, is tasked to pilot a spacecraft, along with a team of researchers, to find a new planet for humans.',
        descriptionFull:
            'When Earth becomes uninhabitable in the future, a farmer and ex-NASA pilot, Joseph Cooper, is tasked to pilot a spacecraft, along with a team of researchers, to find a new planet for humans.',
        synopsis:
            'Earth\'s future has been riddled by disasters, famines, and droughts. There is only one way to ensure mankind\'s survival: Interstellar travel.',
        ytTrailerCode: 'zSWdZVtXT7E',
        language: 'en',
        mpaRating: 'PG-13',
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1200',
        backgroundImageUrlOriginal:
            'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1200',
        smallCoverImage:
            'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=300',
        mediumCoverImage:
            'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
        largeCoverImage:
            'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
        torrents: [
          TorrentModel(
            url: 'https://yts.mx',
            hash: '123',
            quality: '1080p',
            type: 'bluray',
            seeds: 1540,
            peers: 320,
            size: '2.45 GB',
            sizeBytes: 2450000000,
            dateUploaded: '2024-01-10',
          ),
          TorrentModel(
            url: 'https://yts.mx',
            hash: '456',
            quality: '2160p 4K',
            type: 'bluray',
            seeds: 890,
            peers: 140,
            size: '7.80 GB',
            sizeBytes: 7800000000,
            dateUploaded: '2024-01-12',
          ),
        ],
        cast: [
          CastModel(
            name: 'Matthew McConaughey',
            characterName: 'Cooper',
            urlSmallImage:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            imdbCode: 'nm0000190',
          ),
          CastModel(
            name: 'Anne Hathaway',
            characterName: 'Brand',
            urlSmallImage:
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
            imdbCode: 'nm0004266',
          ),
        ],
        dateUploaded: '2024-01-15',
      ),
      MovieModel(
        id: 1002,
        url: 'https://yts.mx',
        imdbCode: 'tt1375666',
        title: 'Inception',
        titleEnglish: 'Inception',
        year: 2010,
        rating: 8.8,
        runtime: 148,
        genres: ['Action', 'Adventure', 'Sci-Fi'],
        summary:
            'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
        descriptionFull:
            'Dom Cobb is a skilled thief, the absolute best in the dangerous art of extraction, stealing valuable secrets from deep within the subconscious during the dream state.',
        synopsis:
            'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
        ytTrailerCode: 'YoHD9XEInc0',
        language: 'en',
        mpaRating: 'PG-13',
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200',
        backgroundImageUrlOriginal:
            'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200',
        smallCoverImage:
            'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=300',
        mediumCoverImage:
            'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=500',
        largeCoverImage:
            'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
        torrents: [
          TorrentModel(
            url: 'https://yts.mx',
            hash: '789',
            quality: '1080p',
            type: 'web',
            seeds: 2100,
            peers: 450,
            size: '2.10 GB',
            sizeBytes: 2100000000,
            dateUploaded: '2024-02-01',
          ),
        ],
        cast: [
          CastModel(
            name: 'Leonardo DiCaprio',
            characterName: 'Cobb',
            urlSmallImage:
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
            imdbCode: 'nm0000138',
          ),
          CastModel(
            name: 'Joseph Gordon-Levitt',
            characterName: 'Arthur',
            urlSmallImage:
                'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
            imdbCode: 'nm0330687',
          ),
        ],
        dateUploaded: '2024-02-05',
      ),
      MovieModel(
        id: 1003,
        url: 'https://yts.mx',
        imdbCode: 'tt0468569',
        title: 'The Dark Knight',
        titleEnglish: 'The Dark Knight',
        year: 2008,
        rating: 9.0,
        runtime: 152,
        genres: ['Action', 'Crime', 'Drama'],
        summary:
            'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
        descriptionFull:
            'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
        synopsis:
            'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets.',
        ytTrailerCode: 'EXeTwQWrcwY',
        language: 'en',
        mpaRating: 'PG-13',
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=1200',
        backgroundImageUrlOriginal:
            'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=1200',
        smallCoverImage:
            'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=300',
        mediumCoverImage:
            'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=500',
        largeCoverImage:
            'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
        torrents: [
          TorrentModel(
            url: 'https://yts.mx',
            hash: '101',
            quality: '1080p',
            type: 'bluray',
            seeds: 3400,
            peers: 610,
            size: '2.30 GB',
            sizeBytes: 2300000000,
            dateUploaded: '2024-02-10',
          ),
        ],
        cast: [
          CastModel(
            name: 'Christian Bale',
            characterName: 'Bruce Wayne / Batman',
            urlSmallImage:
                'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
            imdbCode: 'nm0000288',
          ),
          CastModel(
            name: 'Heath Ledger',
            characterName: 'Joker',
            urlSmallImage:
                'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
            imdbCode: 'nm0005132',
          ),
        ],
        dateUploaded: '2024-02-15',
      ),
      MovieModel(
        id: 1004,
        url: 'https://yts.mx',
        imdbCode: 'tt0111161',
        title: 'The Shawshank Redemption',
        titleEnglish: 'The Shawshank Redemption',
        year: 1994,
        rating: 9.3,
        runtime: 142,
        genres: ['Drama'],
        summary:
            'Over the course of several years, two convicts form a friendship, seeking consolation and eventual redemption through basic compassion.',
        descriptionFull:
            'Over the course of several years, two convicts form a friendship, seeking consolation and eventual redemption through basic compassion.',
        synopsis:
            'Chronicles the experiences of a formerly successful banker as a prisoner in the gloomy jailhouse of Shawshank after being found guilty of a crime he did not commit.',
        ytTrailerCode: '6hB3S9bIaco',
        language: 'en',
        mpaRating: 'R',
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1200',
        backgroundImageUrlOriginal:
            'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=1200',
        smallCoverImage:
            'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=300',
        mediumCoverImage:
            'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=500',
        largeCoverImage:
            'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800',
        torrents: [
          TorrentModel(
            url: 'https://yts.mx',
            hash: '202',
            quality: '1080p',
            type: 'bluray',
            seeds: 1800,
            peers: 290,
            size: '2.05 GB',
            sizeBytes: 2050000000,
            dateUploaded: '2024-03-01',
          ),
        ],
        cast: [
          CastModel(
            name: 'Tim Robbins',
            characterName: 'Andy Dufresne',
            urlSmallImage:
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
            imdbCode: 'nm0000209',
          ),
          CastModel(
            name: 'Morgan Freeman',
            characterName: 'Ellis Boyd "Red" Redding',
            urlSmallImage:
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
            imdbCode: 'nm0000151',
          ),
        ],
        dateUploaded: '2024-03-05',
      ),
      MovieModel(
        id: 1005,
        url: 'https://yts.mx',
        imdbCode: 'tt0133093',
        title: 'The Matrix',
        titleEnglish: 'The Matrix',
        year: 1999,
        rating: 8.7,
        runtime: 136,
        genres: ['Action', 'Sci-Fi'],
        summary:
            'When a beautiful stranger leads computer hacker Neo to a forbidding underworld, he discovers the shocking truth--the life he knows is the elaborate deception of an evil cyber-intelligence.',
        descriptionFull:
            'When a beautiful stranger leads computer hacker Neo to a forbidding underworld, he discovers the shocking truth--the life he knows is the elaborate deception of an evil cyber-intelligence.',
        synopsis:
            'Thomas A. Anderson is a man living two lives. By day he is an average computer programmer and by night a hacker known as Neo.',
        ytTrailerCode: 'vKQi3bBA1y8',
        language: 'en',
        mpaRating: 'R',
        backgroundImageUrl:
            'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1200',
        backgroundImageUrlOriginal:
            'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1200',
        smallCoverImage:
            'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=300',
        mediumCoverImage:
            'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500',
        largeCoverImage:
            'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
        torrents: [
          TorrentModel(
            url: 'https://yts.mx',
            hash: '303',
            quality: '1080p',
            type: 'bluray',
            seeds: 2900,
            peers: 410,
            size: '2.20 GB',
            sizeBytes: 2200000000,
            dateUploaded: '2024-03-10',
          ),
        ],
        cast: [
          CastModel(
            name: 'Keanu Reeves',
            characterName: 'Neo',
            urlSmallImage:
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
            imdbCode: 'nm0000206',
          ),
          CastModel(
            name: 'Laurence Fishburne',
            characterName: 'Morpheus',
            urlSmallImage:
                'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
            imdbCode: 'nm0000401',
          ),
        ],
        dateUploaded: '2024-03-12',
      ),
    ];

    var filtered = list;
    bool isFiltering = false;

    if (queryTerm != null && queryTerm.trim().isNotEmpty) {
      isFiltering = true;
      filtered = filtered
          .where((m) =>
              m.title.toLowerCase().contains(queryTerm.trim().toLowerCase()) ||
              m.genres.any((g) => g.toLowerCase().contains(queryTerm.trim().toLowerCase())))
          .toList();
    }

    if (genre != null && genre.isNotEmpty && genre != 'All') {
      isFiltering = true;
      filtered = filtered.where((m) => m.genres.contains(genre)).toList();
    }

    if (isFiltering) {
      return filtered;
    }
    return list;
  }
}
