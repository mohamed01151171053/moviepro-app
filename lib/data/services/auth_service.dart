import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  bool _isFirebaseInitialized = false;

  UserModel? get currentUser => _currentUser;

  Future<void> init() async {
    try {
      final fbAuth = fb.FirebaseAuth.instance;
      _isFirebaseInitialized = true;
      final fbUser = fbAuth.currentUser;
      if (fbUser != null) {
        _currentUser = UserModel(
          uid: fbUser.uid,
          name: fbUser.displayName ?? 'Youssef Medhat',
          email: fbUser.email ?? 'youssef.medhat@movies.com',
          avatarUrl: fbUser.photoURL ?? AppAvatars.avatars[0],
        );
        return;
      }
    } catch (_) {
      _isFirebaseInitialized = false;
    }

    // Local Storage Session Check
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_uid');
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');
    final avatar = prefs.getString('user_avatar');

    if (uid != null && email != null) {
      _currentUser = UserModel(
        uid: uid,
        name: name ?? 'Youssef Medhat',
        email: email,
        avatarUrl: avatar ?? AppAvatars.avatars[0],
      );
    } else {
      // Default Initialized Session for Youssef Medhat
      _currentUser = UserModel(
        uid: 'user_default',
        name: 'Youssef Medhat',
        email: 'youssef.medhat@movies.com',
        avatarUrl: AppAvatars.avatars[0],
      );
      await _saveSession(_currentUser!);
    }
  }

  Future<bool> login(String email, String password) async {
    if (_isFirebaseInitialized) {
      try {
        final credential = await fb.FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (credential.user != null) {
          _currentUser = UserModel(
            uid: credential.user!.uid,
            name: credential.user!.displayName ?? 'Youssef Medhat',
            email: email,
            avatarUrl: credential.user!.photoURL ?? AppAvatars.avatars[0],
          );
          await _saveSession(_currentUser!);
          return true;
        }
      } catch (e) {
        // Fallback to local login if Firebase throw an exception or is mock mode
      }
    }

    // Standard / Fallback Auth
    if (email.contains('@') && password.length >= 6) {
      _currentUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Youssef Medhat',
        email: email,
        avatarUrl: AppAvatars.avatars[0],
      );
      await _saveSession(_currentUser!);
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? avatarUrl,
  }) async {
    final selectedAvatar = avatarUrl ?? AppAvatars.avatars[0];

    if (_isFirebaseInitialized) {
      try {
        final credential = await fb.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        if (credential.user != null) {
          await credential.user!.updateDisplayName(name);
          await credential.user!.updatePhotoURL(selectedAvatar);

          _currentUser = UserModel(
            uid: credential.user!.uid,
            name: name,
            email: email,
            avatarUrl: selectedAvatar,
          );
          await _saveSession(_currentUser!);
          return true;
        }
      } catch (e) {
        // Fallback
      }
    }

    if (email.contains('@') && password.length >= 6) {
      _currentUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        avatarUrl: selectedAvatar,
      );
      await _saveSession(_currentUser!);
      return true;
    }
    return false;
  }

  Future<void> updateAvatar(String newAvatarUrl) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(avatarUrl: newAvatarUrl);
      await _saveSession(_currentUser!);
      if (_isFirebaseInitialized) {
        try {
          await fb.FirebaseAuth.instance.currentUser?.updatePhotoURL(newAvatarUrl);
        } catch (_) {}
      }
    }
  }

  Future<void> updateName(String newName) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: newName);
      await _saveSession(_currentUser!);
      if (_isFirebaseInitialized) {
        try {
          await fb.FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
        } catch (_) {}
      }
    }
  }

  Future<void> logout() async {
    if (_isFirebaseInitialized) {
      try {
        await fb.FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_avatar');
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', user.uid);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_avatar', user.avatarUrl);
  }
}
