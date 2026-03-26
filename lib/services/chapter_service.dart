import 'package:flutter/foundation.dart';
import 'package:app/services/supabase_config.dart';
import 'package:app/screens/home/components/models.dart';

class ChapterService {
  /// Fetch all active chapters.
  Future<List<ChapterModel>> getChapters({String? type}) async {
    try {
      var query = supabase
          .from('chapters')
          .select('id, type, name, description, history, logo_path, is_active')
          .eq('is_active', true);

      if (type != null) {
        query = query.eq('type', type);
      }

      final response = await query.order('name');
      debugPrint('Chapters response ($type): $response');

      final chapters = (response as List).map((chapter) {
        final logoPath = chapter['logo_path'] as String?;
        String? logoUrl;
        if (logoPath != null) {
          logoUrl = supabase.storage.from('documents').getPublicUrl(logoPath);
        }

        return ChapterModel(
          id: chapter['id'],
          name: chapter['name'],
          type: chapter['type'],
          description: chapter['description'],
          history: chapter['history'],
          logoUrl: logoUrl,
          members: 0,
        );
      }).toList();

      // Fetch member counts from chapter_members
      for (final chapter in chapters) {
        try {
          final countResponse = await supabase
              .from('chapter_members')
              .select()
              .eq('chapter_id', chapter.id)
              .eq('status', 'activo')
              .count();
          chapter.members = countResponse.count;
        } catch (e) {
          debugPrint('Error fetching member count for ${chapter.id}: $e');
        }
      }

      return chapters;
    } catch (e) {
      debugPrint('Error fetching chapters: $e');
      return [];
    }
  }

  /// Fetch a single chapter by ID with board members and their user data.
  Future<Map<String, dynamic>?> getChapterDetail(String chapterId) async {
    try {
      final response = await supabase
          .from('chapters')
          .select('*, board_members(*, user:users(full_name, email, phone))')
          .eq('id', chapterId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching chapter detail: $e');
      return null;
    }
  }

  /// Fetch board members (directiva) for a chapter, with user data.
  Future<List<Map<String, dynamic>>> getBoardMembers(String chapterId) async {
    try {
      final response = await supabase
          .from('board_members')
          .select('id, role, user:users(full_name, email, phone)')
          .eq('chapter_id', chapterId)
          .order('role');

      // Flatten the user data into the board member map
      return (response as List).map((bm) {
        final user = bm['user'] as Map<String, dynamic>?;
        return {
          'id': bm['id'],
          'role': bm['role'],
          'full_name': user?['full_name'] ?? '',
          'email': user?['email'] ?? '',
          'phone': user?['phone'] ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching board members: $e');
      return [];
    }
  }

  /// Fetch chapter members (integrantes) for a chapter via chapter_members join users.
  Future<List<Map<String, dynamic>>> getChapterUsers(String chapterId) async {
    try {
      final response = await supabase
          .from('chapter_members')
          .select(
            'id, status, user:users(id, full_name, email, phone, biography)',
          )
          .eq('chapter_id', chapterId)
          .eq('status', 'activo')
          .order('created_at');

      // Flatten user data
      return (response as List).map((cm) {
        final user = cm['user'] as Map<String, dynamic>?;
        return {
          'id': user?['id'] ?? cm['id'],
          'full_name': user?['full_name'] ?? '',
          'email': user?['email'] ?? '',
          'phone': user?['phone'] ?? '',
          'biography': user?['biography'] ?? '',
          'status': cm['status'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching chapter users: $e');
      return [];
    }
  }

  /// Fetch documents for a specific chapter.
  Future<List<Map<String, dynamic>>> getChapterDocuments(
    String chapterId,
  ) async {
    try {
      final response = await supabase
          .from('documents')
          .select('id, title, file_path, file_size, created_at')
          .eq('chapter_id', chapterId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error fetching chapter documents: $e');
      return [];
    }
  }

  /// Fetch events for a specific chapter.
  Future<List<EventModel>> getChapterEvents(String chapterId) async {
    try {
      final response = await supabase
          .from('events')
          .select('*, event_tags(tag)')
          .eq('chapter_id', chapterId)
          .order('event_date', ascending: true);

      return (response as List).map((event) {
        final tags =
            (event['event_tags'] as List?)
                ?.map((t) => t['tag'] as String)
                .toList() ??
            [];

        return EventModel(
          id: event['id'],
          chapterId: event['chapter_id'],
          title: event['title'],
          place: event['place'],
          eventDate: DateTime.parse(event['event_date']),
          eventTime: event['event_time'] as String,
          tags: tags,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching chapter events: $e');
      return [];
    }
  }
}
