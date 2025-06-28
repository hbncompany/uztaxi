import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'localizations.dart';

class MyRidesScreen extends StatefulWidget {
  @override
  _MyRidesScreenState createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _toggleRideStatus(String rideId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'frozen' : 'active';
    try {
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.rideStatusUpdated ??
                'Ride status updated!',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${AppLocalizations.of(context)?.error ?? 'Error'}: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations?.myRides ?? 'My Rides'),
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
        body: Center(
          child: Text(localizations?.loginRequired ??
              'Please log in to view your rides.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.myRides ?? 'My Rides'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('driverId', isEqualTo: currentUser!.uid)
            .orderBy('createdAt', descending: true) // Order by creation time
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    '${localizations?.error ?? 'Error'}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(localizations?.noRidesFound ?? 'No rides found.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final rideDoc = snapshot.data!.docs[index];
              final rideData = rideDoc.data() as Map<String, dynamic>;
              final rideId = rideDoc.id;

              // Parse Timestamp to DateTime if it's not already
              DateTime rideDateTime;
              if (rideData['dateTime'] is Timestamp) {
                rideDateTime = (rideData['dateTime'] as Timestamp).toDate();
              } else {
                rideDateTime = DateTime.parse(rideData['dateTime']
                    .toString()); // Fallback for direct DateTime strings if any
              }

              final String formattedDateTime =
                  DateFormat('yyyy-MM-dd HH:mm').format(rideDateTime);
              final String currentStatus =
                  rideData['status'] ?? 'active'; // Default to active

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localizations?.fromWhere ?? 'From'}: ${rideData['fromLocation']}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${localizations?.toWhere ?? 'To'}: ${rideData['toLocation']}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                          '${localizations?.dateTime ?? 'Date & Time'}: $formattedDateTime'),
                      Text(
                          '${localizations?.price ?? 'Price'}: ${rideData['price']}'),
                      Text(
                          '${localizations?.neededPassengers ?? 'Passengers'}: ${rideData['neededPassengers']}'),
                      if (rideData['additionalPhoneNumber'] != null &&
                          rideData['additionalPhoneNumber'].isNotEmpty)
                        Text(
                            '${localizations?.additionalPhoneNumber ?? 'Additional Phone'}: ${rideData['additionalPhoneNumber']}'),
                      Text(
                          '${localizations?.deliversObjects ?? 'Delivers Objects'}: ${rideData['deliversObjects'] ? (localizations?.yes ?? 'Yes') : (localizations?.no ?? 'No')}'),
                      Text(
                          '${localizations?.isDailyRide ?? 'Daily Ride'}: ${rideData['isDailyRide'] ? (localizations?.yes ?? 'Yes') : (localizations?.no ?? 'No')}'),
                      Text(
                          '${localizations?.status ?? 'Status'}: ${currentStatus == 'active' ? (localizations?.activeStatus ?? 'Active') : (localizations?.frozenStatus ?? 'Frozen')}'),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                _toggleRideStatus(rideId, currentStatus),
                            icon: Icon(
                              currentStatus == 'active'
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: Colors.white,
                            ),
                            label: Text(
                              currentStatus == 'active'
                                  ? (localizations?.freezeButton ?? 'Freeze')
                                  : (localizations?.activateButton ??
                                      'Activate'),
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentStatus == 'active'
                                  ? Colors.orange
                                  : Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final bool? confirmDelete =
                                  await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(localizations?.confirmDelete ??
                                      'Confirm Delete'),
                                  content: Text(localizations
                                          ?.confirmDeleteRide ??
                                      'Are you sure you want to delete this ride?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                          localizations?.cancel ?? 'Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                          localizations?.delete ?? 'Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmDelete == true) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('rides')
                                      .doc(rideId)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(localizations
                                                ?.rideDeletedSuccessfully ??
                                            'Ride deleted successfully!')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${localizations?.error ?? 'Error'}: $e')),
                                  );
                                }
                              }
                            },
                            tooltip: localizations?.delete ?? 'Delete',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
