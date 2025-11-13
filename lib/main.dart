import 'package:flutter/material.dart';
import 'package:sqflite_supabase_b11/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'application/env_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.instance.init();
  final url = EnvService.instance.supabaseUrl;
  final anonKey = EnvService.instance.supabaseAnonKey;
  await Supabase.initialize(url: url!, anonKey: anonKey!);

  runApp(const App());
}
