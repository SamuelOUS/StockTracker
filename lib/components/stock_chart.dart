// lib/components/stock_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_app/models/historical_data_model.dart';

class StockChart extends StatelessWidget {
  final List<HistoricalData> data;
  final String symbol;

  const StockChart({
    super.key,
    required this.data,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: data.length.toDouble() - 1,
          minY: _getMinPrice(),
          maxY: _getMaxPrice(),
          lineBarsData: [
            LineChartBarData(
              spots: _getDataPoints(),
              isCurved: true,
              color: _getLineColor(),
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getDataPoints() {
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.close);
    }).toList();
  }

  double _getMinPrice() {
    if (data.isEmpty) return 0;
    return data.map((e) => e.low).reduce((a, b) => a < b ? a : b) * 0.98;
  }

  double _getMaxPrice() {
    if (data.isEmpty) return 100;
    return data.map((e) => e.high).reduce((a, b) => a > b ? a : b) * 1.02;
  }

  Color _getLineColor() {
    if (data.length < 2) return Colors.blue;
    final firstPrice = data.first.close;
    final lastPrice = data.last.close;
    return lastPrice >= firstPrice ? Colors.green : Colors.red;
  }
}