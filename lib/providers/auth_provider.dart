import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// AuthService ka instance
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state — user logged in hai ya nahi
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});