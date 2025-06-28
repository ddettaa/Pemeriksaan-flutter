import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Container untuk memberikan background dan border radius
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(
            255, 59, 227, 182), // Warna latar belakang nav bar
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            // Perbaiki navigasi agar tidak double push jika sudah di halaman yang sama
            if (index == currentIndex) return;
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/dashboard-perawat');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/pemeriksaan');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/histori');
                break;
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromARGB(255, 209, 232, 225),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.groups_outlined),
                activeIcon: Icon(Icons.groups),
                label: 'Utama'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Pemeriksaan'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'Histori'),
          ],
        ),
      ),
    );
  }
}
