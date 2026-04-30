import 'package:flutter/foundation.dart';
import 'package:app/services/supabase_config.dart';

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });
}

class NewsService {
  Future<List<NewsModel>> getNews() async {
    try {
      final response = await supabase
          .from('news')
          .select('id, title, content, image_path, created_at')
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        final imagePath = item['image_path'] as String?;
        String? imageUrl;
        if (imagePath != null) {
          imageUrl = supabase.storage.from('documents').getPublicUrl(imagePath);
        }

        return NewsModel(
          id: item['id'],
          title: item['title'],
          content: item['content'],
          imageUrl: imageUrl,
          createdAt: DateTime.parse(item['created_at']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching news: $e');
      return [];
    }
  }
}
