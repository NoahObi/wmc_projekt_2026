import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SubSeeker', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TORTENDIAGRAMM (PIE CHART) ---
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 0, // 0 macht es zu einem vollen Kuchen, keinem Donut
                  sections: [
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: 60,
                      title: '60%',
                      radius: 90,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.blueAccent,
                      value: 40,
                      title: '40%',
                      radius: 90,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- LEGENDE FÜR TORTENDIAGRAMM ---
            _buildLegendItem(Colors.redAccent, 'Streaming: 60%'),
            const SizedBox(height: 10),
            _buildLegendItem(Colors.blueAccent, 'Gaming: 40%'),
            const SizedBox(height: 50),

            // --- 2. LINIENDIAGRAMM (LINE CHART) ---
            const Text(
              'Ausgaben im Vergleich zum Vormonat:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false), // Keine Gitterlinien im Hintergrund
                  titlesData: const FlTitlesData(show: false), // Keine Achsenbeschriftungen wie im Mockup
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      bottom: BorderSide(color: Colors.grey, width: 2),
                      left: BorderSide(color: Colors.grey, width: 2),
                      right: BorderSide.none,
                      top: BorderSide.none,
                    ),
                  ),
                  lineBarsData: [
                    // Linie 1: Aktueller Monat (Weiß)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1),
                        FlSpot(2, 4),
                        FlSpot(4, 3),
                        FlSpot(6, 6),
                      ],
                      isCurved: false, // Spitze Ecken wie im Mockup
                      color: Colors.white,
                      barWidth: 3,
                      dotData: const FlDotData(show: false), // Keine Punkte auf den Ecken
                    ),
                    // Linie 2: Vormonat (Grau)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2),
                        FlSpot(3, 3),
                        FlSpot(4, 5),
                        FlSpot(6, 4),
                      ],
                      isCurved: false,
                      color: Colors.grey,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Hilfs-Widget für die Legende (Farbiger Punkt + Text)
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}