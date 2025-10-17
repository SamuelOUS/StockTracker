// lib/screens/stock_analysis_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/historical_data_provider.dart';
import 'package:my_app/providers/stock_provider.dart';
import 'package:my_app/models/historical_data_model.dart';
import 'package:my_app/screens/indicators_help_page.dart';
import 'dart:math' as math;

class StockAnalysisPage extends StatefulWidget {
  final String symbol;

  const StockAnalysisPage({super.key, required this.symbol});

  @override
  State<StockAnalysisPage> createState() => _StockAnalysisPageState();
}

class _StockAnalysisPageState extends State<StockAnalysisPage> {
  String _selectedTimeframe = '1M';
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    final histProvider = Provider.of<HistoricalDataProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    
    try {
      await Future.wait([
        histProvider.fetchHistoricalData(widget.symbol, _selectedTimeframe),
        stockProvider.fetchStock(widget.symbol),
      ]);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  void _changeTimeframe(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    
    final histProvider = Provider.of<HistoricalDataProvider>(context, listen: false);
    histProvider.fetchHistoricalData(widget.symbol, timeframe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.symbol,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IndicatorsHelpPage(),
            ),
          );
        },
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.help_outline, color: Colors.white),
        label: const Text(
          '¿Qué significan?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Consumer2<HistoricalDataProvider, StockProvider>(
              builder: (context, histProvider, stockProvider, _) {
                final stock = stockProvider.selectedStock;
                final data = histProvider.historicalData;

                if (histProvider.isLoading || stockProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando datos históricos...'),
                      ],
                    ),
                  );
                }

                if (histProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar datos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            histProvider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (stock == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontró ${widget.symbol}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final stats = data.isNotEmpty ? _calculateStatistics(data) : <String, double>{};

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStockHeader(stock),
                      const SizedBox(height: 20),
                      if (data.isNotEmpty) _buildDataInfoBanner(data),
                      const SizedBox(height: 20),
                      _buildTimeframeSelector(),
                      const SizedBox(height: 20),
                      if (data.isNotEmpty) ...[
                        _buildPriceChart(data),
                        const SizedBox(height: 20),
                        _buildVolumeChart(data),
                        const SizedBox(height: 20),
                        _buildStatisticsCards(stats),
                        const SizedBox(height: 20),
                        _buildTechnicalIndicators(data, stats),
                        const SizedBox(height: 20),
                        _buildPriceRangeInfo(data),
                        const SizedBox(height: 80), // Espacio para el botón flotante
                      ] else ...[
                        _buildNoDataMessage(),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStockHeader(stock) {
    final isPositive = stock.changePercent >= 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stock.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${stock.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                      color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stock.changePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetric('High', '\$${stock.dayHigh.toStringAsFixed(2)}', Colors.green),
              const SizedBox(width: 20),
              _buildMetric('Low', '\$${stock.dayLow.toStringAsFixed(2)}', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataInfoBanner(List<HistoricalData> data) {
    final firstDate = data.first.date;
    final lastDate = data.last.date;
    final daysDiff = lastDate.difference(firstDate).inDays;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${data.length} puntos de datos reales • ${daysDiff} días',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos históricos disponibles',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar el período de tiempo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    final timeframes = [
      {'label': '1D', 'value': '1D'},
      {'label': '1W', 'value': '1W'},
      {'label': '1M', 'value': '1M'},
      {'label': '3M', 'value': '3M'},
      {'label': '1Y', 'value': '1Y'},
    ];

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: timeframes.map((tf) {
          final isSelected = _selectedTimeframe == tf['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () => _changeTimeframe(tf['value']!),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tf['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceChart(List<HistoricalData> data) {
    if (data.isEmpty) return const SizedBox();

    final maxPrice = data.map((e) => e.high).reduce(math.max);
    final minPrice = data.map((e) => e.low).reduce(math.min);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Precio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Max: \$${maxPrice.toStringAsFixed(2)} | Min: \$${minPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: Size.infinite,
              painter: _PriceChartPainter(data, minPrice, maxPrice),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeChart(List<HistoricalData> data) {
    if (data.isEmpty) return const SizedBox();

    final maxVolume = data.map((e) => e.volume).reduce(math.max);
    final avgVolume = data.map((e) => e.volume).reduce((a, b) => a + b) / data.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Volumen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Promedio: ${_formatVolume(avgVolume)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: Size.infinite,
              painter: _VolumeChartPainter(data, maxVolume),
            ),
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  Widget _buildStatisticsCards(Map<String, double> stats) {
    if (stats.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard('Media', '\$${stats['mean']!.toStringAsFixed(2)}', Icons.trending_flat, Colors.blue),
            _buildStatCard('Desv. Est.', '\$${stats['stdDev']!.toStringAsFixed(2)}', Icons.show_chart, Colors.orange),
            _buildStatCard('Volatilidad', '${stats['volatility']!.toStringAsFixed(2)}%', Icons.warning_amber, Colors.red),
            _buildStatCard('Rango', '\$${stats['range']!.toStringAsFixed(2)}', Icons.height, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalIndicators(List<HistoricalData> data, Map<String, double> stats) {
    if (stats.isEmpty) return const SizedBox();
    
    final sma20 = _calculateSMA(data, 20);
    final sma50 = _calculateSMA(data, 50);
    final rsi = _calculateRSI(data, 14);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indicadores Técnicos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildIndicatorRow('SMA (20)', sma20 != null ? '\$${sma20.toStringAsFixed(2)}' : 'N/A', _getRSIColor(sma20)),
          const Divider(),
          _buildIndicatorRow('SMA (50)', sma50 != null ? '\$${sma50.toStringAsFixed(2)}' : 'N/A', _getRSIColor(sma50)),
          const Divider(),
          _buildIndicatorRow('RSI (14)', rsi != null ? rsi.toStringAsFixed(2) : 'N/A', _getRSIColor(rsi)),
          const Divider(),
          _buildIndicatorRow('Coef. Variación', '${(stats['cv']! * 100).toStringAsFixed(2)}%', Colors.black87),
        ],
      ),
    );
  }

  Color _getRSIColor(double? value) {
    if (value == null) return Colors.black87;
    if (value > 70) return Colors.red.shade700;
    if (value < 30) return Colors.green.shade700;
    return Colors.black87;
  }

  Widget _buildIndicatorRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeInfo(List<HistoricalData> data) {
    final firstPrice = data.first.close;
    final lastPrice = data.last.close;
    final change = lastPrice - firstPrice;
    final changePercent = (change / firstPrice) * 100;
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rendimiento del período',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 48,
            color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateStatistics(List<HistoricalData> data) {
    if (data.isEmpty) return {};

    final prices = data.map((e) => e.close).toList();
    final mean = prices.reduce((a, b) => a + b) / prices.length;
    final variance = prices.map((p) => math.pow(p - mean, 2)).reduce((a, b) => a + b) / prices.length;
    final stdDev = math.sqrt(variance);
    final volatility = (stdDev / mean) * math.sqrt(252) * 100;
    final maxPrice = prices.reduce(math.max);
    final minPrice = prices.reduce(math.min);
    final range = maxPrice - minPrice;
    final cv = stdDev / mean;

    return {
      'mean': mean,
      'stdDev': stdDev,
      'volatility': volatility,
      'range': range,
      'cv': cv,
    };
  }

  double? _calculateSMA(List<HistoricalData> data, int period) {
    if (data.length < period) return null;
    final recentPrices = data.reversed.take(period).map((e) => e.close).toList();
    return recentPrices.reduce((a, b) => a + b) / period;
  }

  double? _calculateRSI(List<HistoricalData> data, int period) {
    if (data.length < period + 1) return null;

    final changes = <double>[];
    for (int i = 1; i < data.length; i++) {
      changes.add(data[i].close - data[i - 1].close);
    }

    final recentChanges = changes.reversed.take(period).toList();
    final gains = recentChanges.where((c) => c > 0).toList();
    final losses = recentChanges.where((c) => c < 0).map((c) => c.abs()).toList();

    final avgGain = gains.isEmpty ? 0.0 : gains.reduce((a, b) => a + b) / period;
    final avgLoss = losses.isEmpty ? 0.0 : losses.reduce((a, b) => a + b) / period;

    if (avgLoss == 0) return 100;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }
}

class _PriceChartPainter extends CustomPainter {
  final List<HistoricalData> data;
  final double minPrice;
  final double maxPrice;

  _PriceChartPainter(this.data, this.minPrice, this.maxPrice);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final priceRange = maxPrice - minPrice;
    if (priceRange == 0) return;
    
    // Línea principal
    final linePaint = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].close - minPrice) / priceRange) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Área bajo la curva con gradiente
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue.withOpacity(0.3),
        Colors.blue.withOpacity(0.05),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _VolumeChartPainter extends CustomPainter {
  final List<HistoricalData> data;
  final double maxVolume;

  _VolumeChartPainter(this.data, this.maxVolume);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxVolume == 0) return;

    final barWidth = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i].volume / maxVolume) * size.height;
      final x = i * barWidth;
      final y = size.height - barHeight;

      final isPositive = i > 0 ? data[i].close >= data[i - 1].close : true;
      final paint = Paint()
        ..color = (isPositive ? Colors.green : Colors.red).withOpacity(0.7)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(x + barWidth * 0.1, y, barWidth * 0.8, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}