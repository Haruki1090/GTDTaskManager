import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../repositories/auth_repository.dart';

// authStateProvider : 認証情報を監視する StreamProvider
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

// AuthViewModel の Provider
final authViewModelProvider = Provider<AuthViewModel>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository: authRepo);
});

class AuthViewModel {
  final AuthRepository authRepository;
  Account? currentAccount;

  AuthViewModel({required this.authRepository}) {
    // 認証状態が変化した際、Firestoreからアカウント情報を読み込む
    authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        currentAccount = await authRepository.fetchAccountData(user.uid);
      } else {
        currentAccount = null;
      }
    });
  }

  // Google アカウントでサインイン
  Future<void> signInWithGoogle() async {
    await authRepository.signInWithGoogle();
  }

  // Email とパスワードでサインイン
  Future<void> signInWithEmail(String email, String password) async {
    await authRepository.signInWithEmail(email, password);
  }

  // Email とパスワードでサインアップ（アカウント情報も Firestore に保存）
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final credential = await authRepository.registerWithEmail(email, password);
    final uid = credential.user!.uid;
    final account = Account(
      uid: uid,
      email: email,
      username: username,
      iconUrl: '',
    );
    await authRepository.saveAccountData(account);
    currentAccount = account;
  }

  // アカウント情報の更新（ユーザー名、アイコン画像 URL の更新）
  Future<void> updateAccountInfo({
    required String username,
    required String iconUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await authRepository.updateAccountData(user.uid, {
        'username': username,
        'iconUrl': iconUrl,
      });
      currentAccount = Account(
        uid: user.uid,
        email: currentAccount?.email ?? user.email ?? '',
        username: username,
        iconUrl: iconUrl,
      );
    }
  }

  // サインアウト
  Future<void> signOut() async {
    await authRepository.signOut();
    currentAccount = null;
  }
}
