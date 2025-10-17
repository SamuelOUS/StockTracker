// lib/providers/stock_provider.dart
import 'package:flutter/material.dart';
import 'package:my_app/models/stock_model.dart';
import 'package:my_app/repositories/stock_repository.dart';

class StockProvider extends ChangeNotifier {
  final StockRepository _repo = StockRepository();

  List<StockModel> _trending = [];
  StockModel? _selectedStock;
  bool _isLoading = false;

  List<StockModel> get trending => _trending;
  StockModel? get selectedStock => _selectedStock;
  bool get isLoading => _isLoading;

  // 🔹 Obtener acciones populares
  Future<void> fetchTrending() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trending = await _repo.fetchTrending();
    } catch (e) {
      debugPrint('Error fetching trending stocks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Buscar una acción por símbolo
  Future<void> fetchStock(String symbol) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedStock = await _repo.fetchStocks(symbol);
    } catch (e) {
      debugPrint('Error fetching stock: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelected() {
    _selectedStock = null;
    notifyListeners();
  }
}
