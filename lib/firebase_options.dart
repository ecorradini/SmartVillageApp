// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCG6H56RUzZUXmd7zFZUHc0F2ZLYoyzX0c',
    appId: '1:902212500904:android:6b247de1344ebc77bc719d',
    messagingSenderId: '902212500904',
    projectId: 'smartvillage-be3dd',
    databaseURL: 'https://smartvillage-be3dd-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'smartvillage-be3dd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTfU5JhzSFS5y9DZ9F5L2yI2-Aez3jyvc',
    appId: '1:902212500904:ios:6bc6d957e3c90cf1bc719d',
    messagingSenderId: '902212500904',
    projectId: 'smartvillage-be3dd',
    databaseURL: 'https://smartvillage-be3dd-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'smartvillage-be3dd.appspot.com',
    iosBundleId: 'it.diism.smartvillage23',
  );
}
