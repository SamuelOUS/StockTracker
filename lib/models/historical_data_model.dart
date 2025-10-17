// lib/models/historical_data_model.dart
class HistoricalData {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  HistoricalData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory HistoricalData.fromJson(Map<String, dynamic> json) {
    return HistoricalData(
      date: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }
}