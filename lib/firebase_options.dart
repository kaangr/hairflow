// File generated for HairFlow Firebase configuration
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

  // Web yapılandırması - HairFlow
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDci1xtUDZpgaU0QlQb4U-HcB3qCd8SehI',
    appId: '1:95138906850:web:5c746a32d2c7b0df3294bb',
    messagingSenderId: '95138906850',
    projectId: 'hairflow-b5b7d',
    authDomain: 'hairflow-b5b7d.firebaseapp.com',
    storageBucket: 'hairflow-b5b7d.firebasestorage.app',
    measurementId: 'G-CR04B21F62',
  );

  // Android yapılandırması - aynı proje
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDci1xtUDZpgaU0QlQb4U-HcB3qCd8SehI',
    appId: '1:95138906850:android:ANDROID_APP_ID', // Android uygulaması eklediğinde güncelle
    messagingSenderId: '95138906850',
    projectId: 'hairflow-b5b7d',
    storageBucket: 'hairflow-b5b7d.firebasestorage.app',
  );

  // iOS yapılandırması - aynı proje
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDci1xtUDZpgaU0QlQb4U-HcB3qCd8SehI',
    appId: '1:95138906850:ios:IOS_APP_ID', // iOS uygulaması eklediğinde güncelle
    messagingSenderId: '95138906850',
    projectId: 'hairflow-b5b7d',
    storageBucket: 'hairflow-b5b7d.firebasestorage.app',
    iosBundleId: 'com.example.hairflow',
  );

  // macOS yapılandırması
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDci1xtUDZpgaU0QlQb4U-HcB3qCd8SehI',
    appId: '1:95138906850:ios:IOS_APP_ID',
    messagingSenderId: '95138906850',
    projectId: 'hairflow-b5b7d',
    storageBucket: 'hairflow-b5b7d.firebasestorage.app',
    iosBundleId: 'com.example.hairflow',
  );

  // Windows yapılandırması
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDci1xtUDZpgaU0QlQb4U-HcB3qCd8SehI',
    appId: '1:95138906850:web:5c746a32d2c7b0df3294bb',
    messagingSenderId: '95138906850',
    projectId: 'hairflow-b5b7d',
    storageBucket: 'hairflow-b5b7d.firebasestorage.app',
  );
}
