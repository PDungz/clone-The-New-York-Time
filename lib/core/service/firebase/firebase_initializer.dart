import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:news_app/firebase_options.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    try {
      // Luôn thử lấy app mặc định trước
      final app = Firebase.app();
      debugPrint('Firebase app already exists: ${app.name}');
    } catch (e) {
      // Nếu không có app nào, mới khởi tạo
      debugPrint('No Firebase app found, initializing...');
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        debugPrint('Firebase initialized successfully');
      } catch (initError) {
        debugPrint('Firebase initialization error: $initError');
        // Nếu vẫn lỗi duplicate, thử lấy app hiện có
        try {
          final existingApp = Firebase.app();
          debugPrint('Using existing Firebase app: ${existingApp.name}');
        } catch (getError) {
          debugPrint('Cannot get existing Firebase app: $getError');
          rethrow; // Throw lại nếu thực sự không thể khởi tạo Firebase
        }
      }
    }
  }
}