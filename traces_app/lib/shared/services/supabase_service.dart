import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  static String? get currentUserId => auth.currentUser?.id;
  static bool get isLoggedIn => auth.currentUser != null;

  // Upload a file to Supabase Storage
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
    String contentType = 'image/jpeg',
  }) async {
    await client.storage.from(bucket).uploadBinary(
      path,
      Uint8List.fromList(bytes),
      fileOptions: FileOptions(contentType: contentType),
    );
    return client.storage.from(bucket).getPublicUrl(path);
  }
}
