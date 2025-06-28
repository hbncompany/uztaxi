import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'localizations.dart';
import 'auth_screen.dart';
import 'dart:async';

// New import for the dedicated MapSelectionScreen
import 'map_selection_screen.dart'; // Make sure this path is correct

class BookRideScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const BookRideScreen({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  _BookRideScreenState createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _driverSearchController = TextEditingController();

  DateTime? _selectedDate;
  String _driverSearchFilter = '';

  List<String> _availableFromLocations = [];
  List<String> _availableToLocations = [];
  String? _selectedFromLocation;
  String? _selectedToLocation;

  // This will now store the result from MapSelectionScreen
  Map<String, dynamic>? _selectedTakeOverLocation;

  final StreamController<List<DocumentSnapshot>> _ridesStreamController =
  StreamController<List<DocumentSnapshot>>.broadcast();

  Stream<List<DocumentSnapshot>> get _combinedRidesStream => _ridesStreamController.stream;

  StreamSubscription? _dailyRidesSubscription;
  StreamSubscription? _timeFilteredRidesSubscription;
  StreamSubscription? _dateFilteredRidesSubscription;

  @override
  void initState() {
    super.initState();
    _driverSearchController.addListener(_onFilterChanged);
    _fetchUniqueLocations();
    _fetchCombinedRides();
  }

  @override
  void dispose() {
    _driverSearchController.removeListener(_onFilterChanged);
    _driverSearchController.dispose();

    _dailyRidesSubscription?.cancel();
    _timeFilteredRidesSubscription?.cancel();
    _dateFilteredRidesSubscription?.cancel();
    _ridesStreamController.close();
    super.dispose();
  }

  Future<void> _fetchUniqueLocations() async {
    Set<String> fromLocations = {};
    Set<String> toLocations = {};

    try {
      QuerySnapshot ridesSnapshot = await FirebaseFirestore.instance.collection('rides').get();
      for (var doc in ridesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['fromLocation'] != null && data['fromLocation'].isNotEmpty) {
          fromLocations.add(data['fromLocation']);
        }
        if (data['toLocation'] != null && data['toLocation'].isNotEmpty) {
          toLocations.add(data['toLocation']);
        }
      }
      if (mounted) {
        setState(() {
          _availableFromLocations = fromLocations.toList()..sort();
          _availableToLocations = toLocations.toList()..sort();
        });
      }
    } catch (e) {
      print("Error fetching unique locations: $e");
    }
  }

  void _onFilterChanged() {
    setState(() {
      _driverSearchFilter = _driverSearchController.text.trim().toLowerCase();
    });
    _updateCombinedRides(null, null, null);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
        });
      }
      _fetchCombinedRides();
    }
  }

  void _clearDateFilter() {
    if (mounted) {
      setState(() {
        _selectedDate = null;
      });
    }
    _fetchCombinedRides();
  }

  Future<void> _fetchCombinedRides() async {
    _dailyRidesSubscription?.cancel();
    _timeFilteredRidesSubscription?.cancel();
    _dateFilteredRidesSubscription?.cancel();

    Query<Map<String, dynamic>> baseQuery = FirebaseFirestore.instance
        .collection('rides')
        .where('status', isEqualTo: 'active');

    if (_selectedDate != null) {
      DateTime startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 0, 0, 0);
      DateTime endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);

      _dateFilteredRidesSubscription = baseQuery
          .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
          .where('dateTime', isLessThanOrEqualTo: endOfDay)
          .orderBy('dateTime', descending: false)
          .snapshots()
          .listen((snapshot) {
        _updateCombinedRides(null, null, snapshot.docs);
      });
    } else {
      _dailyRidesSubscription = baseQuery
          .where('isDailyRide', isEqualTo: true)
          .orderBy('dateTime', descending: false)
          .snapshots()
          .listen((dailySnapshot) {
        _updateCombinedRides(dailySnapshot.docs, null, null);
      });

      DateTime now = DateTime.now();
      DateTime twentyOhClockToday = DateTime(now.year, now.month, now.day, 20, 0, 0);

      if (now.isAfter(twentyOhClockToday)) {
        twentyOhClockToday = twentyOhClockToday.add(const Duration(days: 1));
      }

      _timeFilteredRidesSubscription = baseQuery
          .where('dateTime', isGreaterThanOrEqualTo: twentyOhClockToday)
          .orderBy('dateTime', descending: false)
          .snapshots()
          .listen((timeFilteredSnapshot) {
        _updateCombinedRides(null, timeFilteredSnapshot.docs, null);
      });
    }
  }

  List<DocumentSnapshot> _latestDailyRides = [];
  List<DocumentSnapshot> _latestTimeFilteredRides = [];
  List<DocumentSnapshot> _latestDateFilteredRides = [];

  void _updateCombinedRides(List<DocumentSnapshot>? dailyDocs, List<DocumentSnapshot>? timeFilteredDocs, List<DocumentSnapshot>? dateFilteredDocs) async {
    if (dailyDocs != null) {
      _latestDailyRides = dailyDocs;
    }
    if (timeFilteredDocs != null) {
      _latestTimeFilteredRides = timeFilteredDocs;
    }
    if (dateFilteredDocs != null) {
      _latestDateFilteredRides = dateFilteredDocs;
    }

    List<DocumentSnapshot> baseList;
    if (_selectedDate != null) {
      baseList = List.from(_latestDateFilteredRides);
    } else {
      Set<String> uniqueRideIds = {};
      List<DocumentSnapshot> combinedList = [];

      for (var doc in _latestDailyRides) {
        if (uniqueRideIds.add(doc.id)) {
          combinedList.add(doc);
        }
      }
      for (var doc in _latestTimeFilteredRides) {
        if (uniqueRideIds.add(doc.id)) {
          combinedList.add(doc);
        }
      }
      baseList = combinedList;
    }

    List<DocumentSnapshot> filteredList = [];
    for (var rideDoc in baseList) {
      final rideData = rideDoc.data() as Map<String, dynamic>;

      bool matchesFrom = _selectedFromLocation == null ||
          (rideData['fromLocation']?.toLowerCase() == _selectedFromLocation?.toLowerCase());

      bool matchesTo = _selectedToLocation == null ||
          (rideData['toLocation']?.toLowerCase() == _selectedToLocation?.toLowerCase());

      bool matchesDriverSearch = true;
      if (_driverSearchFilter.isNotEmpty) {
        try {
          DocumentSnapshot driverDoc = await FirebaseFirestore.instance.collection('users').doc(rideData['driverId']).get();
          if (driverDoc.exists) {
            final driverData = driverDoc.data() as Map<String, dynamic>;
            final driverUsername = (driverData['username']?.toLowerCase() ?? '');
            final driverPhoneNumber = (driverData['phoneNumber']?.toLowerCase() ?? '');
            if (!driverUsername.contains(_driverSearchFilter) &&
                !driverPhoneNumber.contains(_driverSearchFilter)) {
              matchesDriverSearch = false;
            }
          } else {
            matchesDriverSearch = false;
          }
        } catch (e) {
          print("Error fetching driver for search: $e");
          matchesDriverSearch = false;
        }
      }

      if (matchesFrom && matchesTo && matchesDriverSearch) {
        filteredList.add(rideDoc);
      }
    }

    filteredList.sort((a, b) {
      Timestamp? timestampA = a['dateTime'] is Timestamp ? a['dateTime'] : (a['dateTime'] != null ? Timestamp.fromDate(DateTime.parse(a['dateTime'].toString())) : null);
      Timestamp? timestampB = b['dateTime'] is Timestamp ? b['dateTime'] : (b['dateTime'] != null ? Timestamp.fromDate(DateTime.parse(b['dateTime'].toString())) : null);

      if (timestampA == null && timestampB == null) return 0;
      if (timestampA == null) return 1;
      if (timestampB == null) return -1;

      return timestampA.compareTo(timestampB);
    });

    _ridesStreamController.add(filteredList);
  }

  // --- Replaced _showMapSelectionDialog with navigation to MapSelectionScreen ---
  Future<void> _navigateAndSelectLocation(BuildContext context) async {
    final Map<String, dynamic>? selectedResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionScreen(
          initialLocation: _selectedTakeOverLocation,
          onLocaleChange: widget.onLocaleChange, // Pass locale change function
        ),
      ),
    );

    if (selectedResult != null && mounted) {
      setState(() {
        _selectedTakeOverLocation = selectedResult;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)?.locationSelected ??
                  'Location selected: ${selectedResult['address']}'),
        ),
      );
    } else if (mounted) {
      // If result is null, it means the user cancelled or cleared the selection
      setState(() {
        _selectedTakeOverLocation = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.locationCleared ?? 'Location selection cleared.'),
        ),
      );
    }
  }


  Future<void> _sendRideOffer(
      BuildContext mainScreenContext,
      String rideId,
      String driverId,
      String driverPhoneNumber,
      double ridePrice,
      bool deliversObjectsOption,
      int neededPassengersOption,
      ) async {
    final localizations = AppLocalizations.of(mainScreenContext);

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(mainScreenContext).showSnackBar(
          SnackBar(content: Text(localizations?.loginRequired ?? 'You must be logged in to send an offer')),
        );
      }
      return;
    }

    await showDialog(
      context: mainScreenContext,
      builder: (BuildContext dialogContext) {
        return _SendOfferDialog(
          mainScreenContext: mainScreenContext,
          rideId: rideId,
          driverId: driverId,
          driverPhoneNumber: driverPhoneNumber,
          ridePrice: ridePrice,
          deliversObjectsOption: deliversObjectsOption,
          neededPassengersOption: neededPassengersOption,
          currentUser: currentUser,
          selectedTakeOverLocation: _selectedTakeOverLocation,
          localizations: localizations,
          // Pass the navigate function to the dialog
          onSelectLocationFromMap: _navigateAndSelectLocation,
        );
      },
    );

    if (mounted) {
      setState(() {
        _selectedTakeOverLocation = null;
      });
    }
  }

  Future<void> _cancelRideOffer(String offerId) async {
    final localizations = AppLocalizations.of(context);
    try {
      await FirebaseFirestore.instance.collection('ride_offers').doc(offerId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.offerCancelledSuccessfully ?? 'Offer cancelled successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations?.failedToCancelOffer ?? 'Failed to cancel offer'}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations?.bookARide ?? 'Book a Ride'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF26A69A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations?.loginRequired ?? 'Please log in to book a ride.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthScreen(
                          onLocaleChange: widget.onLocaleChange,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: Text(localizations?.loginButton ?? 'Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.bookARide ?? 'Book a Ride'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Dropdown for From Location
                    DropdownButtonFormField<String>(
                      value: _selectedFromLocation,
                      decoration: InputDecoration(
                        labelText: localizations?.filterFromLocation ?? 'Filter From Location',
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2196F3)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      hint: Text(localizations?.filterFromLocation ?? 'Filter From Location'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFromLocation = newValue;
                        });
                        _updateCombinedRides(null, null, null);
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(localizations?.clearFilter ?? 'Clear Filter', style: const TextStyle(color: Colors.red)),
                        ),
                        ..._availableFromLocations.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Dropdown for To Location
                    DropdownButtonFormField<String>(
                      value: _selectedToLocation,
                      decoration: InputDecoration(
                        labelText: localizations?.filterToLocation ?? 'Filter To Location',
                        prefixIcon: const Icon(Icons.place, color: Color(0xFF26A69A)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      hint: Text(localizations?.filterToLocation ?? 'Filter To Location'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedToLocation = newValue;
                        });
                        _updateCombinedRides(null, null, null);
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(localizations?.clearFilter ?? 'Clear Filter', style: const TextStyle(color: Colors.red)),
                        ),
                        ..._availableToLocations.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _driverSearchController,
                      decoration: InputDecoration(
                        labelText: localizations?.searchDriver ?? 'Search Driver (Username or Phone)',
                        prefixIcon: const Icon(Icons.person_search, color: Colors.blueGrey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today, color: Colors.white),
                            label: Text(
                              _selectedDate == null
                                  ? (localizations?.selectDateFilter ?? 'Select Date Filter')
                                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: const Color(0xFF2196F3),
                              elevation: 3,
                            ),
                          ),
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _clearDateFilter,
                            icon: const Icon(Icons.clear, color: Colors.red),
                            tooltip: localizations?.clearDateFilter ?? 'Clear Date Filter',
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _combinedRidesStream,
              builder: (context, ridesSnapshot) {
                if (ridesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ridesSnapshot.hasError) {
                  return Center(child: Text('${localizations?.error ?? 'Error'}: ${ridesSnapshot.error}'));
                }
                if (!ridesSnapshot.hasData || ridesSnapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(localizations?.noActiveRides ?? 'No active rides found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: ridesSnapshot.data!.length,
                  itemBuilder: (context, index) {
                    final rideDoc = ridesSnapshot.data![index];
                    final rideData = rideDoc.data() as Map<String, dynamic>;

                    DateTime rideDateTime;
                    if (rideData['dateTime'] is Timestamp) {
                      rideDateTime = (rideData['dateTime'] as Timestamp).toDate();
                    } else {
                      rideDateTime = DateTime.parse(rideData['dateTime'].toString());
                    }

                    final String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(rideDateTime);

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ride_offers')
                          .where('rideId', isEqualTo: rideDoc.id)
                          .where('clientId', isEqualTo: currentUser!.uid)
                          .where('status', isEqualTo: 'pending')
                          .limit(1)
                          .snapshots(),
                      builder: (context, offersSnapshot) {
                        if (offersSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        String? existingOfferId;
                        if (offersSnapshot.hasData && offersSnapshot.data!.docs.isNotEmpty) {
                          existingOfferId = offersSnapshot.data!.docs.first.id;
                        }

                        return Card(
                          key: ValueKey(rideDoc.id),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Color(0xFF2196F3), size: 24),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${localizations?.fromWhere ?? 'From'}: ${rideData['fromLocation']}',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.place, color: Color(0xFF26A69A), size: 24),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${localizations?.toWhere ?? 'To'}: ${rideData['toLocation']}',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20, thickness: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${localizations?.dateTime ?? 'Date & Time'}:', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                          Text(formattedDateTime, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('${localizations?.price ?? 'Price'}:', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                          Text('\$${rideData['price']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF26A69A))),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${localizations?.neededPassengers ?? 'Passengers'}:', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                          Text('${rideData['neededPassengers']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('${localizations?.deliversObjects ?? 'Delivers Objects'}:', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                          Text(
                                            rideData['deliversObjects'] ? (localizations?.yes ?? 'Yes') : (localizations?.no ?? 'No'),
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: rideData['deliversObjects'] ? Colors.green : Colors.red),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (rideData['additionalPhoneNumber'] != null && rideData['additionalPhoneNumber'].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.phone, size: 20, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${localizations?.additionalPhoneNumber ?? 'Additional Phone'}: ${rideData['additionalPhoneNumber']}',
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.repeat, size: 20, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${localizations?.isDailyRide ?? 'Daily Ride'}: ${rideData['isDailyRide'] ? (localizations?.yes ?? 'Yes') : (localizations?.no ?? 'No')}',
                                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: existingOfferId != null
                                        ? ElevatedButton.icon(
                                      onPressed: () => _cancelRideOffer(existingOfferId!),
                                      icon: const Icon(Icons.cancel, color: Colors.white),
                                      label: Text(
                                        localizations?.cancelRideButton ?? 'Cancel Ride',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        elevation: 5,
                                      ),
                                    )
                                        : ElevatedButton.icon(
                                      onPressed: () {
                                        _sendRideOffer(
                                          context, // Pass the main screen's context
                                          rideDoc.id,
                                          rideData['driverId'],
                                          rideData['driverPhoneNumber'],
                                          rideData['price']?.toDouble() ?? 0.0,
                                          rideData['deliversObjects'] ?? false,
                                          rideData['neededPassengers'] ?? 0,
                                        );
                                      },
                                      icon: const Icon(Icons.send, color: Colors.white),
                                      label: Text(
                                        localizations?.getRideButton ?? 'Get Ride',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF26A69A),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        elevation: 5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Existing _SendOfferDialog widget (modified to call _navigateAndSelectLocation)
class _SendOfferDialog extends StatefulWidget {
  final BuildContext mainScreenContext;
  final String rideId;
  final String driverId;
  final String driverPhoneNumber;
  final double ridePrice;
  final bool deliversObjectsOption;
  final int neededPassengersOption;
  final User? currentUser;
  final Map<String, dynamic>? selectedTakeOverLocation;
  final AppLocalizations? localizations;
  final Function(BuildContext) onSelectLocationFromMap; // New callback

  const _SendOfferDialog({
    Key? key,
    required this.mainScreenContext,
    required this.rideId,
    required this.driverId,
    required this.driverPhoneNumber,
    required this.ridePrice,
    required this.deliversObjectsOption,
    required this.neededPassengersOption,
    required this.currentUser,
    required this.selectedTakeOverLocation,
    required this.localizations,
    required this.onSelectLocationFromMap, // Require the callback
  }) : super(key: key);

  @override
  __SendOfferDialogState createState() => __SendOfferDialogState();
}

class __SendOfferDialogState extends State<_SendOfferDialog> {
  late TextEditingController _commentController;
  int? _requestedPassengers;
  bool? _isShipmentRequest;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _requestedPassengers = widget.neededPassengersOption;
    _isShipmentRequest = widget.deliversObjectsOption;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext dialogContext) {
    final localizations = widget.localizations;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(localizations?.sendOffer ?? 'Send Offer', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.neededPassengersOption > 0)
              TextFormField(
                keyboardType: TextInputType.number,
                initialValue: _requestedPassengers?.toString(),
                decoration: InputDecoration(
                  labelText: localizations?.requestedPassengers ?? 'Requested Passengers',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.people),
                ),
                onChanged: (value) {
                  setState(() {
                    _requestedPassengers = int.tryParse(value);
                  });
                },
              ),
            const SizedBox(height: 10),
            if (widget.deliversObjectsOption)
              CheckboxListTile(
                title: Text(localizations?.isShipmentRequest ?? 'Is Shipment Request?'),
                value: _isShipmentRequest ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    _isShipmentRequest = value;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF26A69A),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Call the callback to navigate to MapSelectionScreen
                widget.onSelectLocationFromMap(widget.mainScreenContext);
                // No need to pop the dialog here, it stays open.
                // It will rebuild when _selectedTakeOverLocation in parent changes.
              },
              icon: const Icon(Icons.map, color: Colors.white),
              label: Text(
                widget.selectedTakeOverLocation != null
                    ? (localizations?.changeLocation ?? 'Change Location')
                    : (localizations?.selectLocationOnMap ?? 'Select Location on Map'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                elevation: 5,
              ),
            ),
            if (widget.selectedTakeOverLocation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${localizations?.selectedLocation ?? 'Selected Location'}: ${widget.selectedTakeOverLocation!['address']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: localizations?.yourComment ?? 'Your Comment (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.comment),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
          },
          child: Text(localizations?.cancel ?? 'Cancel', style: const TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (widget.neededPassengersOption > 0 && (_requestedPassengers == null || _requestedPassengers! <= 0)) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text(localizations?.enterValidNumber ?? 'Please enter a valid number of passengers.')),
              );
              return;
            }

            try {
              String clientPhoneNumber = widget.currentUser?.phoneNumber ?? '';
              String clientUsername = 'N/A';
              if (widget.currentUser != null) {
                final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.currentUser!.uid).get();
                if (userDoc.exists) {
                  clientPhoneNumber = userDoc.data()?['phoneNumber'] ?? widget.currentUser?.phoneNumber ?? '';
                  clientUsername = userDoc.data()?['username'] ?? widget.currentUser!.email?.split('@').first ?? 'N/A';
                }
                // --- CONCEPTUAL: Get FCM Token for Push Notifications ---
                // In a real app, you'd retrieve the current device's FCM token here
                // and store it in Firestore for the current user.
                // Example (NOT FUNCTIONAL WITHOUT FCM SETUP):
                // final String? fcmToken = await FirebaseMessaging.instance.getToken();
                // if (fcmToken != null) {
                //   await FirebaseFirestore.instance.collection('users').doc(widget.currentUser!.uid).update({
                //     'fcmToken': fcmToken,
                //   });
                // }
              }

              await FirebaseFirestore.instance.collection('ride_offers').add({
                'rideId': widget.rideId,
                'driverId': widget.driverId,
                'clientId': widget.currentUser!.uid,
                'clientPhoneNumber': clientPhoneNumber,
                'clientUsername': clientUsername,
                'requestedPassengers': _requestedPassengers,
                'isShipmentRequest': _isShipmentRequest,
                'clientComment': _commentController.text.trim(),
                'takeOverLocation': widget.selectedTakeOverLocation,
                'offerPrice': widget.ridePrice,
                'status': 'pending',
                'createdAt': FieldValue.serverTimestamp(),
              });

              // --- CONCEPTUAL: Trigger Cloud Function for Push Notification ---
              // After a ride offer is successfully added to Firestore, a Firebase Cloud Function
              // (or your custom backend) would be triggered. This function would:
              // 1. Read the newly created ride_offer document.
              // 2. Get the 'driverId' from the offer.
              // 3. Look up the driver's FCM token from the 'users' collection using 'driverId'.
              //    (Ensure drivers register their FCM tokens upon login/app start).
              // 4. Use the Firebase Admin SDK to send a push notification to that FCM token.
              //
              // Example (NOT FUNCTIONAL, FOR ILLUSTRATION ONLY):
              /*
              // In your Firebase Cloud Function (Node.js example):
              const functions = require('firebase-functions');
              const admin = require('firebase-admin');
              admin.initializeApp();

              exports.sendRideOfferNotification = functions.firestore
                  .document('ride_offers/{offerId}')
                  .onCreate(async (snap, context) => {
                      const offerData = snap.data();
                      const driverId = offerData.driverId;
                      const clientId = offerData.clientId;

                      // Get driver's FCM token
                      const driverDoc = await admin.firestore().collection('users').doc(driverId).get();
                      const driverFcmToken = driverDoc.data()?.fcmToken;

                      // Get client's username for the notification message
                      const clientDoc = await admin.firestore().collection('users').doc(clientId).get();
                      const clientUsername = clientDoc.data()?.username || 'A client';

                      if (driverFcmToken) {
                          const payload = {
                              notification: {
                                  title: 'New Ride Offer!',
                                  body: `${clientUsername} sent you an offer for a ride.`,
                                  sound: 'default',
                              },
                              data: {
                                  rideId: offerData.rideId,
                                  offerId: snap.id,
                                  // other relevant data for the driver app to handle
                              },
                          };
                          return admin.messaging().sendToDevice(driverFcmToken, payload);
                      }
                      return null;
                  });
              */

              Navigator.of(dialogContext).pop();
              if (mounted) {
                ScaffoldMessenger.of(widget.mainScreenContext).showSnackBar(
                  SnackBar(content: Text(localizations?.offerSentSuccessfully ?? 'Offer sent successfully!')),
                );
              }
            } catch (e) {
              print('Failed to send offer: $e');
              if (mounted) {
                ScaffoldMessenger.of(widget.mainScreenContext).showSnackBar(
                  SnackBar(content: Text('${localizations?.failedToSendOffer ?? 'Failed to send offer'}: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF26A69A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
          ),
          child: Text(localizations?.sendOffer ?? 'Send Offer'),
        ),
      ],
    );
  }
}
