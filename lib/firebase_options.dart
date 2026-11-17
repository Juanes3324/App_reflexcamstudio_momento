import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase is not configured for Web. Run FlutterFire configure.',
      );
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => throw UnsupportedError(
        'Firebase is not configured for iOS. Run FlutterFire configure.',
      ),
      _ => throw UnsupportedError(
        'Firebase is only configured for Android in this project.',
      ),
    };
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyBwu-mGXhuzt1y93v5xgYCfb-hXO3BoGmw',
    appId: '1:114587436078:android:86e50aebcaae52f85e4bbf',
    messagingSenderId: '114587436078',
    projectId: 'reflexcamstudioapp',
    storageBucket: 'reflexcamstudioapp.firebasestorage.app',
  );
}
