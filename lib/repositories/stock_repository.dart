import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:my_app/models/stock_model.dart';
import 'package:my_app/models/historical_data_model.dart';

class StockRepository {
  static const String baseUrl = "https://finnhub.io/api/v1";
  static const String apiKey = "d3n8e81r01qk65167tlgd3n8e81r01qk65167tm0";

  // API alternativa para logos
  static const String logoBaseUrl = "https://logo.clearbit.com";

  // Obtener precio actual de una acción
  Future<StockModel> fetchStocks(String symbol) async {
    try {
      final quoteUrl = Uri.parse('$baseUrl/quote?symbol=$symbol&token=$apiKey');
      final profileUrl = Uri.parse('$baseUrl/stock/profile2?symbol=$symbol&token=$apiKey');

      final quoteResponse = await http.get(quoteUrl);
      final profileResponse = await http.get(profileUrl);

      if (quoteResponse.statusCode != 200) {
        throw Exception('Error fetching quote data for $symbol');
      }

      final quoteData = json.decode(quoteResponse.body);
      final profileData = profileResponse.statusCode == 200 
          ? json.decode(profileResponse.body)
          : {};

      // Verificar si los datos de precio son válidos
      final currentPrice = (quoteData['c'] as num?)?.toDouble();
      final changePercent = (quoteData['dp'] as num?)?.toDouble();

      if (currentPrice == null || currentPrice == 0) {
        throw Exception('Invalid price data for $symbol');
      }

      // Obtener logo de ClearBit
      String? logoUrl;
      final companyName = profileData['name'] ?? '';
      if (companyName.isNotEmpty) {
        // Intentar obtener logo basado en el nombre de la compañía
        final domain = _getDomainFromCompanyName(companyName);
        if (domain != null) {
          logoUrl = '$logoBaseUrl/$domain';
          // Verificar si el logo existe
          final logoResponse = await http.head(Uri.parse(logoUrl));
          if (logoResponse.statusCode != 200) {
            logoUrl = null;
          }
        }
      }

      return StockModel(
        symbol: symbol,
        name: companyName.isNotEmpty ? companyName : _getCompanyNameFromSymbol(symbol),
        price: currentPrice,
        changePercent: changePercent ?? 0.0,
        dayHigh: (quoteData['h'] as num?)?.toDouble() ?? currentPrice,
        dayLow: (quoteData['l'] as num?)?.toDouble() ?? currentPrice,
        logoUrl: logoUrl,
      );
    } catch (e) {
      developer.log('Error fetching stock $symbol: $e');
      rethrow;
    }
  }

  // Método auxiliar para obtener dominio del nombre de la compañía
  String? _getDomainFromCompanyName(String companyName) {
    try {
      final Map<String, String> companyDomains = {
        'Apple': 'apple.com',
        'Microsoft': 'microsoft.com',
        'Google': 'google.com',
        'Amazon': 'amazon.com',
        'Tesla': 'tesla.com',
        'Meta Platforms': 'meta.com',
        'NVIDIA': 'nvidia.com',
        'Netflix': 'netflix.com',
        'Advanced Micro Devices': 'amd.com',
        'Intel': 'intel.com',
        'JPMorgan Chase': 'jpmorganchase.com',
        'Johnson & Johnson': 'jnj.com',
        'Visa': 'visa.com',
        'Mastercard': 'mastercard.com',
        'PayPal': 'paypal.com',
        'Bank of America': 'bankofamerica.com',
        'Walmart': 'walmart.com',
        'Disney': 'waltdisney.com',
        'Nike': 'nike.com',
        'Exxon': 'exxonmobil.com',
        'Coca-Cola': 'coca-colacompany.com',
        'McDonald\'s': 'mcdonalds.com',
        'Starbucks': 'starbucks.com',
      };

      for (final entry in companyDomains.entries) {
        if (companyName.contains(entry.key)) {
          return entry.value;
        }
      }

      // Si no encuentra coincidencia, intentar generar un dominio
      final cleanName = companyName
          .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
          .replaceAll(RegExp(r'\s+'), '')
          .toLowerCase();

      return '$cleanName.com';
    } catch (e) {
      return null;
    }
  }

