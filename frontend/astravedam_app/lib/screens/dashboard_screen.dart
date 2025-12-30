import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> userChart;
  
  const DashboardScreen({super.key, required this.userChart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text('Astravedam'),
        backgroundColor: Colors.deepPurple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              _showProfileDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildMainFeaturesGrid(context),
              const SizedBox(height: 24),
              _buildTodaysGuidance(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

 Widget _buildWelcomeSection() {
  // DEBUG: Check what data we have
  print('=== DEBUG WELCOME SECTION ===');
  print('UserChart keys: ${userChart.keys.toList()}');
  print('Has locationData?: ${userChart.containsKey('locationData')}');
  print('Full userChart: $userChart');
  
  final locationData = userChart['locationData'] ?? {};
  print('LocationData: $locationData');
  print('City: ${locationData['city']}');
  print('Country: ${locationData['country']}');
  // Add debug to verify

  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.self_improvement,
              color: Colors.deepPurple[600],
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${userChart['name'] ?? 'User'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                  ),
                ),
                const SizedBox(height: 4),
                if (locationData['city'] != null)
                  Text(
                    'Born in ${locationData['city']}, ${locationData['country']}',
                    style: TextStyle(
                      color: Colors.deepPurple[600],
                      fontSize: 12,
                    ),
                  ),
                Text(
                  'Your cosmic journey begins here...',
                  style: TextStyle(
                    color: Colors.deepPurple[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.amber[700],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Credits: 5',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMainFeaturesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Spiritual Tools',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: [
            _buildFeatureCard(
              context,
              Icons.calendar_today,
              'Daily Horoscope',
              'Free',
              Colors.blue,
              () {
                _showComingSoon(context, 'Daily Horoscope');
              },
            ),
            _buildFeatureCard(
              context,
              Icons.pie_chart,
              'Your Kundali',
              'Free',
              Colors.green,
              () {
                _showKundaliDetails(context);
              },
            ),
            _buildFeatureCard(
              context,
              Icons.self_improvement,
              'Ask Gods',
              '3 Questions',
              Colors.purple,
              () {
                _showComingSoon(context, 'Ask Gods');
              },
            ),
            _buildFeatureCard(
              context,
              Icons.work,
              'Career Reading',
              '2 Credits',
              Colors.orange,
              () {
                _showCreditRequiredDialog(context, 'Career Reading', 2);
              },
            ),
            _buildFeatureCard(
              context,
              Icons.favorite,
              'Love Match',
              '2 Credits',
              Colors.pink,
              () {
                _showCreditRequiredDialog(context, 'Love Match', 2);
              },
            ),
            _buildFeatureCard(
              context,
              Icons.attach_money,
              'Wealth Reading',
              '2 Credits',
              Colors.green,
              () {
                _showCreditRequiredDialog(context, 'Wealth Reading', 2);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: subtitle == 'Free' ? Colors.green[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitle == 'Free' ? Colors.green[700] : Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysGuidance() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 8),
                Text(
                  "Today's Guidance",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGuidanceItem('Career', 'Good time for new projects and networking.'),
                  _buildGuidanceItem('Health', 'Focus on balanced diet and regular exercise.'),
                  _buildGuidanceItem('Spiritual', 'Meditate during Brahma Muhurta for best results.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceItem(String category, String advice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $category: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple[700],
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              advice,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Buy Credits',
                Icons.workspace_premium,
                Colors.purple,
                () {
                  _showCreditsStore(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Learn More',
                Icons.menu_book,
                Colors.blue,
                () {
                  _showComingSoon(context, 'Learn Section');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple[600],
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.self_improvement),
          label: 'Ask Gods',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.workspace_premium),
          label: 'Credits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Learn',
        ),
      ],
      onTap: (index) {
        _handleBottomNavTap(context, index);
      },
    );
  }

  void _handleBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        _showComingSoon(context, 'Ask Gods');
        break;
      case 2:
        _showCreditsStore(context);
        break;
      case 3:
        _showComingSoon(context, 'Learn Section');
        break;
    }
  }

void _showKundaliDetails(BuildContext context) {
  // ✅ SAFE data access with location data
  final chartData = userChart['chart'] ?? userChart;
  final locationData = userChart['locationData'] ?? {};
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Your Kundali Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location Information
              if (locationData['formattedAddress'] != null)
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📍 Birth Location:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(locationData['formattedAddress'] ?? ''),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Timezone: ${locationData['timezone'] ?? 'UTC'}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Coords: ${locationData['coordinates']?['lat']?.toStringAsFixed(4) ?? '0'}, '
                                 '${locationData['coordinates']?['lng']?.toStringAsFixed(4) ?? '0'}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Kundali Details
              const Text(
                '🧘‍♂️ Vedic Birth Chart:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Planet')),
                  DataColumn(label: Text('Rashi')),
                  DataColumn(label: Text('Nakshatra')),
                ],
                rows: [
                  _buildPlanetRow('Sun', chartData['planets']?['sun']),
                  _buildPlanetRow('Moon', chartData['planets']?['moon']),
                  _buildPlanetRow('Mars', chartData['planets']?['mars']),
                ],
              ),
              
              const SizedBox(height: 12),
              Text('Lagna: ${chartData['lagna'] ?? 'Not available'}'),
              const SizedBox(height: 8),
              
              if (chartData['summary'] != null)
                Text(
                  chartData['summary'] ?? '',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

// Helper method for planet rows
DataRow _buildPlanetRow(String planetName, Map<String, dynamic>? planetData) {
  return DataRow(
    cells: [
      DataCell(Text(planetName)),
      DataCell(Text(planetData?['rashi'] ?? '--')),
      DataCell(Text(planetData?['nakshatra'] ?? '--')),
    ],
  );
}

void _showProfileDialog(BuildContext context) {
  final chartData = userChart['chart'] ?? userChart;
  final locationData = userChart['locationData'] ?? {};
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Your Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(userChart['name'] ?? 'User'),
                subtitle: const Text('Registered User'),
              ),
              
              const SizedBox(height: 16),
              const Text(
                'Birth Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Date: ${_formatDate(chartData['birthDate'])}'),
              Text('Time: ${chartData['birthTime'] ?? 'Not specified'}'),
              
              // Show geocoded location if available
              if (locationData['formattedAddress'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Place: ${locationData['formattedAddress']}'),
                    Text('Timezone: ${locationData['timezone'] ?? 'UTC'}'),
                  ],
                )
              else
                Text('Place: ${chartData['location'] ?? 'Not specified'}'),
              
              const SizedBox(height: 16),
              const Text(
                'Kundali Summary:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Lagna: ${chartData['lagna'] ?? 'Not available'}'),
              Text('Sun: ${chartData['planets']?['sun']?['rashi'] ?? '--'}'),
              Text('Moon: ${chartData['planets']?['moon']?['rashi'] ?? '--'}'),
              
              if (chartData['summary'] != null) ...[
                const SizedBox(height: 16),
                Text(
                  chartData['summary'] ?? '',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

// Helper method to format date
String _formatDate(dynamic date) {
  if (date == null) return 'Not specified';
  if (date is String) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return date.toString();
    }
  }
  return date.toString();
}

  void _showCreditRequiredDialog(BuildContext context, String feature, int credits) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$feature Required'),
          content: Text('This feature requires $credits credits. You currently have 5 credits.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessDialog(context, feature);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Use $credits Credits'),
            ),
          ],
        );
      },
    );
  }

  void _showCreditsStore(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Purchase Credits'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCreditPackage(context, '5 Credits', '₹199', 'For casual use'),
                const SizedBox(height: 12),
                _buildCreditPackage(context, '10 Credits', '₹349', 'For regular use'),
                const SizedBox(height: 12),
                _buildCreditPackage(context, '20 Credits', '₹599', 'Best value'),
                const SizedBox(height: 12),
                _buildCreditPackage(context, '50 Credits', '₹1299', 'For power users'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreditPackage(BuildContext context, String credits, String price, String description) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              credits,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSuccessDialog(context, credits);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success!'),
          content: Text('You have successfully accessed $feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Great!'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coming Soon!'),
          content: Text('$feature is under development. Stay tuned!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}