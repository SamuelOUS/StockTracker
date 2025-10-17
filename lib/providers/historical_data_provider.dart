// lib/providers/historical_data_provider.dart
import 'package:flutter/material.dart';
import 'package:my_app/models/historical_data_model.dart';
import 'package:my_app/repositories/alpha_vantage_repository.dart'; // ✅ CAMBIAR ESTO

class HistoricalDataProvider extends ChangeNotifier {
  final AlphaVantageRepository _repo = AlphaVantageRepository(); // ✅ CAMBIAR ESTO
   
  List<HistoricalData> _historicalData = [];
  bool _isLoading = false;
  String _selectedSymbol = '';
  String? _error;
 
  List<HistoricalData> get historicalData => _historicalData;
  bool get isLoading => _isLoading;
  String get selectedSymbol => _selectedSymbol;
  String? get error => _error;

  Future<void> fetchHistoricalData(String symbol, String timeframe) async {
    _isLoading = true;
    _selectedSymbol = symbol;
    _error = null;
    notifyListeners();

    try {
      final data = await _repo.fetchHistoricalData(symbol, timeframe);
      _historicalData = data;
      
      debugPrint('✅ Successfully fetched ${data.length} data points for $symbol');
    } catch (e) {
      debugPrint('❌ Error fetching historical data: $e');
      _error = e.toString();
      _historicalData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _historicalData = [];
    _selectedSymbol = '';
    _error = null;
    notifyListeners();
  }
}