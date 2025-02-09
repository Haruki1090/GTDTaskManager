import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';

// authStateProvider : 認証情報を監視するStreamProvider
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

// AuthViewModelのProvider
final authViewModelProvider = Provider<AuthViewModel>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository: authRepo);
});

class AuthViewModel {
  final AuthRepository authRepository;

  AuthViewModel({required this.authRepository});

  // Googleアカウントでサインイン
  Future<void> signInWithGoogle() async {
    await authRepository.signInWithGoogle();
  }

  // Emailとパスワードでサインイン
  Future<void> signInWithEmail(String email, String password) async {
    await authRepository.signInWithEmail(email, password);
  }

  // Emailとパスワードでサインアップ
  Future<void> registerWithEmail(String email, String password) async {
    await authRepository.registerWithEmail(email, password);
  }

  // サインアウト
  Future<void> signOut() async {
    await authRepository.signOut();
  }
}
