import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB3FYj53DX-gK64FT_WHflvquKc60uN85M',
    appId: '1:207464714538:web:fea081b9ac121fe06a4e53',
    messagingSenderId: '207464714538',
    projectId: 'astro-app-47166',
    authDomain: 'astro-app-47166.firebaseapp.com',
    storageBucket: 'astro-app-47166.appspot.com',
    measurementId: 'G-E39G8NL0E4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3FYj53DX-gK64FT_WHflvquKc60uN85M',
    appId: '1:207464714538:android:fea081b9ac121fe06a4e53',
    messagingSenderId: '207464714538',
    projectId: 'astro-app-47166',
    storageBucket: 'astro-app-47166.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3FYj53DX-gK64FT_WHflvquKc60uN85M',
    appId: '1:207464714538:ios:fea081b9ac121fe06a4e53',
    messagingSenderId: '207464714538',
    projectId: 'astro-app-47166',
    storageBucket: 'astro-app-47166.appspot.com',
    iosClientId: '207464714538-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com',
    iosBundleId: 'com.example.astro.admin',
  );
} 