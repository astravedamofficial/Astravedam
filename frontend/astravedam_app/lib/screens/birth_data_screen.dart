import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart';
import '../services/api_service.dart';
import '../services/user_id_service.dart';  // ✅ ADD THIS LINE
class BirthDataScreen extends StatefulWidget {
  const BirthDataScreen({super.key});

  @override
  State<BirthDataScreen> createState() => _BirthDataScreenState();
}

class _BirthDataScreenState extends State<BirthDataScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 40),
              
              // Name Field
              _buildTextField('Your Name (Optional)', _nameController),
              const SizedBox(height: 24),
              
              // Date of Birth
              _buildDateField(),
              const SizedBox(height: 24),
              
              // Time of Birth  
              _buildTimeField(),
              const SizedBox(height: 24),
              
              // Place of Birth
              _buildTextField('Place of Birth', _locationController),
              const SizedBox(height: 40),
              
              // Calculate Button
              _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCalculateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        // Spiritual icon
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            shape: BoxShape.circle,
            ),
            child: Icon(
            Icons.self_improvement,
            size: 40,
            color: Colors.deepPurple[600],
            ),
        ),
        const SizedBox(height: 20),
        Text(
            'Astravedam',
            style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
            fontFamily: 'serif',
            ),
        ),
        const SizedBox(height: 8),
        Text(
            'Vedic Astrology & Birth Chart Analysis',
            style: TextStyle(
            fontSize: 16,
            color: Colors.deepPurple[600],
            fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
            'Discover your cosmic blueprint',
            style: TextStyle(
            fontSize: 14,
            color: Colors.deepPurple[400],
            ),
        ),
        const SizedBox(height: 30),
        Container(
            height: 1,
            color: Colors.deepPurple[100],
        ),
        ],
    );
    }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepPurple[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepPurple[500]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'Select your date of birth'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(
                    color: _selectedDate == null 
                        ? Colors.grey[600] 
                        : Colors.deepPurple[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: _selectDate,
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple[500],
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time of Birth *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedTime == null
                      ? 'Select your time of birth'
                      : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: _selectedTime == null 
                        ? Colors.grey[600] 
                        : Colors.deepPurple[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: _selectTime,
                icon: Icon(
                  Icons.access_time,
                  color: Colors.deepPurple[500],
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _calculateChart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Calculate My Chart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

    Future<void> _calculateChart() async {
    if (_locationController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
    }

    setState(() {
        _isLoading = true;
    });

    try {
        // ✅ FIXED: Get user ID
        final userId = await UserIdService.getOrCreateUserId();
        
        // ✅ FIXED: Prepare birth data with correct fields
        final name = _nameController.text.isEmpty ? 'User' : _nameController.text;
        final birthData = {
        'name': name,
        'date': _selectedDate!.toIso8601String(),
        'time': '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        'location': _locationController.text,
        // ✅ New fields for multi-kundali support
        'userId': userId,
        'personName': name,  // Same as name for now (user's own chart)
        'setAsPrimary': true,  // This is user's primary chart
        };
        
        print('📤 Sending to backend: ${birthData.keys.toList()}');
        
        // ✅ REST OF YOUR CODE STAYS EXACTLY THE SAME
        final response = await http.post(
        Uri.parse('https://astravedam.onrender.com/api/calculate-chart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(birthData),
        );
        
        print('📥 Backend response status: ${response.statusCode}');
        print('📥 Backend response body: ${response.body}');

        if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ Chart calculated successfully!');
        
        // Navigate to Dashboard (existing code unchanged)
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
            builder: (context) => DashboardScreen(userChart: result),
            ),
        );
        } else {
        throw Exception('Backend error: ${response.statusCode}');
        }
    } catch (e) {
        print('❌ Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Connection Error: $e'),
            duration: const Duration(seconds: 5),
        ),
        );
    } finally {
        setState(() {
        _isLoading = false;
        });
    }
    }

  void _showResultsDialog(Map<String, dynamic> result) {
    final chart = result['chart'];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🧘‍♂️ Your Vedic Birth Chart'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '📍 Lagna (Ascendant): ${chart['lagna']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🪐 Planetary Positions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('☀️ Sun: ${chart['planets']['sun']['rashi']} - ${chart['planets']['sun']['nakshatra']}'),
                Text('🌙 Moon: ${chart['planets']['moon']['rashi']} - ${chart['planets']['moon']['nakshatra']}'),
                Text('♂️ Mars: ${chart['planets']['mars']['rashi']} - ${chart['planets']['mars']['nakshatra']}'),
                const SizedBox(height: 16),
                const Text(
                  '🏠 Houses:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('1st House: ${chart['houses']['first']['sign']} (Lord: ${chart['houses']['first']['lord']})'),
                Text('2nd House: ${chart['houses']['second']['sign']} (Lord: ${chart['houses']['second']['lord']})'),
                Text('3rd House: ${chart['houses']['third']['sign']} (Lord: ${chart['houses']['third']['lord']})'),
                const SizedBox(height: 16),
                Text(
                  '📜 Summary: ${chart['summary']}',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
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
}