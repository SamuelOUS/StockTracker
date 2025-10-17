class StockModel {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final double dayHigh;
  final double dayLow;
  final String? logoUrl;

  StockModel({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.dayHigh,
    required this.dayLow,
    this.logoUrl,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
      dayHigh: (json['dayHigh'] as num?)?.toDouble() ?? 0.0,
      dayLow: (json['dayLow'] as num?)?.toDouble() ?? 0.0,
      logoUrl: json['logoUrl'] ?? '',
    );
  }

  // Método para determinar el color basado en el cambio porcentual
  bool get isPositiveChange => changePercent >= 0;
}