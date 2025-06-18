import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:vocal_odyssey/widgets/my_app_bar.dart';
import 'package:vocal_odyssey/widgets/my_scaffold_layout.dart';
import '../../../models/level.dart';
import '../../../providers/level_provider.dart';

class LevelOverviewScreen extends StatelessWidget {
  const LevelOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final level = ModalRoute.of(context)!.settings.arguments as Level;
    final levelProvider = Provider.of<LevelProvider>(context);
    final lwp = levelProvider.levelsWithProgress;

    final attempts = lwp.firstWhere((l) => l.level.id == level.id).attempts;

    return MyScaffoldLayout(
      appBar: MyAppBar(title: level.name),
      topPadding: 0,
      children: [
        const Text(
          'Child Performance Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Average Score per Attempt',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              minY: 80,
              barGroups: attempts
                  .asMap()
                  .entries
                  .map(
                    (entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.score.toDouble(),
                          color: Colors.blue,
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt() + 1}',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: true),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            'Total Mistakes per Attempt',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: attempts
                  .asMap()
                  .entries
                  .map(
                    (entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.mistakesCount.values
                              .fold(0, (sum, count) => sum + count)
                              .toDouble()
                              .clamp(0.5, double.infinity),
                          color: Colors.green,
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt() + 1}',
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: true),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Details for Attempts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...attempts.asMap().entries.map((entry) {
          final index = entry.key;
          final attempt = entry.value;

          return Card(
            child: ListTile(
              title: Text(
                'Attempt ${index + 1}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Score: ${attempt.score}%\n'
                'Mistakes: ${attempt.mistakesCount.isEmpty ? 'None' : attempt.mistakesCount.entries.map((e) => '${e.key}: ${e.value}').join(', ')}\n'
                'Stars achieved: ${attempt.stars.toInt()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }),
      ],
    );
  }
}