  // Método auxiliar para obtener nombre de compañía del símbolo
  String _getCompanyNameFromSymbol(String symbol) {
    final Map<String, String> symbolToName = {
      'AAPL': 'Apple Inc.',
      'GOOGL': 'Alphabet Inc. (Google)',
      'MSFT': 'Microsoft Corporation',
      'AMZN': 'Amazon.com Inc.',
      'TSLA': 'Tesla Inc.',
      'META': 'Meta Platforms Inc.',
      'NVDA': 'NVIDIA Corporation',
      'NFLX': 'Netflix Inc.',
      'AMD': 'Advanced Micro Devices Inc.',
      'INTC': 'Intel Corporation',
      'JPM': 'JPMorgan Chase & Co.',
      'JNJ': 'Johnson & Johnson',
      'V': 'Visa Inc.',
      'MA': 'Mastercard Incorporated',
      'PYPL': 'PayPal Holdings Inc.',
      'BAC': 'Bank of America Corporation',
      'WMT': 'Walmart Inc.',
      'DIS': 'The Walt Disney Company',
      'NKE': 'Nike Inc.',
      'XOM': 'Exxon Mobil Corporation',
      'KO': 'The Coca-Cola Company',
      'MCD': 'McDonald\'s Corporation',
      'SBUX': 'Starbucks Corporation',
      'PEP': 'PepsiCo Inc.',
      'CSCO': 'Cisco Systems Inc.',
      'ORCL': 'Oracle Corporation',
      'IBM': 'International Business Machines',
      'T': 'AT&T Inc.',
      'VZ': 'Verizon Communications Inc.',
    };

    return symbolToName[symbol] ?? '$symbol Company';
  }

  // Obtener lista de acciones populares (versión mejorada)
  Future<List<StockModel>> fetchTrending() async {
    try {
      // Usar símbolos populares que sabemos que funcionan
      final popularSymbols = [
        'AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA', 
        'META', 'NVDA', 'JPM', 'JNJ', 'V',
        'MA', 'PYPL', 'BAC', 'WMT', 'DIS'
      ];
      
      final List<StockModel> stocks = [];
      
      for (final symbol in popularSymbols) {
        try {
          final stock = await fetchStocks(symbol);
          stocks.add(stock);
          developer.log('Successfully fetched: $symbol - \$${stock.price}');
          
          // Pausa más larga para evitar rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          developer.log('Error fetching data for $symbol: $e');
          // Si falla, crear un stock con datos de ejemplo para desarrollo
          stocks.add(StockModel(
            symbol: symbol,
            name: _getCompanyNameFromSymbol(symbol),
            price: _getMockPrice(symbol),
            changePercent: _getMockChangePercent(symbol),
            dayHigh: _getMockPrice(symbol) * 1.02,
            dayLow: _getMockPrice(symbol) * 0.98,
            logoUrl: null,
          ));
        }
      }
      
      return stocks;
    } catch (e) {
      developer.log('Error in fetchTrending: $e');
      // En caso de error general, devolver datos mock para desarrollo
      return _getMockStocks();
    }
  }

  // ===========================================================================
  // MÉTODOS PARA DATOS HISTÓRICOS (GRÁFICOS)
  // ===========================================================================

  // Obtener datos históricos de una acción (Candlestick data)
  Future<List<HistoricalData>> fetchHistoricalData(
    String symbol, 
    String resolution, 
    int from, 
    int to
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/stock/candle?symbol=$symbol&resolution=$resolution&from=$from&to=$to&token=$apiKey'
      );

