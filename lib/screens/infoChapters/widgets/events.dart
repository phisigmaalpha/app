import 'package:flutter/material.dart';
import 'package:app/services/chapter_service.dart';

class ChapterMembersWidget extends StatefulWidget {
  final String chapterId;

  const ChapterMembersWidget({super.key, required this.chapterId});

  @override
  State<ChapterMembersWidget> createState() => _ChapterMembersWidgetState();
}

class _ChapterMembersWidgetState extends State<ChapterMembersWidget> {
  final _chapterService = ChapterService();
  List<Map<String, dynamic>> _boardMembers = [];
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final board = await _chapterService.getBoardMembers(widget.chapterId);
    final users = await _chapterService.getChapterUsers(widget.chapterId);
    if (!mounted) return;
    setState(() {
      _boardMembers = board;
      _members = users;
      _isLoading = false;
    });
  }

  static const _roleLabels = {
    'presidente': 'Presidente',
    'vicepresidente': 'Vicepresidente',
    'secretario': 'Secretario',
    'tesorero': 'Tesorero',
    'representante_region_oeste': 'Rep. Región Oeste',
    'vicepresidente_region_oeste': 'Vicepresidente Región Oeste',
  };

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
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Directiva section
            if (_boardMembers.isNotEmpty) ...[
              const Text(
                "Directiva",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3D96),
                ),
              ),
              const SizedBox(height: 12),
              ..._boardMembers.map((member) => GestureDetector(
                onTap: () => _showMemberDetail(context, member, isBoard: true),
                child: _buildBoardCard(member),
              )),
              const SizedBox(height: 24),
            ],
            // Integrantes section
            Text(
              "Integrantes (${_members.length})",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3D96),
              ),
            ),
            const SizedBox(height: 12),
            if (_members.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "No hay integrantes registrados",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
            else
              ..._members.map((member) => GestureDetector(
                onTap: () => _showMemberDetail(context, member),
                child: _buildMemberCard(member),
              )),
          ],
        ),
      ),
    );
  }

  void _showMemberDetail(BuildContext context, Map<String, dynamic> member, {bool isBoard = false}) {
    final name = member['full_name'] ?? '';
    final email = member['email'] ?? '';
    final phone = member['phone'] ?? '';
    String? role;
    String? biography;

    if (isBoard) {
      role = _roleLabels[member['role']] ?? member['role'];
      // Look up biography from chapter_users by email
      final match = _members.cast<Map<String, dynamic>?>().firstWhere(
        (u) => u != null && (u['email'] as String?)?.toLowerCase() == (email as String).toLowerCase(),
        orElse: () => null,
      );
      biography = match?['biography'];
    } else {
      biography = member['biography'];
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 32,
              backgroundColor: isBoard
                  ? const Color(0xFFEBB143).withOpacity(0.15)
                  : const Color(0xFF1A3D96).withOpacity(0.1),
              child: Text(
                (name as String).isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isBoard ? const Color(0xFFEBB143) : const Color(0xFF1A3D96),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A3D96),
              ),
            ),
            if (role != null) ...[
              const SizedBox(height: 4),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEBB143),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if ((email as String).isNotEmpty)
              _buildDetailRow(Icons.email_outlined, email),
            if ((phone as String).isNotEmpty)
              _buildDetailRow(Icons.phone_outlined, phone),
            if (biography != null && biography.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Biografía",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A3D96),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  biography,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardCard(Map<String, dynamic> member) {
    final role = _roleLabels[member['role']] ?? member['role'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBB143).withOpacity(0.4)),
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
          CircleAvatar(
            backgroundColor: const Color(0xFFEBB143).withOpacity(0.15),
            child: const Icon(Icons.star, color: Color(0xFFEBB143), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['full_name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A3D96),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    color: const Color(0xFFEBB143),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1A3D96).withOpacity(0.1),
            radius: 18,
            child: Text(
              (member['full_name'] as String? ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF1A3D96),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['full_name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A3D96),
                    fontSize: 14,
                  ),
                ),
                if (member['email'] != null)
                  Text(
                    member['email'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
