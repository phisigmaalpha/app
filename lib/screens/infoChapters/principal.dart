import 'package:flutter/material.dart';
import 'package:app/screens/home/components/models.dart';
import 'widgets/history.dart';
import 'widgets/news.dart';
import 'widgets/events.dart';
import 'widgets/documents.dart';

class PrincipalScreen extends StatelessWidget {
  final ChapterModel chapter;

  const PrincipalScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: Row(
            children: [
              chapter.logoUrl != null
                ? CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(chapter.logoUrl!),
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
                      chapter.name,
                      style: const TextStyle(
                        color: Color(0xFF1A3D96),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${chapter.members} integrantes",
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
          bottom: const TabBar(
            labelColor: Color(0xFFEBB143),
            unselectedLabelColor: Color(0xFF1A3D96),
            indicatorColor: Color(0xFFEBB143),
            isScrollable: true,
            tabs: [
              Tab(text: "Historia"),
              Tab(text: "Integrantes"),
              Tab(text: "Noticias"),
              Tab(text: "Documentación"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChapterHistoryWidget(history: chapter.history),
            ChapterMembersWidget(chapterId: chapter.id),
            const NewsWidget(),
            DocumentsWidget(chapterId: chapter.id),
          ],
        ),
      ),
    );
  }
}
