import 'package:flutter/material.dart';
import 'package:menu_maison/utils/theme.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: tealColor,
        foregroundColor: whiteColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Graphique des plats consommés',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 200,
                      child: CustomPaint(
                        painter: BarChartPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suivi budgétaire',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text('Semaine: 45€'),
                    const Text('Mois: 180€'),
                    const Text('Année: 2100€'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingrédients les plus utilisés',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text('1. Tomates (15 fois)'),
                    const Text('2. Pâtes (12 fois)'),
                    const Text('3. Fromage (10 fois)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter simple pour un graphique à barres
class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.fill;

    final data = [5, 8, 3, 6]; // Données simulées (ex.: consommation de plats)
    final maxValue = data.reduce((a, b) => a > b ? a : b).toDouble();
    final barWidth = size.width / data.length / 1.5;
    final barSpacing = barWidth / 2;

    for (var i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxValue) * (size.height - 20);
      canvas.drawRect(
        Rect.fromLTWH(
          i * (barWidth + barSpacing),
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
