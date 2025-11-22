import 'package:flutter/material.dart';

class ChartResultsScreen extends StatelessWidget {
  final Map<String, dynamic> chartData;
  
  const ChartResultsScreen({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text('Your Birth Chart'),
        backgroundColor: Colors.deepPurple[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Chart Visualization Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart,
                      size: 50,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Birth Chart Visualization',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('(Coming Soon)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Planetary Positions
            _buildPlanetaryPositions(),
            const SizedBox(height: 20),
            
            // Houses
            _buildHouses(),
            const SizedBox(height: 20),
            
            // Summary
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetaryPositions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🪐 Planetary Positions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            const SizedBox(height: 10),
            // We'll add real data later
            _buildPlanetRow('Sun', 'Leo', 'Magha'),
            _buildPlanetRow('Moon', 'Cancer', 'Pushya'),
            _buildPlanetRow('Mars', 'Aries', 'Ashwini'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetRow(String planet, String sign, String nakshatra) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            planet,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            '$sign • $nakshatra',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildHouses() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏠 Houses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            const SizedBox(height: 10),
            _buildHouseRow(1, 'Aries', 'Mars'),
            _buildHouseRow(2, 'Taurus', 'Venus'),
            _buildHouseRow(3, 'Gemini', 'Mercury'),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseRow(int house, String sign, String lord) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            'House $house',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            '$sign (Lord: $lord)',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📜 Chart Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your chart shows strong leadership qualities with a focus on spiritual growth and material success. The planetary positions indicate potential for success in creative fields.',
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}