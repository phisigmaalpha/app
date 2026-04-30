import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/services/chapter_service.dart';
import 'package:app/services/supabase_config.dart';

class DocumentsWidget extends StatefulWidget {
  final String chapterId;

  const DocumentsWidget({super.key, required this.chapterId});

  @override
  State<DocumentsWidget> createState() => _DocumentsWidgetState();
}

class _DocumentsWidgetState extends State<DocumentsWidget> {
  final _chapterService = ChapterService();
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final docs = await _chapterService.getChapterDocuments(widget.chapterId);
    if (!mounted) return;
    setState(() {
      _documents = docs;
      _isLoading = false;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    const k = 1024;
    final sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (log(bytes) / log(k)).floor();
    return '${(bytes / pow(k, i)).toStringAsFixed(1)} ${sizes[i]}';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _openDocument(String filePath) async {
    final url = supabase.storage.from('documents').getPublicUrl(filePath);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

    if (_documents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No hay documentos disponibles",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          final doc = _documents[index];
          final title = doc['title'] ?? 'Sin título';
          final fileSize = doc['file_size'] as int? ?? 0;
          final createdAt = doc['created_at'] as String? ?? '';
          final filePath = doc['file_path'] as String;

          return GestureDetector(
            onTap: () => _openDocument(filePath),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A3D96),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatFileSize(fileSize)} · ${_formatDate(createdAt)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new,
                    color: Color(0xFF1A3D96),
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
