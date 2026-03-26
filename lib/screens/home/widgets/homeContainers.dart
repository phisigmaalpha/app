import 'package:flutter/material.dart';
import '../components/models.dart';
import '../components/chapterCard.dart';
import '../components/eventCard.dart';

class ContainerSection extends StatelessWidget {
  final String title;
  final String type; // 'chapter' o 'event'
  final List<ChapterModel>? chapters;
  final List<EventModel>? events;
  final Set<String>? favoriteIds;
  final Future<void> Function(String eventId)? onFavoriteToggled;
  final VoidCallback? onSeeMore;

  const ContainerSection({
    super.key,
    required this.title,
    required this.type,
    this.chapters,
    this.events,
    this.favoriteIds,
    this.onFavoriteToggled,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(24, 41, 163, 1),
                ),
              ),
              if (onSeeMore != null)
                TextButton(
                  onPressed: onSeeMore,
                  child: const Text(
                    "Ver más",
                    style: TextStyle(color: Color.fromRGBO(24, 41, 163, 0.7)),
                  ),
                ),
            ],
          ),
        ),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    switch (type) {
      case 'chapter':
        if (chapters == null || chapters!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              "No hay capítulos disponibles",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: chapters!.length,
            itemBuilder: (context, index) {
              return ChapterCard(chapter: chapters![index]);
            },
          ),
        );
      case 'event':
        if (events == null || events!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              "No hay eventos disponibles",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: events!
                .map(
                  (event) => EventCard(
                    event: event,
                    isFavorite: favoriteIds?.contains(event.id) ?? false,
                    onFavoriteToggled: onFavoriteToggled != null
                        ? () => onFavoriteToggled!(event.id)
                        : null,
                  ),
                )
                .toList(),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
