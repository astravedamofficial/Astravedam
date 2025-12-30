import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart';
import '../services/api_service.dart';
import '../services/user_id_service.dart';  // ✅ ADD THIS LINE
class BirthDataScreen extends StatefulWidget {
  final bool isAdditionalKundali;
  
  const BirthDataScreen({
    super.key,
    this.isAdditionalKundali = false,
  });

  @override
  State<BirthDataScreen> createState() => _BirthDataScreenState();
}

class _BirthDataScreenState extends State<BirthDataScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
    // ✅ ADD THIS initState METHOD
  @override
  void initState() {
    super.initState();
    if (widget.isAdditionalKundali) {
      _nameController.clear();
    }
  }
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
              _buildHeader(widget.isAdditionalKundali),
              const SizedBox(height: 40),
              
              // Name Field
              _buildTextField(
                widget.isAdditionalKundali 
                  ? 'Person\'s Name *'
                  : 'Your Name (Optional)',
                _nameController,
                isRequired: widget.isAdditionalKundali,
              ),
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
                : _buildCalculateButton(widget.isAdditionalKundali),
            ],
          ),
        ),
      ),
    );
  }

// ✅ ADD PARAMETER TO METHOD
Widget _buildHeader(bool isAdditionalKundali) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ USE DIFFERENT COLOR BASED ON TYPE
          color: isAdditionalKundali ? Colors.green[50] : Colors.deepPurple[50],
          shape: BoxShape.circle,
        ),
        child: Icon(
          // ✅ USE DIFFERENT ICON
          isAdditionalKundali ? Icons.group_add : Icons.self_improvement,
          size: 40,
          color: isAdditionalKundali ? Colors.green[600] : Colors.deepPurple[600],
        ),
      ),
      const SizedBox(height: 20),
      Text(
        // ✅ DIFFERENT TITLE
        isAdditionalKundali ? 'Add Kundali' : 'Astravedam',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: isAdditionalKundali ? Colors.green[800] : Colors.deepPurple[800],
          fontFamily: 'serif',
        ),
      ),
      const SizedBox(height: 8),
      Text(
        // ✅ DIFFERENT SUBTITLE
        isAdditionalKundali 
            ? 'Create birth chart for family or friend'
            : 'Vedic Astrology & Birth Chart Analysis',
        style: TextStyle(
          fontSize: 16,
          color: isAdditionalKundali ? Colors.green[600] : Colors.deepPurple[600],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        // ✅ DIFFERENT DESCRIPTION
        isAdditionalKundali 
            ? 'All charts saved under your profile'
            : 'Discover your cosmic blueprint',
        style: TextStyle(
          fontSize: 14,
          color: isAdditionalKundali ? Colors.green[400] : Colors.deepPurple[400],
        ),
      ),
      const SizedBox(height: 30),
      Container(
        height: 1,
        color: isAdditionalKundali ? Colors.green[100] : Colors.deepPurple[100],
      ),
    ],
  );
}

// ✅ ADD isRequired PARAMETER
Widget _buildTextField(String label, TextEditingController controller, {bool isRequired = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple[800],
            ),
          ),
          // ✅ SHOW ASTERISK IF REQUIRED
          if (isRequired) ...[
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Enter ${label.replaceAll('*', '').trim()}',
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

// ✅ ADD PARAMETER
Widget _buildCalculateButton(bool isAdditionalKundali) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _calculateChart,
      style: ElevatedButton.styleFrom(
        // ✅ DIFFERENT COLOR
        backgroundColor: isAdditionalKundali ? Colors.green[600] : Colors.deepPurple[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Text(
        // ✅ DIFFERENT TEXT
        isAdditionalKundali 
            ? 'Add This Kundali'
            : 'Calculate My Chart',
        style: const TextStyle(
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
    if (widget.isAdditionalKundali && _nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter person\'s name')),
        );
        return;
    }
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
        // Get user ID
        final userId = await UserIdService.getOrCreateUserId();
        
        // ✅ GET PERSON NAME
        final personName = _nameController.text.isEmpty 
            ? 'User' 
            : _nameController.text;
        
        // ✅ SET PRIMARY FLAG CORRECTLY
        final bool setAsPrimary = !widget.isAdditionalKundali;

        // Prepare birth data for backend
        final birthData = {
        'name': personName,
        'date': _selectedDate!.toIso8601String(),
        'time': '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        'location': _locationController.text,
        // ✅ NEW FIELDS
        'userId': userId,
        'personName': personName,
        'setAsPrimary': setAsPrimary,
        };
        print('📤 Creating ${widget.isAdditionalKundali ? "ADDITIONAL" : "PRIMARY"} kundali');
        print('   UserId: $userId');
        print('   SetAsPrimary: $setAsPrimary');
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
        print('✅ ${widget.isAdditionalKundali ? "Additional" : "Primary"} kundali created successfully!');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(
                widget.isAdditionalKundali 
                    ? '✅ Kundali added successfully!'
                    : '✅ Your birth chart is ready!',
            ),
            backgroundColor: Colors.green,
            ),
        );
        
        // ✅ FIXED NAVIGATION:
        if (widget.isAdditionalKundali) {
            // For ADDITIONAL kundali: Just go back to previous screen (Dashboard)
            Navigator.pop(context);
        } else {
            // For FIRST/PRIMARY kundali: Go to new Dashboard screen
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardScreen(userChart: result),
            ),
            );
          }
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