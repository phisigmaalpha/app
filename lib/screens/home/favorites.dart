import 'package:app/screens/home/components/eventCard.dart';
import 'package:app/screens/home/components/models.dart';
import 'package:app/services/favorites_service.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  final Future<void> Function(String eventId) onFavoriteToggled;
  final String searchQuery;

  const FavoritesScreen({
    super.key,
    required this.onFavoriteToggled,
    this.searchQuery = '',
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoritesService = FavoritesService();
  List<EventModel> _favoriteEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didUpdateWidget(FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final events = await _favoritesService.getFavoriteEvents();
      if (!mounted) return;
      setState(() {
        _favoriteEvents = events;
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
        ? _favoriteEvents
        : _favoriteEvents
            .where((e) =>
                e.title.toLowerCase().contains(q) ||
                e.place.toLowerCase().contains(q))
            .toList();

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mis favoritos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(24, 41, 163, 1),
              ),
            ),
            const SizedBox(height: 10),
            if (_favoriteEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border,
                          size: 64, color: Color.fromRGBO(231, 182, 43, 0.5)),
                      SizedBox(height: 16),
                      Text("No tienes eventos favoritos",
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 8),
                      Text("Marca eventos como favoritos para verlos aquí",
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text("Sin resultados",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              )
            else
              ...filtered.map(
                (event) => EventCard(
                  event: event,
                  isFavorite: true,
                  onFavoriteToggled: () async {
                    await widget.onFavoriteToggled(event.id);
                    _loadFavorites();
                  },
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