      developer.log('Fetching historical data for $symbol: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['s'] == 'ok') {
          return _processCandleData(data);
        } else {
          throw Exception('No data available for $symbol');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Error fetching historical data for $symbol');
      }
    } catch (e) {
      developer.log('Error fetching historical data for $symbol: $e');
      rethrow;
    }
  }

  // Procesar datos de candlestick
  List<HistoricalData> _processCandleData(Map<String, dynamic> data) {
    final List<HistoricalData> candles = [];
    
    final timestamps = data['t'] as List? ?? []; // Timestamps
    final opens = data['o'] as List? ?? [];       // Open prices
    final highs = data['h'] as List? ?? [];       // High prices  
    final lows = data['l'] as List? ?? [];        // Low prices
    final closes = data['c'] as List? ?? [];      // Close prices
    final volumes = data['v'] as List? ?? [];     // Volumes

    developer.log('Processing ${timestamps.length} candlesticks');

    for (int i = 0; i < timestamps.length; i++) {
      try {
        candles.add(HistoricalData(
          
          date: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
          open: (opens[i] as num).toDouble(),
          high: (highs[i] as num).toDouble(),
          low: (lows[i] as num).toDouble(),
          close: (closes[i] as num).toDouble(),
          volume: (volumes[i] as num).toDouble(),
        ));
      } catch (e) {
        developer.log('Error processing candle data at index $i: $e');
      }
    }
    
    return candles;
  }

  // Método conveniente para obtener datos históricos con fechas por defecto
  Future<List<HistoricalData>> fetchHistoricalDataDefault(String symbol, String resolution) async {
    final to = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Calcular 'from' basado en la resolución
    int from;
    switch (resolution) {
      case '1': // 1 minuto - últimas 24 horas
        from = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;
        break;
      case '5': // 5 minutos - últimos 3 días
        from = DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch ~/ 1000;
        break;
      case 'D': // Diario - últimos 90 días
        from = DateTime.now().subtract(const Duration(days: 90)).millisecondsSinceEpoch ~/ 1000;
        break;
      case 'W': // Semanal - último año
        from = DateTime.now().subtract(const Duration(days: 365)).millisecondsSinceEpoch ~/ 1000;
        break;
      case 'M': // Mensual - últimos 5 años
        from = DateTime.now().subtract(const Duration(days: 1825)).millisecondsSinceEpoch ~/ 1000;
        break;
      default: // Por defecto, últimos 30 días
        from = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000;
    }

    return fetchHistoricalData(symbol, resolution, from, to);
  }

  // ===========================================================================
  // MÉTODOS AUXILIARES Y DATOS MOCK
  // ===========================================================================

  // Datos mock para desarrollo
  double _getMockPrice(String symbol) {
    final mockPrices = {
      'AAPL': 185.23,
      'MSFT': 378.85,
      'GOOGL': 138.21,
      'AMZN': 154.67,
      'TSLA': 248.42,
      'META': 353.96,
      'NVDA': 495.22,
      'JPM': 172.34,
      'JNJ': 155.78,
      'V': 259.13,
      'MA': 445.67,
      'PYPL': 62.34,
      'BAC': 33.45,
      'WMT': 165.78,
      'DIS': 92.34,
    };
    return mockPrices[symbol] ?? 100.0;
  }

  double _getMockChangePercent(String symbol) {
    final mockChanges = {
      'AAPL': 1.23,
      'MSFT': -0.45,
      'GOOGL': 2.15,
      'AMZN': -1.78,
      'TSLA': 3.42,
      'META': 0.89,
      'NVDA': 4.21,
      'JPM': -0.32,
      'JNJ': 0.67,
      'V': 1.45,
      'MA': 2.34,
      'PYPL': -2.15,
      'BAC': 0.89,
      'WMT': -0.56,
      'DIS': 1.23,
    };
    return mockChanges[symbol] ?? 0.5;
  }

  List<StockModel> _getMockStocks() {
    return [
      StockModel(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        price: 185.23,
        changePercent: 1.23,
        dayHigh: 186.50,
        dayLow: 183.75,
        logoUrl: 'https://logo.clearbit.com/apple.com',
      ),
      StockModel(
        symbol: 'MSFT',
        name: 'Microsoft Corporation',
        price: 378.85,
        changePercent: -0.45,
        dayHigh: 381.20,
        dayLow: 376.40,
        logoUrl: 'https://logo.clearbit.com/microsoft.com',
      ),
      StockModel(
        symbol: 'GOOGL',
        name: 'Alphabet Inc. (Google)',
        price: 138.21,
        changePercent: 2.15,
        dayHigh: 139.80,
        dayLow: 136.45,
        logoUrl: 'https://logo.clearbit.com/google.com',
      ),
      StockModel(
        symbol: 'AMZN',
        name: 'Amazon.com Inc.',
        price: 154.67,
        changePercent: -1.78,
        dayHigh: 157.89,
        dayLow: 153.45,
        logoUrl: 'https://logo.clearbit.com/amazon.com',
      ),
      StockModel(
        symbol: 'TSLA',
        name: 'Tesla Inc.',
        price: 248.42,
        changePercent: 3.42,
        dayHigh: 252.10,
        dayLow: 245.30,
        logoUrl: 'https://logo.clearbit.com/tesla.com',
      ),
    ];
  }

  // Método para buscar acciones por nombre o símbolo
  Future<List<StockModel>> searchStocks(String query) async {
    try {
      // Finnhub no tiene un endpoint de búsqueda gratuito, así que usamos una lista predefinida
      final allSymbols = [
        'AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA', 'META', 'NVDA', 'JPM', 'JNJ', 'V',
        'MA', 'PYPL', 'BAC', 'WMT', 'DIS', 'NFLX', 'AMD', 'INTC', 'NKE', 'XOM'
      ];
      
      final filteredSymbols = allSymbols.where((symbol) =>
        symbol.toLowerCase().contains(query.toLowerCase()) ||
        _getCompanyNameFromSymbol(symbol).toLowerCase().contains(query.toLowerCase())
      ).toList();

      final List<StockModel> results = [];
      
      for (final symbol in filteredSymbols.take(5)) { // Limitar a 5 resultados
        try {
          final stock = await fetchStocks(symbol);
          results.add(stock);
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          developer.log('Error fetching search result for $symbol: $e');
        }
      }
      
      return results;
    } catch (e) {
      developer.log('Error in searchStocks: $e');
      return [];
    }
  }

  // Método para obtener información fundamental de una acción
  Future<Map<String, dynamic>> fetchStockFundamentals(String symbol) async {
    try {
      final url = Uri.parse('$baseUrl/stock/metric?symbol=$symbol&metric=all&token=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error fetching fundamentals for $symbol');
      }
    } catch (e) {
      developer.log('Error fetching fundamentals for $symbol: $e');
      rethrow;
    }
  }
}