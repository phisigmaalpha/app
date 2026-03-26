import 'package:app/services/supabase_config.dart';
import 'package:app/screens/home/components/models.dart';

class EventService {
  /// Fetch all upcoming events (from today onwards).
  Future<List<EventModel>> getUpcomingEvents() async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await supabase
        .from('events')
        .select('*, event_tags(tag), chapters(name)')
        .gte('event_date', today)
        .order('event_date', ascending: true);

    return _parseEvents(response);
  }

  /// Fetch all events.
  Future<List<EventModel>> getAllEvents() async {
    final response = await supabase
        .from('events')
        .select('*, event_tags(tag), chapters(name)')
        .order('event_date', ascending: false);

    return _parseEvents(response);
  }

  /// Fetch the next featured event (closest upcoming).
  Future<EventModel?> getNextFeaturedEvent() async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await supabase
        .from('events')
        .select('*, event_tags(tag), chapters(name)')
        .gte('event_date', today)
        .order('event_date', ascending: true)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return _parseEvent(response);
  }

  List<EventModel> _parseEvents(List<dynamic> data) {
    return data.map((event) => _parseEvent(event)).toList();
  }

  EventModel _parseEvent(Map<String, dynamic> event) {
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
    );
  }
}
