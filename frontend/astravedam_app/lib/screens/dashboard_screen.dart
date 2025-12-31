import 'package:flutter/material.dart';
import 'dart:convert';  // For json.decode
import 'package:http/http.dart' as http;  // For API calls
import '../services/identity_service.dart';  // For userId
import 'birth_data_screen.dart';  // ✅ ADD THIS LINE
import '../services/auth_service.dart';  // ADD THIS
import 'login_screen.dart';  // ADD THIS LINE

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userChart;
  
  const DashboardScreen({super.key, required this.userChart});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

    // ✅ ADD THIS VARIABLE
  int _refreshCounter = 0;
  
  // ✅ ADD THIS METHOD
  void _refreshKundaliList() {
    setState(() {
      _refreshCounter++;
      print('🔄 Refreshing kundali list (counter: $_refreshCounter)');
    });
  }
    
void _showAddKundaliDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Kundali'),
        content: const Text('Add birth chart for another person (family member, friend, etc.)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // ✅ Navigate and wait for result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BirthDataScreen(
                    isAdditionalKundali: true,
                  ),
                ),
              );
              
              // ✅ Refresh when we come back
              if (result == true) {
                _refreshKundaliList();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Now'),
          ),
        ],
      );
    },
  );
}

void _logout(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await AuthService.logout();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logged out successfully'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
          ),
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _showLoginRequiredDialog(BuildContext context, String featureName, int credits) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Login Required for $featureName'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('This feature requires login and $credits credit${credits > 1 ? 's' : ''}.'),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text('Cost: $credits credit${credits > 1 ? 's' : ''}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.account_circle, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 8),
              const Text('Requires registered account'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(
                  redirectMessage: 'Login to access "$featureName"',
                  onLoginSuccess: () {
                    // After login, show the feature
                    // You'll implement this later
                  },
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple[600],
          ),
          child: const Text('Login / Register', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
    // ✅ ADD THIS METHOD TO FETCH KUNDALIS
    Future<List<dynamic>> _fetchUserKundalis(BuildContext context) async {
    try {
        final identity = await IdentityService.getIdentity();
        final userId = identity['id'];
        final isLoggedIn = identity['type'] == 'registered';
        
        print('📊 Fetching kundalis for user: $userId (type: ${isLoggedIn ? "registered" : "anonymous"})');
        
        // Build the URL based on login status
        String url;
        if (isLoggedIn) {
        // Logged in user - no need for userId parameter
        url = 'https://astravedam.onrender.com/api/charts';
        } else {
        // Anonymous user - need userId parameter
        url = 'https://astravedam.onrender.com/api/charts?userId=$userId';
        }
        
        // Prepare headers
        final headers = <String, String>{
        'Content-Type': 'application/json',
        };
        
        // Add auth token if logged in
        if (isLoggedIn) {
        final token = await AuthService.getToken();
        if (token != null) {
            headers['Authorization'] = 'Bearer $token';
        }
        }
        
        final response = await http.get(
        Uri.parse(url),
        headers: headers,
        );
        
        if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final List<dynamic> kundalis = result['charts'] ?? [];
        print('✅ Found ${kundalis.length} kundalis');
        return kundalis;
        }
        return [];
    } catch (e) {
        print('❌ Error fetching kundalis: $e');
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load kundalis: $e'),
            duration: const Duration(seconds: 3),
        ),
        );
        return [];
    }
    }
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
          FutureBuilder<Map<String, dynamic>?>(
            future: AuthService.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Icon(Icons.person_outline);
              }
              
              final userData = snapshot.data;
              final isLoggedIn = userData != null;
              
              if (isLoggedIn) {
                // Show profile dropdown for logged in users
                return PopupMenuButton(
                  icon: const Icon(Icons.person),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(userData['name'] ?? 'Profile'),
                        subtitle: Text(userData['email'] ?? ''),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'logout') {
                      _logout(context);
                    } else if (value == 'profile') {
                      _showProfileDialog(context);
                    }
                  },
                );
              } else {
                // Show login button for anonymous users
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(
                          onLoginSuccess: () {
                            setState(() {}); // Refresh dashboard
                          },
                        ),
                      ),
                    );
                  },
                  tooltip: 'Login',
                );
              }
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
              const SizedBox(height: 16),
        
             // ✅ SECTION 1: KUNDALI LIST
              _buildKundaliListSection(context),
              const SizedBox(height: 16),
              
              // ✅ SECTION 2: ADD KUNDALI BUTTON
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _showAddKundaliDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green[100]!),
                          ),
                          child: Icon(
                            Icons.add_circle_outline,
                            color: Colors.green[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Another Kundali',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create birth chart for family or friends',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
  return FutureBuilder<Map<String, dynamic>?>(
    future: AuthService.getUserData(),
    builder: (context, snapshot) {
      final userData = snapshot.data;
      final isLoggedIn = userData != null;
      
      final userName = isLoggedIn 
          ? (userData['name'] ?? 'User')
          : (widget.userChart['name'] ?? 'User');
      
      final locationData = widget.userChart['locationData'] ?? {};
      
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar/Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLoggedIn ? Colors.green[100] : Colors.deepPurple[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLoggedIn ? Icons.person : Icons.self_improvement,
                  color: isLoggedIn ? Colors.green[600] : Colors.deepPurple[600],
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Welcome, $userName',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                        if (isLoggedIn) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              'Account',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
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
                      isLoggedIn 
                          ? 'Your cosmic journey continues...' 
                          : 'Your cosmic journey begins here...',
                      style: TextStyle(
                        color: Colors.deepPurple[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Credits badge
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
                      isLoggedIn
                          ? 'Credits: ${userData?['credits'] ?? 0}'
                          : 'Credits: 0',
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
    },
  );
}

Widget _buildKundaliListSection(BuildContext context) {
  return FutureBuilder<List<dynamic>>(
    future: _fetchUserKundalis(context),
    // ✅ ADD THIS KEY
    key: ValueKey<int>(_refreshCounter),
    builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading kundalis: ${snapshot.error}'),
            ),
          );
        }
        
        final kundalis = snapshot.data ?? [];
        
        if (kundalis.isEmpty) {
          return const SizedBox(); // Hide if no kundalis
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Kundalis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${kundalis.length} saved',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // List of kundalis
            ...kundalis.map((kundali) {
              final isPrimary = kundali['isPrimary'] == true;
              final personName = kundali['personName'] ?? kundali['name'] ?? 'Unknown';
              final location = kundali['location'] ?? 'Unknown location';
              final formattedDate = _formatKundaliDate(kundali['birthDate']);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Primary Badge
                      if (isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[700],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Secondary',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      
                      const SizedBox(width: 12),
                      
                      // Kundali Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              personName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$location • $formattedDate',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Actions
                      IconButton(
                        onPressed: () {
                          _viewKundaliDetails(context, kundali);
                        },
                        icon: Icon(
                          Icons.visibility,
                          size: 18,
                          color: Colors.deepPurple[600],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
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
              '1 Credit',
              Colors.purple,
              () async {
                // Check if user is logged in
                final isLoggedIn = await AuthService.isLoggedIn();
                
                if (!isLoggedIn) {
                  _showLoginRequiredDialog(context, 'Ask Gods', 1);
                } else {
                  // User is logged in, check credits
                  final credits = await IdentityService.getCreditsBalance();
                  if (credits >= 1) {
                    // TODO: Open Ask Gods feature
                    _showComingSoon(context, 'Ask Gods');
                  } else {
                    _showCreditRequiredDialog(context, 'Ask Gods', 1);
                  }
                }
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
    final chartData = widget.userChart['chart'] ?? widget.userChart;
    final locationData = widget.userChart['locationData'] ?? {};
  
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

  // ✅ ADD THIS METHOD TO VIEW SPECIFIC KUNDALI
  void _viewKundaliDetails(BuildContext context, Map<String, dynamic> kundali) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("${kundali['personName'] ?? 'User'}'s Kundali"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info
                ListTile(
                  leading: const Icon(Icons.person, size: 20),
                  title: const Text('Person Name'),
                  subtitle: Text(kundali['personName'] ?? kundali['name'] ?? 'Unknown'),
                ),
                
                ListTile(
                  leading: const Icon(Icons.calendar_today, size: 20),
                  title: const Text('Birth Date'),
                  subtitle: Text(_formatKundaliDate(kundali['birthDate'])),
                ),
                
                ListTile(
                  leading: const Icon(Icons.access_time, size: 20),
                  title: const Text('Birth Time'),
                  subtitle: Text(kundali['birthTime'] ?? 'Not specified'),
                ),
                
                ListTile(
                  leading: const Icon(Icons.location_on, size: 20),
                  title: const Text('Birth Place'),
                  subtitle: Text(kundali['location'] ?? 'Unknown location'),
                ),
                
                // Status
                ListTile(
                  leading: const Icon(Icons.star, size: 20),
                  title: const Text('Status'),
                  subtitle: Text(
                    kundali['isPrimary'] == true ? 'Primary Kundali' : 'Secondary Kundali',
                    style: TextStyle(
                      color: kundali['isPrimary'] == true ? Colors.amber[700] : Colors.grey[600],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Actions
                if (kundali['isPrimary'] != true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _setAsPrimary(context, kundali);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[600],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Set as Primary'),
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

  // ✅ ADD THIS METHOD TO SET AS PRIMARY
  void _setAsPrimary(BuildContext context, Map<String, dynamic> kundali) {
    // Note: This requires a new backend endpoint
    // For now, just show a message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set as Primary'),
          content: const Text('This feature requires backend support. Coming soon!'),
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
  final chartData = widget.userChart['chart'] ?? widget.userChart;
  final locationData = widget.userChart['locationData'] ?? {};
  
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
                title: Text(widget.userChart['name'] ?? 'User'),
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

      // ✅ ADD THIS HELPER METHOD
    String _formatKundaliDate(dynamic date) {
        if (date == null) return 'Date unknown';
        try {
        final dateStr = date.toString();
        final parsedDate = DateTime.parse(dateStr);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
        } catch (e) {
        return 'Date unknown';
        }
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