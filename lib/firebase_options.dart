// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBDBftqqFDgYeJz_s9o95ml0gMp9Pv5gTs',
    appId: '1:127745496627:web:9e24ead03a43784e057546',
    messagingSenderId: '127745496627',
    projectId: 'shatter-forge',
    authDomain: 'shatter-forge.firebaseapp.com',
    storageBucket: 'shatter-forge.appspot.com',
    measurementId: 'G-JDK1FXKVJK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJQhx1MD03iSVPFlygvgftKrXQWJgxgjs',
    appId: '1:127745496627:android:8d423aa8264ed9a0057546',
    messagingSenderId: '127745496627',
    projectId: 'shatter-forge',
    storageBucket: 'shatter-forge.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDk4aoSo1tSyHFJPimbfSTojUjGJCYQgCQ',
    appId: '1:127745496627:ios:c2611c86f7fb5e65057546',
    messagingSenderId: '127745496627',
    projectId: 'shatter-forge',
    storageBucket: 'shatter-forge.appspot.com',
    iosBundleId: 'com.example.shatterforge',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDk4aoSo1tSyHFJPimbfSTojUjGJCYQgCQ',
    appId: '1:127745496627:ios:c2611c86f7fb5e65057546',
    messagingSenderId: '127745496627',
    projectId: 'shatter-forge',
    storageBucket: 'shatter-forge.appspot.com',
    iosBundleId: 'com.example.shatterforge',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBDBftqqFDgYeJz_s9o95ml0gMp9Pv5gTs',
    appId: '1:127745496627:web:c6ad51f6112332d5057546',
    messagingSenderId: '127745496627',
    projectId: 'shatter-forge',
    authDomain: 'shatter-forge.firebaseapp.com',
    storageBucket: 'shatter-forge.appspot.com',
    measurementId: 'G-4GZVTV5LM2',
  );
}
