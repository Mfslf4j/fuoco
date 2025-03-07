import 'package:supabase_flutter/supabase_flutter.dart';

class ComicRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchComics() async {
    try {
      final response = await _client
          .from('comics')
          .select(
        'id, title, author, volumes, bought_volumes, last_read_volume_matteo, last_read_volume_sara, cover_url',
      )
          .order('title', ascending: true);
      return (response as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Errore durante il recupero dei comics: $e');
    }
  }

  Future<void> updateComic(
      Map<String, dynamic> updatedComic, String selectedProfile) async {
    try {
      await _client.from('comics').update({
        'title': updatedComic['title'],
        'author': updatedComic['author'],
        'volumes': updatedComic['volumes'],
        'bought_volumes': updatedComic['bought_volumes'],
        'last_read_volume_${selectedProfile.toLowerCase()}':
        updatedComic['last_read_volume_${selectedProfile.toLowerCase()}'],
        'cover_url': updatedComic['cover_url'],
      }).eq('id', updatedComic['id']);
    } catch (e) {
      throw Exception('Errore durante l\'aggiornamento del comic: $e');
    }
  }
}