import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final List<int> favoriteMovieIds;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.favoriteMovieIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Youssef Medhat',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? AppAvatars.avatars[0],
      favoriteMovieIds: json['favoriteMovieIds'] != null
          ? List<int>.from(json['favoriteMovieIds'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'favoriteMovieIds': favoriteMovieIds,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? avatarUrl,
    List<int>? favoriteMovieIds,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteMovieIds: favoriteMovieIds ?? this.favoriteMovieIds,
    );
  }
}

class AppAvatars {
  static const List<String> avatars = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
    'assets/images/avatar3.png',
    'assets/images/avatar4.png',
    'assets/images/avatar5.png',
    'assets/images/avatar6.png',
  ];

  static ImageProvider getAvatarProvider(String urlOrPath) {
    if (urlOrPath.startsWith('assets/')) {
      return AssetImage(urlOrPath);
    } else if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return NetworkImage(urlOrPath);
    }
    return const AssetImage('assets/images/avatar1.png');
  }
}
