class TorrentModel {
  final String url;
  final String hash;
  final String quality;
  final String type;
  final int seeds;
  final int peers;
  final String size;
  final int sizeBytes;
  final String dateUploaded;

  TorrentModel({
    required this.url,
    required this.hash,
    required this.quality,
    required this.type,
    required this.seeds,
    required this.peers,
    required this.size,
    required this.sizeBytes,
    required this.dateUploaded,
  });

  factory TorrentModel.fromJson(Map<String, dynamic> json) {
    return TorrentModel(
      url: json['url'] ?? '',
      hash: json['hash'] ?? '',
      quality: json['quality'] ?? 'HD',
      type: json['type'] ?? 'bluray',
      seeds: json['seeds'] ?? 0,
      peers: json['peers'] ?? 0,
      size: json['size'] ?? '',
      sizeBytes: json['size_bytes'] ?? 0,
      dateUploaded: json['date_uploaded'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'hash': hash,
      'quality': quality,
      'type': type,
      'seeds': seeds,
      'peers': peers,
      'size': size,
      'size_bytes': sizeBytes,
      'date_uploaded': dateUploaded,
    };
  }
}

class CastModel {
  final String name;
  final String characterName;
  final String urlSmallImage;
  final String imdbCode;

  CastModel({
    required this.name,
    required this.characterName,
    required this.urlSmallImage,
    required this.imdbCode,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] ?? 'Actor',
      characterName: json['character_name'] ?? '',
      urlSmallImage: json['url_small_image'] ?? '',
      imdbCode: json['imdb_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'character_name': characterName,
      'url_small_image': urlSmallImage,
      'imdb_code': imdbCode,
    };
  }
}

class MovieModel {
  final int id;
  final String url;
  final String imdbCode;
  final String title;
  final String titleEnglish;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String descriptionFull;
  final String synopsis;
  final String ytTrailerCode;
  final String language;
  final String mpaRating;
  final String backgroundImageUrl;
  final String backgroundImageUrlOriginal;
  final String smallCoverImage;
  final String mediumCoverImage;
  final String largeCoverImage;
  final List<TorrentModel> torrents;
  final List<CastModel> cast;
  final String dateUploaded;

  MovieModel({
    required this.id,
    required this.url,
    required this.imdbCode,
    required this.title,
    required this.titleEnglish,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.summary,
    required this.descriptionFull,
    required this.synopsis,
    required this.ytTrailerCode,
    required this.language,
    required this.mpaRating,
    required this.backgroundImageUrl,
    required this.backgroundImageUrlOriginal,
    required this.smallCoverImage,
    required this.mediumCoverImage,
    required this.largeCoverImage,
    required this.torrents,
    required this.cast,
    required this.dateUploaded,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedGenres = [];
    if (json['genres'] != null) {
      parsedGenres = List<String>.from(json['genres'].map((x) => x.toString()));
    }

    List<TorrentModel> parsedTorrents = [];
    if (json['torrents'] != null) {
      parsedTorrents = List<TorrentModel>.from(
        json['torrents'].map((x) => TorrentModel.fromJson(x)),
      );
    }

    List<CastModel> parsedCast = [];
    if (json['cast'] != null) {
      parsedCast = List<CastModel>.from(
        json['cast'].map((x) => CastModel.fromJson(x)),
      );
    }

    return MovieModel(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      imdbCode: json['imdb_code'] ?? '',
      title: json['title'] ?? 'Untitled Movie',
      titleEnglish: json['title_english'] ?? json['title'] ?? '',
      year: json['year'] ?? 2024,
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 0.0,
      runtime: json['runtime'] ?? 0,
      genres: parsedGenres,
      summary: json['summary'] ?? '',
      descriptionFull: json['description_full'] ?? json['synopsis'] ?? '',
      synopsis: json['synopsis'] ?? json['summary'] ?? '',
      ytTrailerCode: json['yt_trailer_code'] ?? '',
      language: json['language'] ?? 'en',
      mpaRating: json['mpa_rating'] ?? 'PG-13',
      backgroundImageUrl: json['background_image'] ?? '',
      backgroundImageUrlOriginal: json['background_image_original'] ?? '',
      smallCoverImage: json['small_cover_image'] ?? '',
      mediumCoverImage: json['medium_cover_image'] ?? '',
      largeCoverImage: json['large_cover_image'] ?? json['medium_cover_image'] ?? '',
      torrents: parsedTorrents,
      cast: parsedCast,
      dateUploaded: json['date_uploaded'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'imdb_code': imdbCode,
      'title': title,
      'title_english': titleEnglish,
      'year': year,
      'rating': rating,
      'runtime': runtime,
      'genres': genres,
      'summary': summary,
      'description_full': descriptionFull,
      'synopsis': synopsis,
      'yt_trailer_code': ytTrailerCode,
      'language': language,
      'mpa_rating': mpaRating,
      'background_image': backgroundImageUrl,
      'background_image_original': backgroundImageUrlOriginal,
      'small_cover_image': smallCoverImage,
      'medium_cover_image': mediumCoverImage,
      'large_cover_image': largeCoverImage,
      'torrents': torrents.map((x) => x.toJson()).toList(),
      'cast': cast.map((x) => x.toJson()).toList(),
      'date_uploaded': dateUploaded,
    };
  }
}
