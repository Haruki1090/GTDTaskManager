import 'package:firebase_core/firebase_core.dart';

class FirebaseInitializer {
  static Future<FirebaseApp> initializeFirebase() async {
    return Firebase.initializeApp();
  }
}
