import 'package:flutter/material.dart';

class ChapterHistoryWidget extends StatelessWidget {
  final String? history;

  const ChapterHistoryWidget({super.key, this.history});

  @override
  Widget build(BuildContext context) {
    if (history == null || history!.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_edu, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Este capítulo aún no tiene historia registrada.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nuestra Historia",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3D96),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            history!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}
