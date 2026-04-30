import 'package:flutter/material.dart';
import 'package:app/services/chapter_service.dart';
import 'package:app/screens/home/components/models.dart';
import 'package:app/screens/home/components/eventCard.dart';
import 'package:app/services/favorites_service.dart';

class ChapterEventsWidget extends StatefulWidget {
  final String chapterId;

  const ChapterEventsWidget({super.key, required this.chapterId});

  @override
  State<ChapterEventsWidget> createState() => _ChapterEventsWidgetState();
}

class _ChapterEventsWidgetState extends State<ChapterEventsWidget> {
  final _chapterService = ChapterService();
  final _favoritesService = FavoritesService();
  List<EventModel> _events = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = true;

  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _chapterService.getChapterEvents(widget.chapterId);
    Set<String> favIds = {};
    try {
      favIds = await _favoritesService.getFavoriteEventIds();
    } catch (_) {}

    for (final e in events) {
      e.isFavorite = favIds.contains(e.id);
    }

    if (mounted) {
      setState(() {
        _events = events;
        _favoriteIds = favIds;
        _isLoading = false;
      });
    }
  }

  /// Días que tienen eventos
  Set<DateTime> get _eventDays {
    return _events.map((e) => DateTime(e.eventDate.year, e.eventDate.month, e.eventDate.day)).toSet();
  }

  /// Eventos del día seleccionado
  List<EventModel> get _selectedDayEvents {
    if (_selectedDay == null) return [];
    return _events.where((e) {
      return e.eventDate.year == _selectedDay!.year &&
          e.eventDate.month == _selectedDay!.month &&
          e.eventDate.day == _selectedDay!.day;
    }).toList();
  }

  Future<void> _onFavoriteToggled(String eventId) async {
    final isNow = await _favoritesService.toggleFavorite(eventId);
    setState(() {
      if (isNow) {
        _favoriteIds.add(eventId);
      } else {
        _favoriteIds.remove(eventId);
      }
      for (final e in _events) {
        if (e.id == eventId) e.isFavorite = isNow;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEBB143)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendario
            _buildCalendar(),
            const SizedBox(height: 16),

            // Eventos del día seleccionado
            if (_selectedDay != null) ...[
              Text(
                'Eventos del ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3D96),
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedDayEvents.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No hay eventos este día',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._selectedDayEvents.map((event) => EventCard(
                      event: event,
                      isFavorite: _favoriteIds.contains(event.id),
                      onFavoriteToggled: () => _onFavoriteToggled(event.id),
                    )),
            ] else ...[
              if (_events.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No hay eventos para este capítulo',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Selecciona un día para ver sus eventos',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sunday

    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    const weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A3D96).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header: mes y flechas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xFF1A3D96)),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(year, month - 1);
                    _selectedDay = null;
                  });
                },
              ),
              Text(
                '${months[month]} $year',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3D96),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF1A3D96)),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(year, month + 1);
                    _selectedDay = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Weekday headers
          Row(
            children: weekdays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Day grid
          ...List.generate(6, (week) {
            return Row(
              children: List.generate(7, (weekday) {
                final dayIndex = week * 7 + weekday - startWeekday + 1;
                if (dayIndex < 1 || dayIndex > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 40));
                }

                final date = DateTime(year, month, dayIndex);
                final hasEvent = _eventDays.contains(date);
                final isSelected = _selectedDay != null &&
                    _selectedDay!.year == date.year &&
                    _selectedDay!.month == date.month &&
                    _selectedDay!.day == date.day;
                final isToday = DateTime.now().year == date.year &&
                    DateTime.now().month == date.month &&
                    DateTime.now().day == date.day;

                return Expanded(
                  child: GestureDetector(
                    onTap: hasEvent
                        ? () => setState(() => _selectedDay = date)
                        : null,
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEBB143)
                            : hasEvent
                                ? const Color(0xFFEBB143).withValues(alpha: 0.2)
                                : null,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday && !isSelected
                            ? Border.all(color: const Color(0xFF1A3D96), width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayIndex',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasEvent || isToday ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : hasEvent
                                    ? const Color(0xFF1A3D96)
                                    : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}
