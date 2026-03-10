import 'package:flutter/material.dart';

class AboListScreen extends StatelessWidget {
  const AboListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy-Daten basierend auf deinem Mockup
    final List<Map<String, dynamic>> abos = [
      {
        'name': 'Netflix',
        'price': '12,99 €',
        'date': '15. des Monats',
        'iconText': 'N',
        'color': Colors.red,
      },
      {
        'name': 'Spotify',
        'price': '9,99 €',
        'date': '2. des Monats',
        'icon': Icons.music_note, // Ersatz für das Spotify-Logo
        'color': Colors.green,
      },
      {
        'name': 'Amazon Prime',
        'price': '7,99 €',
        'date': '20. des Monats',
        'iconText': 'a',
        'color': Colors.blue,
      },
      {
        'name': 'Fitnessstudio',
        'price': '29,99 €',
        'date': '1. des Monats',
        'icon': Icons.fitness_center,
        'color': Colors.white,
        'iconColor': Colors.black, // Damit das Icon auf weißem Grund sichtbar ist
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SubSeeker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () {},
          )
        ],
      ),
      // --- HAUPTINHALT ---
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Abo-Liste',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // --- LISTENANSICHT ---
            Expanded(
              child: ListView.builder(
                itemCount: abos.length,
                itemBuilder: (context, index) {
                  final abo = abos[index];
                  
                  // Dismissible ermöglicht die geforderte Swipe-Geste zum Löschen
                  return Dismissible(
                    key: Key(abo['name']),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      // Bestätigungs-Dialog (laut Konzeptdokument)
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFF2A2A40),
                            title: const Text("Abo löschen", style: TextStyle(color: Colors.white)),
                            content: Text("Möchtest du ${abo['name']} wirklich löschen?", style: const TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Abbrechen", style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Löschen", style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white, size: 30),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A40), // Dunkler Hintergrund
                        border: Border.all(color: Colors.white70, width: 1), // Weißer Rand wie im Mockup
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Das runde Icon links (Avatar)
                          CircleAvatar(
                            backgroundColor: abo['color'],
                            radius: 25,
                            child: abo.containsKey('icon')
                                ? Icon(abo['icon'], color: abo['iconColor'] ?? Colors.white, size: 28)
                                : Text(
                                    abo['iconText'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 15),
                          
                          // Name und Preis/Datum
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  abo['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${abo['price']} | ${abo['date']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Das rote Mülleimer-Icon aus dem Mockup
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              // Hier könnte man den gleichen Dialog wie beim Wischen aufrufen
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-edit');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 40, color: Colors.white),
      ),
    );
  }
}