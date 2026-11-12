import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_model.dart';

class WatchlistService extends ChangeNotifier {
  static final WatchlistService _instance = WatchlistService._internal();
  factory WatchlistService() => _instance;
  WatchlistService._internal();

  final List<MovieModel> _watchlist = [];

  List<MovieModel> get watchlist => List.unmodifiable(_watchlist);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString('user_watchlist');
      if (jsonString != null && jsonString.isNotEmpty) {
        final List decodedList = json.decode(jsonString);
        _watchlist.clear();
        _watchlist.addAll(decodedList.map((x) => MovieModel.fromJson(x)));
        notifyListeners();
      }
    } catch (_) {}
  }

  bool isFavorite(int movieId) {
    return _watchlist.any((movie) => movie.id == movieId);
  }

  Future<void> toggleFavorite(MovieModel movie) async {
    final index = _watchlist.indexWhere((m) => m.id == movie.id);
    if (index >= 0) {
      _watchlist.removeAt(index);
    } else {
      _watchlist.add(movie);
    }
    notifyListeners();
    await _persistWatchlist();
  }

  Future<void> removeFromWatchlist(int movieId) async {
    _watchlist.removeWhere((m) => m.id == movieId);
    notifyListeners();
    await _persistWatchlist();
  }

  Future<void> _persistWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _watchlist.map((m) => m.toJson()).toList();
      await prefs.setString('user_watchlist', json.encode(jsonList));
    } catch (_) {}
  }
}
