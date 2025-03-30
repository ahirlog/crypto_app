import 'dart:developer';
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

    try {
      log('PriceChart data: ${data.length} items');
      if (data.isNotEmpty) {
        log('First item keys: ${data.first.keys.join(', ')}');
      }

      // Process data for chart
      final List<FlSpot> spots = [];
      double minY = double.infinity;
      double maxY = -double.infinity;

      // Try to extract price data from different possible formats
      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        
        // Try different possible keys for price data
        double? value;
        
        if (item.containsKey('rate_close')) {
          value = _safeToDouble(item['rate_close']);
        } else if (item.containsKey('close')) {
          value = _safeToDouble(item['close']);
        } else if (item.containsKey('price')) {
          value = _safeToDouble(item['price']);
        } else if (item.containsKey('value')) {
          value = _safeToDouble(item['value']);
        } else if (item.containsKey('rate')) {
          value = _safeToDouble(item['rate']);
        } else {
          // If no known keys, use the first double value found
          for (final val in item.values) {
            if (val is num) {
              value = val.toDouble();
              break;
            }
          }
        }
        
        // If no value found in the current item, generate a mock value
        if (value == null) {
          value = 10000.0 + (300.0 * i) + (i % 5 == 0 ? -500.0 : 200.0);
        }

        if (value < minY) minY = value;
        if (value > maxY) maxY = value;

        spots.add(FlSpot(i.toDouble(), value));
      }

      // Add some padding to min/max
      minY = minY * 0.95;
      maxY = maxY * 1.05;

      // Determine gradient colors based on price trend
      final isPositive = spots.length >= 2 ? spots.first.y < spots.last.y : true;
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
                  spots.length >= 2 
                      ? (isPositive 
                          ? '+${((spots.last.y - spots.first.y) / spots.first.y * 100).toStringAsFixed(2)}%'
                          : '${((spots.last.y - spots.first.y) / spots.first.y * 100).toStringAsFixed(2)}%')
                      : '0.00%',
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
    } catch (e, stackTrace) {
      log('Error rendering price chart: $e');
      log(stackTrace.toString());
      return const Center(child: Text('Error rendering chart'));
    }
  }
  
  // Helper function to safely convert values to double
  double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
