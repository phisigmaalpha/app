class NewsItem {
  final String title;
  final String description;
  NewsItem({required this.title, required this.description});
}

class EventItem {
  final String title;
  final String description;
  final DateTime date;
  final String location;
  EventItem({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
  });
}
