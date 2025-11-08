import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meat_sample.dart';

/// Supabase API client
class SupabaseApi {
  final SupabaseClient _client;

  SupabaseApi(this._client);

  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Upload training sample to cloud
  Future<void> uploadSample(MeatSample sample) async {
    await _client.from('samples').insert(sample.toJson());
  }

  /// Fetch user's training samples from cloud
  Future<List<MeatSample>> fetchSamples() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('samples')
        .select()
        .eq('user_id', userId);

    return (response as List).map((json) => MeatSample.fromJson(json)).toList();
  }

  /// Delete a sample
  Future<void> deleteSample(String sampleId) async {
    await _client.from('samples').delete().eq('id', sampleId);
  }

  /// Sync local samples to cloud
  Future<void> syncSamples(List<MeatSample> samples) async {
    for (final sample in samples) {
      await uploadSample(sample);
    }
  }
}
