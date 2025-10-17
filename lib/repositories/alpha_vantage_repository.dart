// lib/repositories/alpha_vantage_repository.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:my_app/models/historical_data_model.dart';

class AlphaVantageRepository {
 
  static const String apiKey = "TM3M6E61E4R4YCO0S"; 
  static const String baseUrl = "https://www.alphavantage.co/query";


  Future<List<HistoricalData>> fetchDailyData(
    String symbol, {
    String outputsize = 'compact',
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl?function=TIME_SERIES_DAILY'
        '&symbol=$symbol'
        '&outputsize=$outputsize'
        '&apikey=$apiKey'
      );

      developer.log('Fetching Alpha Vantage data: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verificar errores de la API
        if (data.containsKey('Error Message')) {
          throw Exception('Symbol not found: $symbol');
        }

        if (data.containsKey('Note')) {
          throw Exception('API call frequency limit reached. Try again later.');
        }

        if (!data.containsKey('Time Series (Daily)')) {
          throw Exception('Invalid response format');
        }

        return _parseDailyData(data['Time Series (Daily)']);
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to fetch data');
      }
    } catch (e) {
      developer.log('Error fetching Alpha Vantage data: $e');
      rethrow;
    }
  }


  Future<List<HistoricalData>> fetchIntradayData(
    String symbol, {
    String interval = '5min',
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl?function=TIME_SERIES_INTRADAY'
        '&symbol=$symbol'
        '&interval=$interval'
        '&apikey=$apiKey'
      );

      developer.log('Fetching intraday data: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('Error Message')) {
          throw Exception('Symbol not found: $symbol');
        }

        if (data.containsKey('Note')) {
          throw Exception('API call limit reached');
        }

        final timeSeriesKey = 'Time Series ($interval)';
        if (!data.containsKey(timeSeriesKey)) {
          throw Exception('Invalid response format');
        }

        return _parseIntradayData(data[timeSeriesKey]);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching intraday data: $e');
      rethrow;
    }
  }


  Future<List<HistoricalData>> fetchWeeklyData(String symbol) async {
    try {
      final url = Uri.parse(
        '$baseUrl?function=TIME_SERIES_WEEKLY'
        '&symbol=$symbol'
        '&apikey=$apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('Error Message')) {
          throw Exception('Symbol not found: $symbol');
        }

        if (!data.containsKey('Weekly Time Series')) {
          throw Exception('Invalid response format');
        }

        return _parseDailyData(data['Weekly Time Series']);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching weekly data: $e');
      rethrow;
    }
  }


  Future<List<HistoricalData>> fetchMonthlyData(String symbol) async {
    try {
      final url = Uri.parse(
        '$baseUrl?function=TIME_SERIES_MONTHLY'
        '&symbol=$symbol'
        '&apikey=$apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('Error Message')) {
          throw Exception('Symbol not found: $symbol');
        }

        if (!data.containsKey('Monthly Time Series')) {
          throw Exception('Invalid response format');
        }

        return _parseDailyData(data['Monthly Time Series']);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching monthly data: $e');
      rethrow;
    }
  }


  List<HistoricalData> _parseDailyData(Map<String, dynamic> timeSeries) {
    final List<HistoricalData> dataList = [];

    timeSeries.forEach((dateStr, values) {
      try {
        final date = DateTime.parse(dateStr);
        final open = double.parse(values['1. open']);
        final high = double.parse(values['2. high']);
        final low = double.parse(values['3. low']);
        final close = double.parse(values['4. close']);
        final volume = double.parse(values['5. volume']);

        dataList.add(HistoricalData(
          date: date,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ));
      } catch (e) {
        developer.log('Error parsing data point: $e');
      }
    });

    dataList.sort((a, b) => a.date.compareTo(b.date));

    return dataList;
  }


  List<HistoricalData> _parseIntradayData(Map<String, dynamic> timeSeries) {
    final List<HistoricalData> dataList = [];

    timeSeries.forEach((dateTimeStr, values) {
      try {
        final dateTime = DateTime.parse(dateTimeStr);
        final open = double.parse(values['1. open']);
        final high = double.parse(values['2. high']);
        final low = double.parse(values['3. low']);
        final close = double.parse(values['4. close']);
        final volume = double.parse(values['5. volume']);

        dataList.add(HistoricalData(
          date: dateTime,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ));
      } catch (e) {
        developer.log('Error parsing intraday data: $e');
      }
    });

    dataList.sort((a, b) => a.date.compareTo(b.date));

    return dataList;
  }

  Future<List<HistoricalData>> fetchHistoricalData(
    String symbol,
    String timeframe,
  ) async {
    switch (timeframe) {
      case '1D':
        return fetchIntradayData(symbol, interval: '5min');
      case '1W':
        return fetchDailyData(symbol, outputsize: 'compact');
      case '1M':
        return fetchDailyData(symbol, outputsize: 'compact');
      case '3M':
        return fetchDailyData(symbol, outputsize: 'full');
      case '1Y':
        return fetchWeeklyData(symbol);
      default:
        return fetchDailyData(symbol, outputsize: 'compact');
    }
  }
}

