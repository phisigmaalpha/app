import 'package:flutter/material.dart';

class FloatingMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const FloatingMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 41, 163, 1),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _menuItem(Icons.home_outlined, 0),
          _menuItem(Icons.calendar_today_outlined, 1),
          _menuItem(Icons.favorite_outline, 2),
          _menuItem(Icons.person_outline, 3),
          _menuItem(Icons.logout, 4),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, int index) {
    final isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Icon(
        icon,
        color: isActive ? const Color.fromRGBO(231, 182, 43, 1) : Colors.white,
        size: 28,
      ),
    );
  }
}
