import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/astro_api_service.dart';

class UserHomeTab extends StatefulWidget {
  const UserHomeTab({super.key});

  @override
  State<UserHomeTab> createState() => _UserHomeTabState();
}

class _UserHomeTabState extends State<UserHomeTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _tobController = TextEditingController();
  final _pobController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _showKundaliForm = false;

  final AstroApiService _astroApiService = AstroApiService();
  Map<String, dynamic>? _kundaliData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _pobController.dispose();
    super.dispose();
  }

  void _toggleKundaliForm() {
    setState(() {
      _showKundaliForm = !_showKundaliForm;
      // Reset form when hiding
      if (!_showKundaliForm) {
        _formKey.currentState?.reset();
        _nameController.clear();
        _dobController.clear();
        _tobController.clear();
        _pobController.clear();
        _selectedDate = null;
        _selectedTime = null;
        _kundaliData = null;
        _errorMessage = null;
      }
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat.yMd().format(picked);
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _tobController.text = picked.format(context);
      });
    }
  }

  Future<void> _generateKundali() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        setState(() {
          _errorMessage = "Please select Date and Time of Birth.";
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _kundaliData = null;
      });

      try {
        final double latitude = 28.6139; 
        final double longitude = 77.2090;
        final double timezone = 5.5;

        final data = await _astroApiService.getKundaliDetails(
          day: _selectedDate!.day,
          month: _selectedDate!.month,
          year: _selectedDate!.year,
          hour: _selectedTime!.hour,
          minute: _selectedTime!.minute,
          latitude: latitude,
          longitude: longitude,
          timezone: timezone,
        );
        setState(() {
          _kundaliData = data;
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Failed to generate Kundali: ${e.toString()}";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.purple.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.home,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to Astro App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore your cosmic journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Kundali Banner Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepPurple.shade700,
                        Colors.indigo.shade800,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_graph,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Want to know your Kundali?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Discover your cosmic blueprint and planetary influences',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _toggleKundaliForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _showKundaliForm ? 'Hide Kundali Generator' : 'Generate My Kundali',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Kundali Form (shown conditionally)
          if (_showKundaliForm) ...[
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'Enter Your Birth Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dobController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _pickDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tobController,
                        decoration: const InputDecoration(
                          labelText: 'Time of Birth',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        readOnly: true,
                        onTap: () => _pickTime(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your time of birth';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pobController,
                        decoration: const InputDecoration(
                          labelText: 'Place of Birth (e.g., City, Country)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your place of birth';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _generateKundali,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Generate Kundali',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          
          // Kundali Results (shown conditionally)
          if (_kundaliData != null) ...[
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildKundaliDetails(_kundaliData!),
              ),
            ),
          ],
          
          // Additional content for home screen
          const SizedBox(height: 24),
          
          // Daily Horoscope Card (example of additional content)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sunny, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Daily Horoscope',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Today is a great day to explore new ideas and connect with those who share your interests. Your intuition is particularly strong today.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to full horoscope
                      },
                      child: const Text('Read More'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKundaliDetails(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Your Kundali Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // Basic Information
        _buildSectionTitle('Basic Information'),
        ListTile(
          title: const Text('Name'),
          subtitle: Text(_nameController.text),
          leading: const Icon(Icons.person, color: Colors.deepPurple),
        ),
        ListTile(
          title: const Text('Birth Date'),
          subtitle: Text(data['birth_date'] ?? ''),
          leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
        ),
        ListTile(
          title: const Text('Birth Time'),
          subtitle: Text(data['birth_time'] ?? ''),
          leading: const Icon(Icons.access_time, color: Colors.deepPurple),
        ),
        ListTile(
          title: const Text('Location'),
          subtitle: Text(_pobController.text),
          leading: const Icon(Icons.location_on, color: Colors.deepPurple),
        ),
        
        const Divider(),
        
        // Ascendant and Signs
        _buildSectionTitle('Ascendant & Signs'),
        ListTile(
          title: const Text('Ascendant'),
          subtitle: Text(data['ascendant'] ?? ''),
          leading: const Icon(Icons.arrow_upward, color: Colors.deepPurple),
        ),
        ListTile(
          title: const Text('Moon Sign'),
          subtitle: Text(data['moon_sign'] ?? ''),
          leading: const Icon(Icons.nightlight, color: Colors.deepPurple),
        ),
        ListTile(
          title: const Text('Sun Sign'),
          subtitle: Text(data['sun_sign'] ?? ''),
          leading: const Icon(Icons.wb_sunny, color: Colors.deepPurple),
        ),
        
        // Only show planets if they exist in the data
        if (data.containsKey('planets') && data['planets'] is Map) ...[
          const Divider(),
          _buildSectionTitle('Planetary Positions'),
          ...(data['planets'] as Map).entries.map((entry) {
            IconData icon;
            switch(entry.key) {
              case 'sun': icon = Icons.wb_sunny; break;
              case 'moon': icon = Icons.nightlight; break;
              case 'mercury': icon = Icons.speed; break;
              case 'venus': icon = Icons.favorite; break;
              case 'mars': icon = Icons.fitness_center; break;
              case 'jupiter': icon = Icons.auto_awesome; break;
              case 'saturn': icon = Icons.watch_later; break;
              default: icon = Icons.public;
            }
            
            return ListTile(
              title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
              subtitle: Text(entry.value.toString()),
              leading: Icon(icon, color: Colors.deepPurple),
            );
          }).toList(),
        ],
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
} 