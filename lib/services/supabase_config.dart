import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://kpbaajkdhpvxlmebxixz.supabase.co';
const supabaseAnonKey = 'sb_publishable_ZUbZB0Ou63zy7X7xjT9zPQ_VV215AH6';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
