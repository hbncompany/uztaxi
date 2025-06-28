import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return android;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return android;
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS is not supported');
      default:
        throw UnsupportedError('Unknown platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3Mjsw6nIM9zhW-6F7kTOt12IEmyGvo5c',
    appId: '1:695826586284:android:c102d56f41862d59415d09',
    messagingSenderId: '695826586284',
    projectId: 'expenses-c0d64',
    storageBucket: 'expenses-c0d64.firebasestorage.app',
  );

  // ... other platform configurations
}
