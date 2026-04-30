import 'package:app/screens/home/components/eventCard.dart';
import 'package:app/screens/home/components/models.dart';
import 'package:app/services/event_service.dart';
import 'package:flutter/material.dart';

class EventSection extends StatefulWidget {
  final Set<String> favoriteIds;
  final Future<void> Function(String eventId) onFavoriteToggled;
  final String searchQuery;

  const EventSection({
    super.key,
    required this.favoriteIds,
    required this.onFavoriteToggled,
    this.searchQuery = '',
  });

  @override
  State<EventSection> createState() => _EventSectionState();
}

class _EventSectionState extends State<EventSection> {
  final _eventService = EventService();
  List<EventModel> _upcomingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventService.getUpcomingEvents();
      if (!mounted) return;
      setState(() {
        _upcomingEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.fromRGBO(231, 182, 43, 1),
          ),
        ),
      );
    }

    final q = widget.searchQuery.toLowerCase();
    final filtered = q.isEmpty
        ? _upcomingEvents
        : _upcomingEvents.where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.place.toLowerCase().contains(q) ||
            e.tags.any((t) => t.toLowerCase().contains(q))).toList();

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Eventos próximos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(24, 41, 163, 1),
              ),
            ),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    "No hay eventos próximos",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              ...filtered.map(
                (event) => EventCard(
                  event: event,
                  isFavorite: widget.favoriteIds.contains(event.id),
                  onFavoriteToggled: () => widget.onFavoriteToggled(event.id),
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
