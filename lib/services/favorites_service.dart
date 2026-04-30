import 'package:app/services/supabase_config.dart';
import 'package:app/screens/home/components/models.dart';

class FavoritesService {
  /// Get the set of event IDs that the current user has favorited.
  Future<Set<String>> getFavoriteEventIds() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return {};

    final response = await supabase
        .from('user_favorites')
        .select('event_id')
        .eq('user_id', userId);

    return (response as List)
        .map((row) => row['event_id'] as String)
        .toSet();
  }

  /// Toggle favorite status for an event. Returns true if now favorited.
  Future<bool> toggleFavorite(String eventId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    // Check if already favorited
    final existing = await supabase
        .from('user_favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('event_id', eventId)
        .maybeSingle();

    if (existing != null) {
      // Remove favorite
      await supabase
          .from('user_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('event_id', eventId);
      return false;
    } else {
      // Add favorite
      await supabase.from('user_favorites').insert({
        'user_id': userId,
        'event_id': eventId,
      });
      return true;
    }
  }

  /// Get all favorited events with full event data.
  Future<List<EventModel>> getFavoriteEvents() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('user_favorites')
        .select('event_id, events(*, event_tags(tag), chapters(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).where((row) => row['events'] != null).map((row) {
      final event = row['events'] as Map<String, dynamic>;
      final tags = (event['event_tags'] as List?)
              ?.map((t) => t['tag'] as String)
              .toList() ??
          [];
      final chapterName = event['chapters'] != null
          ? event['chapters']['name'] as String?
          : null;

      return EventModel(
        id: event['id'],
        chapterId: event['chapter_id'],
        title: event['title'],
        place: event['place'],
        eventDate: DateTime.parse(event['event_date']),
        eventTime: event['event_time'] as String,
        tags: tags,
        chapterName: chapterName,
        isFavorite: true,
      );
    }).toList();
  }
}
