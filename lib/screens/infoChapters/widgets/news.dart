import 'package:flutter/material.dart';

class NewsWidget extends StatelessWidget {
  const NewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3, // Ejemplo
            itemBuilder: (context, index) => _buildNewsCard(),
          ),
        ),
        _buildPagination(),
      ],
    );
  }

  Widget _buildNewsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Día de campo : Celebración del día del hombre 2025",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3D96),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            style: TextStyle(color: Colors.blueGrey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "← Previous",
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Color(0xFFEBB143),
            child: Text("1", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Text("2    3    ..."),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Next →",
              style: TextStyle(color: Color(0xFF1A3D96)),
            ),
          ),
        ],
      ),
    );
  }
}
