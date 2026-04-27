import 'package:flutter/material.dart';
import 'package:app/screens/home/components/models.dart';
import 'package:app/services/chapter_service.dart';
import 'package:app/l10n/app_localizations.dart';
import 'widgets/history.dart';
import 'widgets/events.dart';
import 'widgets/chapter_events.dart';
import 'widgets/documents.dart';

class PrincipalScreen extends StatefulWidget {
  final ChapterModel chapter;

  const PrincipalScreen({super.key, required this.chapter});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final _chapterService = ChapterService();
  String? _membershipStatus;
  bool _isLoadingStatus = true;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _checkMembership();
  }

  Future<void> _checkMembership() async {
    final status = await _chapterService.getMembershipStatus(widget.chapter.id);
    if (mounted) {
      setState(() {
        _membershipStatus = status;
        _isLoadingStatus = false;
      });
    }
  }

  void _showJoinDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.joinChapterConfirmTitle ?? 'Unirse al capítulo'),
        content: Text(
          l10n?.joinChapterConfirmMessage ?? '¿Deseas unirte a este capítulo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isJoining = true);
              try {
                await _chapterService.joinChapter(widget.chapter.id);
                if (mounted) {
                  setState(() {
                    _membershipStatus = 'pendiente';
                    _isJoining = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.joinChapterSuccess ??
                            'Solicitud enviada exitosamente',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isJoining = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.joinChapterError ?? 'Error al enviar la solicitud',
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(231, 182, 43, 1),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.confirm ?? 'Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: Row(
            children: [
              widget.chapter.logoUrl != null
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(widget.chapter.logoUrl!),
                      backgroundColor: Colors.grey.shade200,
                    )
                  : const CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 25,
                      child: Icon(Icons.groups, color: Colors.white),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chapter.name,
                      style: const TextStyle(
                        color: Color(0xFF1A3D96),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${widget.chapter.members} integrantes",
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [_buildJoinAction(l10n)],
          bottom: TabBar(
            labelColor: const Color(0xFFEBB143),
            unselectedLabelColor: const Color(0xFF1A3D96),
            indicatorColor: const Color(0xFFEBB143),
            isScrollable: true,
            tabs: [
              Tab(text: l10n?.translate('tabHistory') ?? 'Historia'),
              Tab(text: l10n?.translate('tabMembers') ?? 'Integrantes'),
              Tab(text: l10n?.translate('tabEvents') ?? 'Eventos'),
              Tab(text: l10n?.translate('tabDocuments') ?? 'Documentación'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChapterHistoryWidget(history: widget.chapter.history),
            ChapterMembersWidget(chapterId: widget.chapter.id),
            ChapterEventsWidget(chapterId: widget.chapter.id),
            DocumentsWidget(chapterId: widget.chapter.id),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinAction(AppLocalizations? l10n) {
    if (_isLoadingStatus) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color.fromRGBO(231, 182, 43, 1),
          ),
        ),
      );
    }

    if (_isJoining) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color.fromRGBO(231, 182, 43, 1),
          ),
        ),
      );
    }

    if (_membershipStatus == null) {
      return TextButton.icon(
        onPressed: _showJoinDialog,
        icon: const Icon(
          Icons.person_add,
          color: Color.fromRGBO(231, 182, 43, 1),
          size: 18,
        ),
        label: Text(
          l10n?.joinChapter ?? 'Unirse',
          style: const TextStyle(
            color: Color.fromRGBO(231, 182, 43, 1),
            fontSize: 13,
          ),
        ),
      );
    }

    // activo (o cualquier otro estado)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Text(
            l10n?.alreadyMember ?? 'Miembro',
            style: const TextStyle(color: Colors.green, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
