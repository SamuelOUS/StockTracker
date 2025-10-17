import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/stock_provider.dart';

import 'package:my_app/screens/user_form_page.dart';
import 'package:my_app/screens/user_search_page.dart';
import 'package:my_app/screens/user_delete_page.dart';
import 'package:my_app/screens/user_update_page.dart';
import 'package:my_app/screens/stock_analysis_page.dart';

import 'package:my_app/models/stock_model.dart';
import 'package:my_app/models/user_model.dart';

import 'package:my_app/components/bottom_nav_bar.dart'; 
class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<StockProvider>(context, listen: false).fetchTrending());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> pages = [
      _HomePage(provider: provider, screenWidth: screenWidth, screenHeight: screenHeight),
      const UserSearchPage(),
      const UserFormPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          Positioned.fill(child: pages[_selectedIndex]),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              currentIndex: _selectedIndex, 
              onTap: (index) {              
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  final StockProvider provider;
  final double screenWidth;
  final double screenHeight;

  const _HomePage({
    required this.provider,
    required this.screenWidth,
    required this.screenHeight,
  });

  Widget _buildSquareLogo(String symbol, String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            logoUrl,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildSquareDefaultIcon(symbol),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return _buildSquareDefaultIcon(symbol);
    }
  }

  Widget _buildSquareDefaultIcon(String symbol) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getColorFromSymbol(symbol),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol.length > 1 ? symbol.substring(0, 1) : symbol,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Color _getColorFromSymbol(String symbol) {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.red.shade700,
      Colors.teal.shade700,
      Colors.indigo.shade700,
      Colors.pink.shade700,
    ];
    final index = symbol.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }

  Widget _buildGrowthBar(double changePercent, bool isPositive) {
    final percentage = changePercent.abs();
    final maxBarHeight = 50.0;
    final barHeight = (percentage / 10).clamp(0.1, 1.0) * maxBarHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 6,
          height: barHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: isPositive
                  ? [Colors.green.shade300, Colors.green.shade600]
                  : [Colors.red.shade300, Colors.red.shade600],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${changePercent.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStockItem(
      BuildContext context, StockModel stock, bool isPositive) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockAnalysisPage(symbol: stock.symbol),
          ),
        );
      },
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildGrowthBar(stock.changePercent, isPositive),
            const SizedBox(height: 6),
            _buildSquareLogo(stock.symbol, stock.logoUrl),
            const SizedBox(height: 6),
            Text(
              stock.symbol,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '\$${stock.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStocksSection(
      String title, List<StockModel> stocks, bool isPositive, BuildContext context) {
    if (stocks.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isPositive ? Colors.green.shade100 : Colors.red.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                return _buildStockItem(context, stocks[index], isPositive);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trending = provider.trending;

    final positiveStocks =
        trending.where((stock) => stock.changePercent >= 0).toList();
    final negativeStocks =
        trending.where((stock) => stock.changePercent < 0).toList();

    positiveStocks.sort((a, b) => b.changePercent.compareTo(a.changePercent));
    negativeStocks.sort((a, b) => a.changePercent.compareTo(b.changePercent));

    final topPositiveStocks = positiveStocks.take(5).toList();
    final topNegativeStocks = negativeStocks.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.10),
                    Text(
                      'Welcome Samuel',
                      style: TextStyle(
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
              _buildStocksSection('Top Gainers', topPositiveStocks, true, context),
              _buildStocksSection('Top Losers', topNegativeStocks, false, context),
            ],
          ),
        ),
      ),
    );
  }
}
