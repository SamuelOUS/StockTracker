// lib/screens/indicators_help_page.dart
import 'package:flutter/material.dart';

class IndicatorsHelpPage extends StatelessWidget {
  const IndicatorsHelpPage({super.key});

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
        title: const Text(
          'Guía de Indicadores',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Estadísticas Básicas'),
          _buildIndicatorCard(
            title: 'Media (Promedio)',
            icon: Icons.trending_flat,
            color: Colors.blue,
            description: 'Es el precio promedio de la acción durante el período seleccionado.',
            interpretation: 'Te ayuda a entender el precio "típico" de la acción. Si el precio actual está muy por encima o debajo de la media, puede indicar una oportunidad o riesgo.',
            example: 'Si la media es \$50 y el precio actual es \$60, la acción está 20% por encima de su promedio.',
          ),
          
          _buildIndicatorCard(
            title: 'Desviación Estándar',
            icon: Icons.show_chart,
            color: Colors.orange,
            description: 'Mide cuánto varían los precios respecto al promedio.',
            interpretation: 'Una desviación alta significa precios muy variables (más riesgo). Una baja significa precios estables (menos riesgo).',
            example: 'Si es \$5, los precios típicamente varían ±\$5 del promedio.',
          ),
          
          _buildIndicatorCard(
            title: 'Volatilidad',
            icon: Icons.warning_amber,
            color: Colors.red,
            description: 'Porcentaje de variación del precio anualizado.',
            interpretation: 'Alta volatilidad (>30%) = mayor riesgo y oportunidad. Baja volatilidad (<15%) = más estable pero menos oportunidades de ganancia rápida.',
            example: 'Volatilidad de 25% significa que en un año el precio podría variar ±25%.',
          ),
          
          _buildIndicatorCard(
            title: 'Rango',
            icon: Icons.height,
            color: Colors.green,
            description: 'Diferencia entre el precio más alto y más bajo del período.',
            interpretation: 'Un rango amplio indica grandes fluctuaciones de precio. Útil para identificar oportunidades de trading.',
            example: 'Rango de \$15 = diferencia entre el máximo y mínimo del período.',
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Indicadores Técnicos'),
          
          _buildIndicatorCard(
            title: 'SMA (Media Móvil Simple)',
            icon: Icons.insights,
            color: Colors.purple,
            description: 'Promedio de precios de los últimos N días (20 o 50).',
            interpretation: '''
• SMA(20): Tendencia a corto plazo
• SMA(50): Tendencia a mediano plazo
• Precio > SMA = Tendencia alcista
• Precio < SMA = Tendencia bajista
• Cuando SMA(20) cruza por encima de SMA(50) es señal de compra''',
            example: 'Si SMA(20) = \$52 y precio actual = \$55, la tendencia es positiva.',
          ),
          
          _buildIndicatorCard(
            title: 'RSI (Índice de Fuerza Relativa)',
            icon: Icons.speed,
            color: Colors.indigo,
            description: 'Mide la fuerza del movimiento del precio en una escala de 0-100.',
            interpretation: '''
• RSI > 70: Sobrecompra (posible caída próxima)
• RSI < 30: Sobreventa (posible subida próxima)
• RSI 40-60: Neutral, sin señales claras
• Útil para identificar puntos de entrada/salida''',
            example: 'RSI = 75 sugiere que la acción podría bajar pronto (está "cara").',
          ),
          
          _buildIndicatorCard(
            title: 'Coeficiente de Variación',
            icon: Icons.percent,
            color: Colors.teal,
            description: 'Relación entre desviación estándar y media (riesgo relativo).',
            interpretation: '''
• < 15%: Baja variabilidad relativa
• 15-30%: Variabilidad moderada
• > 30%: Alta variabilidad relativa
Útil para comparar riesgo entre acciones de diferentes precios.''',
            example: 'CV = 8% indica que la acción es relativamente estable.',
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Rendimiento'),
          
          _buildIndicatorCard(
            title: 'Rendimiento del Período',
            icon: Icons.trending_up,
            color: Colors.green.shade700,
            description: 'Cambio porcentual del precio entre el inicio y fin del período.',
            interpretation: '''
• Positivo (+): Ganancia en el período
• Negativo (-): Pérdida en el período
• Compara con índices de mercado para ver si superó al promedio''',
            example: '+15.5% significa que ganaste 15.5% si compraste al inicio del período.',
          ),
          
          const SizedBox(height: 24),
          _buildTipsCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildIndicatorCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required String interpretation,
    String? example,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoSection('¿Qué es?', description),
          const SizedBox(height: 12),
          _buildInfoSection('¿Cómo interpretarlo?', interpretation),
          if (example != null) ...[
            const SizedBox(height: 12),
            _buildInfoSection('Ejemplo', example, isExample: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String content, {bool isExample = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isExample ? Colors.blue.shade700 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Consejos Importantes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Nunca uses un solo indicador para tomar decisiones'),
          _buildTipItem('Combina análisis técnico con análisis fundamental'),
          _buildTipItem('Los indicadores pasados no garantizan resultados futuros'),
          _buildTipItem('Considera el contexto del mercado general'),
          _buildTipItem('Establece límites de pérdida (stop-loss) siempre'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}