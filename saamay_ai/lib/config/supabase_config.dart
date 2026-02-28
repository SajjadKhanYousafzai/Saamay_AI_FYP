import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://ytpsgqffzgkvyalnotxe.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_isi9u3I0h_SMWBCuyvlTiQ_5H_DbxRa';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
