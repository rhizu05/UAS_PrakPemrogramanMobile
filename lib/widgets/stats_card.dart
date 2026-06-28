import 'package:flutter/material.dart';

// TODO: widgets/stats_card.dart
// Tanggung jawab: Widget card visual untuk statistik admin (dashboard card radius 18, icon, label, besar angka).
class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Stat Card'),
      ),
    );
  }
}
