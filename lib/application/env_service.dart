import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  EnvService._();
  static final EnvService instance = EnvService._();

  Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      print('Error loading .env');
    }
  }

  String? get supabaseUrl => dotenv.env['SUPABASE_URL'];
  String? get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'];
}
