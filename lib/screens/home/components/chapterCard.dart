// Widget privado para la tarjeta individual
import 'package:app/screens/home/components/models.dart';
import 'package:app/screens/infoChapters/principal.dart';
import 'package:flutter/material.dart';

class ChapterCard extends StatelessWidget {
  final ChapterModel chapter;

  const ChapterCard({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrincipalScreen(chapter: chapter),
          ),
        );
      },
      child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            chapter.logoUrl != null
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(chapter.logoUrl!),
                    backgroundColor: Colors.grey.shade200,
                  )
                : const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color.fromRGBO(24, 41, 163, 0.1),
                    child: Icon(Icons.groups, size: 20, color: Color.fromRGBO(24, 41, 163, 1)),
                  ),
            const SizedBox(height: 8),
            Text(
              chapter.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(24, 41, 163, 1),
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: 18,
                  color: Color.fromRGBO(24, 41, 163, 1),
                ),
                const SizedBox(width: 5),
                Text(
                  "${chapter.members} integrantes",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
