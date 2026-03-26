import 'package:flutter/material.dart';

class HomeNavbar extends StatelessWidget {
  final int selectedIndex;
  final String userName;

  const HomeNavbar({
    super.key,
    required this.selectedIndex,
    this.userName = '',
  });

  @override
  Widget build(BuildContext context) {
    final isProfileTab = selectedIndex == 3;

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: !isProfileTab
            ? const Color.fromRGBO(231, 182, 43, 1)
            : const Color.fromRGBO(24, 41, 163, 1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_titleWidget(), const SizedBox(height: 10)],
              ),
            ),
          ),
          Visibility(
            visible: !isProfileTab,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Buscar...",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleWidget() {
    final firstName = userName.isNotEmpty
        ? userName.split(' ').first
        : 'Usuario';

    return selectedIndex != 3
        ? Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 30, color: Color.fromRGBO(24, 41, 163, 1)),
              ),
              const SizedBox(width: 15),
              Text(
                "Hola, $firstName",
                style: const TextStyle(
                  color: Color.fromRGBO(24, 41, 163, 1),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        : Column(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color.fromRGBO(24, 41, 163, 1)),
              ),
              const SizedBox(width: 15),
              Text(
                userName.isNotEmpty ? userName : 'Usuario',
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
  }
}
