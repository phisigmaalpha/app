class ChapterModel {
  final String id;
  final String name;
  final String type; // 'militante' or 'activo'
  final String? description;
  final String? history;
  final String? logoUrl;
  int members;

  ChapterModel({
    required this.id,
    required this.name,
    this.type = 'activo',
    this.description,
    this.history,
    this.logoUrl,
    required this.members,
  });
}

class ProfileModel {
  final String title;
  final String? description;

  ProfileModel({required this.title, required this.description});
}

class EventModel {
  final String id;
  final String? chapterId;
  final String title;
  final String place;
  final DateTime eventDate;
  final String eventTime;
  final List<String> tags;
  final String? chapterName;
  bool isFavorite;

  EventModel({
    required this.id,
    this.chapterId,
    required this.title,
    required this.place,
    required this.eventDate,
    required this.eventTime,
    this.tags = const [],
    this.chapterName,
    this.isFavorite = false,
  });
}
