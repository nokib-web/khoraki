import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0R3NJYasCCi8O478lVvWXvQvTB_NMh28',
    appId: '1:493088290249:android:a31351a5d102986c792418',
    messagingSenderId: '493088290249',
    projectId: 'khoraki-6e679',
    storageBucket: 'khoraki-6e679.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD0R3NJYasCCi8O478lVvWXvQvTB_NMh28',
    appId: '1:493088290249:web:a31351a5d102986c792418',
    messagingSenderId: '493088290249',
    projectId: 'khoraki-6e679',
    storageBucket: 'khoraki-6e679.firebasestorage.app',
  );
}
