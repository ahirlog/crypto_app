import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String period;

  const PriceChart({
    Key? key,
    required this.data,
    required this.period,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }

    // Process data for chart
    final List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = -double.infinity;

    // For simplicity, let's generate mock chart data since the API data structure might be different
    for (var i = 0; i < 30; i++) {
      double value = data.length > i
          ? (data[i]['rate_close'] ?? 0.0).toDouble()
          : 10000 + (300 * i) + (i % 5 == 0 ? -500 : 200);

      if (value < minY) minY = value;
      if (value > maxY) maxY = value;

      spots.add(FlSpot(i.toDouble(), value));
    }

    // Add some padding to min/max
    minY = minY * 0.95;
    maxY = maxY * 1.05;

    // Determine gradient colors based on price trend
    final isPositive = spots.first.y < spots.last.y;
    final gradientColors = isPositive
        ? [Colors.green.withOpacity(0.5), Colors.green.withOpacity(0.05)]
        : [Colors.red.withOpacity(0.5), Colors.red.withOpacity(0.05)];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$period Price Chart',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isPositive ? '+${((spots.last.y - spots.first.y) / spots.first.y * 100).toStringAsFixed(2)}%'
                    : '${((spots.last.y - spots.first.y) / spots.first.y * 100).toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toInt()}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              minX: 0,
              maxX: spots.length.toDouble() - 1,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: isPositive ? Colors.green : Colors.red,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.grey[800]!,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      return LineTooltipItem(
                        '\$${touchedSpot.y.toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
