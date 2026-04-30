import 'package:add_2_calendar/add_2_calendar.dart' as cal;
import 'package:app/screens/home/components/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggled;

  const EventCard({
    super.key,
    required this.event,
    this.isFavorite = false,
    this.onFavoriteToggled,
  });

  void _onHeartTap(BuildContext context) {
    final wasFavorite = isFavorite;
    onFavoriteToggled?.call();

    // If going from not-favorite to favorite, offer to add to calendar
    if (!wasFavorite) {
      _showCalendarDialog(context);
    }
  }

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Agregar al calendario"),
        content: const Text(
          "¿Deseas agregar este evento a tu calendario con un recordatorio?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _addToCalendar();
            },
            child: const Text("Sí, agregar"),
          ),
        ],
      ),
    );
  }

  void _addToCalendar() {
    final timeParts = event.eventTime.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;

    final startDate = DateTime(
      event.eventDate.year,
      event.eventDate.month,
      event.eventDate.day,
      hour,
      minute,
    );

    final calEvent = cal.Event(
      title: event.title,
      description: event.chapterName != null
          ? 'Evento de ${event.chapterName}'
          : 'Evento SIGMA',
      location: event.place,
      startDate: startDate,
      endDate: startDate.add(const Duration(hours: 1)),
      iosParams: const cal.IOSParams(reminder: Duration(minutes: 30)),
      androidParams: const cal.AndroidParams(emailInvites: []),
    );

    cal.Add2Calendar.addEvent2Cal(calEvent);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromRGBO(24, 41, 163, 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(24, 41, 163, 1),
                      fontSize: 16,
                    ),
                  ),
                  if (event.chapterName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.chapterName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(24, 41, 163, 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.place,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(event.eventDate),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.eventTime,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (event.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: event.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(231, 182, 43, 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color.fromRGBO(231, 182, 43, 1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _onHeartTap(context),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: const Color.fromRGBO(231, 182, 43, 1),
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
