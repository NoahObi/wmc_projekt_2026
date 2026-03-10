import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR ---
      appBar: AppBar(
        title: const Text(
          'SubSeeker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () {
              // Platzhalter für später (z.B. Profil)
            },
          )
        ],
      ),

      // --- SEITENMENÜ (DRAWER) FÜR DIE NAVIGATION ---
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A2E), // Passend zum Theme
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF6B48FF)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.subscriptions, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text('SubSeeker Menü', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.white),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context), // Schließt den Drawer (wir sind ja schon hier)
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.white),
              title: const Text('Abo-Liste', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/abo-list');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart, color: Colors.white),
              title: const Text('Statistik (Analytics)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/analytics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Einstellungen', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),

      // --- HAUPTINHALT (DASHBOARD) ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Gesamtausgaben Karte
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B48FF).withOpacity(0.9), 
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Gesamtausgaben:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '42,50 €',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 2. Anstehende Zahlungen
              const Text(
                'Anstehende Zahlungen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildUpcomingCard('Spotify', 'In 2 Tagen fällig'),
                    const SizedBox(width: 15),
                    _buildUpcomingCard('Netflix', 'In 5 Tagen fällig'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. Ausgaben Statistik
              const Text(
                'Ausgaben Statistik',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 15),
              _buildStatRow('Letzte 7 Tage:', '120,00 €'),
              const Divider(color: Colors.white24, height: 25, thickness: 1),
              _buildStatRow('Letzte 30 Tage:', '450,00 €'),
              const Divider(color: Colors.white24, height: 25, thickness: 1),
              _buildStatRow('Alle Zahlungen:', '1200,00 €'),
            ],
          ),
        ),
      ),

      // --- FLOATING ACTION BUTTON (PLUS) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigiert zum Add/Edit Screen
          Navigator.pushNamed(context, '/add-edit');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 40, color: Colors.white),
      ),
    );
  }

  // Hilfs-Widget: Kleine horizontale Karten für anstehende Zahlungen
  Widget _buildUpcomingCard(String title, String subtitle) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A40), // Dunkleres Blau/Grau aus dem Mockup
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  // Hilfs-Widget: Reihen für die Statistik
  Widget _buildStatRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}