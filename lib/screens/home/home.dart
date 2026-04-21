import 'package:app/screens/home/components/models.dart';
import 'package:app/screens/home/widgets/homeContainers.dart';
import 'package:app/screens/home/events.dart';
import 'package:app/screens/home/favorites.dart';
import 'package:app/screens/home/news.dart';
import 'package:app/screens/home/profile.dart';
import 'package:app/services/chapter_service.dart';
import 'package:app/services/event_service.dart';
import 'package:app/services/favorites_service.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/supabase_config.dart';
import 'package:flutter/material.dart';
import 'components/navbar.dart';
import 'components/menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _chapterService = ChapterService();
  final _eventService = EventService();
  final _favoritesService = FavoritesService();
  final _authService = AuthService();

  List<ChapterModel> _activosChapters = [];
  List<ChapterModel> _militantesChapters = [];
  EventModel? _featuredEvent;
  Set<String> _favoriteIds = {};
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final activos = await _chapterService.getChapters(type: 'activo');
    final militantes = await _chapterService.getChapters(type: 'militante');

    EventModel? featured;
    try {
      featured = await _eventService.getNextFeaturedEvent();
    } catch (e) {
      debugPrint('Error loading featured event: $e');
    }

    Set<String> favIds = {};
    try {
      favIds = await _favoritesService.getFavoriteEventIds();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }

    String userName = 'Usuario';
    try {
      final profile = await _authService.getCurrentUserProfile();
      userName = profile?['full_name'] ?? 'Usuario';
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }

    if (!mounted) return;
    setState(() {
      _activosChapters = activos;
      _militantesChapters = militantes;
      _featuredEvent = featured;
      _favoriteIds = favIds;
      _userName = userName;

      if (_featuredEvent != null) {
        _featuredEvent!.isFavorite = _favoriteIds.contains(_featuredEvent!.id);
      }

      _isLoading = false;
    });
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              HomeNavbar(selectedIndex: _selectedIndex, userName: _userName),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromRGBO(231, 182, 43, 1),
                          ),
                        ),
                      )
                    : IndexedStack(
                        index: _selectedIndex,
                        children: [
                          // 0: Home
                          RefreshIndicator(
                            onRefresh: _loadData,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  ContainerSection(
                                    title: "Capítulos activos",
                                    type: 'chapter',
                                    chapters: _activosChapters,
                                  ),
                                  SizedBox(height: 10),
                                  if (_militantesChapters.isNotEmpty)
                                    ContainerSection(
                                      title: "Capítulos militantes",
                                      type: 'chapter',
                                      chapters: _militantesChapters,
                                    ),
                                  const SizedBox(height: 10),
                                  if (_featuredEvent != null)
                                    ContainerSection(
                                      title: "Próximo evento destacado",
                                      type: 'event',
                                      events: [_featuredEvent!],
                                      favoriteIds: _favoriteIds,
                                      onFavoriteToggled: _onFavoriteToggled,
                                    ),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                          // 1: Eventos
                          EventSection(
                            favoriteIds: _favoriteIds,
                            onFavoriteToggled: _onFavoriteToggled,
                          ),
                          // 2: Favoritos
                          FavoritesScreen(
                            onFavoriteToggled: _onFavoriteToggled,
                          ),
                          // 3: Noticias
                          const NewsScreen(),
                          // 4: Perfil
                          const ProfileScreen(),
                        ],
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 15,
            left: 20,
            right: 20,
            child: FloatingMenu(
              selectedIndex: _selectedIndex,
              onItemSelected: _onMenuItemSelected,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onFavoriteToggled(String eventId) async {
    final isNowFavorite = await _favoritesService.toggleFavorite(eventId);
    setState(() {
      if (isNowFavorite) {
        _favoriteIds.add(eventId);
      } else {
        _favoriteIds.remove(eventId);
      }
      if (_featuredEvent != null && _featuredEvent!.id == eventId) {
        _featuredEvent!.isFavorite = isNowFavorite;
      }
    });
  }
}
