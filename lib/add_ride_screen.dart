import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import 'localizations.dart'; // Ensure this path is correct
import 'package:animate_do/animate_do.dart'; // NEW: Import animate_do package

class AddRideScreen extends StatefulWidget {
  @override
  _AddRideScreenState createState() => _AddRideScreenState();
}

class _AddRideScreenState extends State<AddRideScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();
  final TextEditingController _additionalPhoneController =
      TextEditingController();
  bool _deliversObjects = false;
  bool _isDailyRide = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _priceController.dispose();
    _passengersController.dispose();
    _additionalPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _addRide() async {
    final localizations = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(localizations?.selectDateTime ??
                'Please select date and time')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(localizations?.loginRequired ??
                'You must be logged in to add a ride')),
      );
      return;
    }

    try {
      // Combine date and time
      final rideDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('rides').add({
        'driverId': user.uid,
        'driverPhoneNumber': user.phoneNumber ?? '',
        'dateTime': rideDateTime,
        'fromLocation': _fromController.text.trim(),
        'toLocation': _toController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'neededPassengers': int.parse(_passengersController.text.trim()),
        'additionalPhoneNumber': _additionalPhoneController.text.trim(),
        'deliversObjects': _deliversObjects,
        'isDailyRide': _isDailyRide,
        'status': 'active', // 'active' or 'frozen'
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(localizations?.rideAddedSuccessfully ??
                'Ride added successfully!')),
      );
      Navigator.pop(context); // Go back to HomePage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations?.error ?? 'Error'}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.addRide ?? 'Add Ride'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeInDown(
                // This was causing the error
                child: Text(
                  localizations?.rideDetails ?? 'Ride Details',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24),
              // Date Picker
              FadeInUp(
                // This was causing the error
                delay: Duration(milliseconds: 100),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Color(0xFF2196F3)),
                  title: Text(
                    _selectedDate == null
                        ? (localizations?.selectDate ?? 'Select Date')
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () => _selectDate(context),
                ),
              ),
              SizedBox(height: 16),
              // Time Picker
              FadeInUp(
                delay: Duration(milliseconds: 200),
                child: ListTile(
                  leading: Icon(Icons.access_time, color: Color(0xFF2196F3)),
                  title: Text(
                    _selectedTime == null
                        ? (localizations?.selectTime ?? 'Select Time')
                        : _selectedTime!.format(context),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () => _selectTime(context),
                ),
              ),
              SizedBox(height: 16),
              // From Location
              FadeInUp(
                delay: Duration(milliseconds: 300),
                child: TextFormField(
                  controller: _fromController,
                  decoration: InputDecoration(
                    labelText: localizations?.fromWhere ?? 'From Where',
                    prefixIcon:
                        Icon(Icons.location_on, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.enterFromLocation ??
                          'Please enter origin location';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              // To Location
              FadeInUp(
                delay: Duration(milliseconds: 400),
                child: TextFormField(
                  controller: _toController,
                  decoration: InputDecoration(
                    labelText: localizations?.toWhere ?? 'To Where',
                    prefixIcon:
                        Icon(Icons.location_on, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.enterToLocation ??
                          'Please enter destination location';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              // Price
              FadeInUp(
                delay: Duration(milliseconds: 500),
                child: TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: localizations?.price ?? 'Price',
                    prefixIcon:
                        Icon(Icons.attach_money, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.enterPrice ?? 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return localizations?.enterValidPrice ??
                          'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              // Needed Passengers Count
              FadeInUp(
                delay: Duration(milliseconds: 600),
                child: TextFormField(
                  controller: _passengersController,
                  decoration: InputDecoration(
                    labelText: localizations?.neededPassengers ??
                        'Needed Passengers Count',
                    prefixIcon: Icon(Icons.people, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations?.enterPassengerCount ??
                          'Please enter passenger count';
                    }
                    if (int.tryParse(value) == null) {
                      return localizations?.enterValidNumber ??
                          'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              // Additional Phone Number
              FadeInUp(
                delay: Duration(milliseconds: 700),
                child: TextFormField(
                  controller: _additionalPhoneController,
                  decoration: InputDecoration(
                    labelText: localizations?.additionalPhoneNumber ??
                        'Additional Phone Number (Optional)',
                    prefixIcon:
                        Icon(Icons.phone_in_talk, color: Color(0xFF2196F3)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(height: 16),
              // Delivers Objects Checkbox
              FadeInUp(
                delay: Duration(milliseconds: 800),
                child: CheckboxListTile(
                  title: Text(
                      localizations?.deliversObjects ?? 'Delivers Objects?'),
                  value: _deliversObjects,
                  onChanged: (bool? value) {
                    setState(() {
                      _deliversObjects = value ?? false;
                    });
                  },
                  activeColor: Color(0xFF26A69A),
                ),
              ),
              SizedBox(height: 16),
              // Daily Ride Checkbox
              FadeInUp(
                delay: Duration(milliseconds: 900),
                child: CheckboxListTile(
                  title: Text(localizations?.isDailyRide ?? 'Daily Ride?'),
                  value: _isDailyRide,
                  onChanged: (bool? value) {
                    setState(() {
                      _isDailyRide = value ?? false;
                    });
                  },
                  activeColor: Color(0xFF26A69A),
                ),
              ),
              SizedBox(height: 24),
              // Add Ride Button
              _buildGradientButton(
                text: localizations?.addRideButton ?? 'Add Ride',
                icon: Icons.check,
                onPressed: _addRide,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for the gradient button to be used within this screen
  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
