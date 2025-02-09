import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/account.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 認証状態の変化を監視する Stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Googleアカウントでサインイン
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // ユーザーがキャンセルした場合は何もしない
      return;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
  }

  // Emailとパスワードでサインイン
  Future<void> signInWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Emailとパスワードでサインアップ
  // サインアップ後に返される UserCredential を返す
  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Firestore にアカウント情報を保存する
  Future<void> saveAccountData(Account account) async {
    await _firestore.collection('users').doc(account.uid).set(account.toJson());
  }

  // Firestore からアカウント情報を取得する
  Future<Account?> fetchAccountData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return Account.fromJson(doc.data()!);
    }
    return null;
  }

  // Firestore のアカウント情報を更新する
  Future<void> updateAccountData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // サインアウト
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
