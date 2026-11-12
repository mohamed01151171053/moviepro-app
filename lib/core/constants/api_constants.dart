class ApiConstants {
  static const String baseUrl = 'https://yts.mx/api/v2';
  static const String fallbackBaseUrl = 'https://yts.lt/api/v2';

  // Endpoints
  static const String listMovies = '$baseUrl/list_movies.json';
  static const String movieDetails = '$baseUrl/movie_details.json';
  static const String movieSuggestions = '$baseUrl/movie_suggestions.json';

  // Genres List
  static const List<String> genres = [
    'All',
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Sport',
    'Thriller',
    'War',
    'Western',
  ];
}
