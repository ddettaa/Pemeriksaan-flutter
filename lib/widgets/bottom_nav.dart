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
            255, 105, 219, 188), // Warna latar belakang nav bar
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
            // Logika navigasi tidak berubah, sudah benar
            switch (index) {
              case 0:
                if (currentIndex != 0)
                  Navigator.pushReplacementNamed(context, '/dashboard-perawat');
                break;
              case 1:
                if (currentIndex != 1)
                  Navigator.pushReplacementNamed(context, '/pasien');
                break;
              case 2:
                if (currentIndex != 2)
                  Navigator.pushReplacementNamed(context, '/histori');
                break;
            }
          },
          // --- PENYESUAIAN STYLE DI SINI ---
          backgroundColor: Colors
              .transparent, // Dibuat transparan agar warna Container terlihat
          elevation: 0, // Shadow diatur oleh Container, jadi ini di-nol-kan
          type: BottomNavigationBarType.fixed, // Tipe agar item tidak bergeser
          selectedItemColor: const Color.fromARGB(
              255, 32, 95, 76), // Warna untuk item yang aktif
          unselectedItemColor:
              Colors.grey[600], // Warna untuk item yang tidak aktif
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

          items: const [
            // Ikon disesuaikan agar lebih cocok dengan desain
            BottomNavigationBarItem(
                icon: Icon(Icons.groups_outlined),
                activeIcon: Icon(Icons.groups),
                label: 'Utama'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Pasien'),
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Histori'),
          ],
        ),
      ),
    );
  }
}
