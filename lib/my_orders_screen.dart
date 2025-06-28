import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening external URLs
import 'localizations.dart'; // Ensure this path is correct

class MyOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String _userRole = 'client'; // Default, will be fetched
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userRole = userDoc.data()?['role'] ?? 'client';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  // NEW: Function to open map link
  Future<void> _openMapLink(double latitude, double longitude) async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final Uri url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.cannotLaunchMap ?? 'Could not launch map.')),
      );
    }
  }

  // Function to remove a client's offer
  Future<void> _removeOffer(String offerId) async {
    final localizations = AppLocalizations.of(context);
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations?.confirmDelete ?? 'Confirm Delete'),
          content: Text(localizations?.confirmDeleteOffer ?? 'Are you sure you want to remove this offer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations?.delete ?? 'Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('ride_offers').doc(offerId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.offerRemovedSuccessfully ?? 'Offer removed successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations?.failedToRemoveOffer ?? 'Failed to remove offer'}: $e')),
        );
        print('Error removing offer: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations?.myOrders ?? 'My Orders'),
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
          child: Text(localizations?.loginRequired ?? 'Please log in to view your orders.'),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations?.myOrders ?? 'My Orders'),
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Determine the query based on user role
    Query<Map<String, dynamic>> ordersQuery;
    String titleText;
    String noOrdersText;

    if (_userRole == 'client') {
      ordersQuery = FirebaseFirestore.instance
          .collection('ride_offers')
          .where('clientId', isEqualTo: currentUser!.uid)
          .orderBy('createdAt', descending: true);
      titleText = localizations?.clientOffersTitle ?? 'Your Ride Offers';
      noOrdersText = localizations?.noClientOffers ?? 'You have not sent any ride offers yet.';
    } else { // Driver
      ordersQuery = FirebaseFirestore.instance
          .collection('ride_offers')
          .where('driverId', isEqualTo: currentUser!.uid)
          .where('status', isEqualTo: 'accepted') // Drivers only see accepted offers in this view
          .orderBy('respondedAt', descending: true); // Order by when they accepted
      titleText = localizations?.driverAcceptedOffersTitle ?? 'Your Accepted Client Offers';
      noOrdersText = localizations?.noDriverAcceptedOffers ?? 'You have no accepted client offers.';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
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
        stream: ordersQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${localizations?.error ?? 'Error'}: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(noOrdersText));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final orderDoc = snapshot.data!.docs[index];
              final orderData = orderDoc.data() as Map<String, dynamic>;

              final String status = orderData['status'] ?? 'unknown';
              Color statusColor;
              String statusText;

              switch (status) {
                case 'pending':
                  statusColor = Colors.orange;
                  statusText = localizations?.pendingStatus ?? 'Pending';
                  break;
                case 'accepted':
                  statusColor = Colors.green;
                  statusText = localizations?.acceptedStatus ?? 'Accepted';
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  statusText = localizations?.rejectedStatus ?? 'Rejected';
                  break;
                case 'cancelled':
                  statusColor = Colors.grey;
                  statusText = localizations?.cancelledStatus ?? 'Cancelled';
                  break;
                default:
                  statusColor = Colors.blueGrey;
                  statusText = localizations?.unknownStatus ?? 'Unknown';
              }

              // Fetch ride details using FutureBuilder
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('rides').doc(orderData['rideId']).get(),
                builder: (context, rideSnapshot) {
                  if (rideSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      key: ValueKey(orderDoc.id),
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text(localizations?.loadingRideDetails ?? 'Loading ride details...'),
                          ],
                        ),
                      ),
                    );
                  }

                  Map<String, dynamic>? rideData;
                  if (rideSnapshot.hasData && rideSnapshot.data!.exists) {
                    rideData = rideSnapshot.data!.data() as Map<String, dynamic>;
                  }

                  // Retrieve takeOverLocation
                  final Map<String, dynamic>? takeOverLocation = orderData['takeOverLocation'] is Map
                      ? orderData['takeOverLocation'] as Map<String, dynamic>
                      : null;

                  return Card(
                      key: ValueKey(orderDoc.id),
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${localizations?.offerFor ?? 'Offer for'}: ${rideData?['fromLocation'] ?? 'N/A'} - ${rideData?['toLocation'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('${localizations?.dateTime ?? 'Date & Time'}: ${_formatTimestamp(rideData?['dateTime'] as Timestamp?)}'),
                          SizedBox(height: 8),
                          if (_userRole == 'client') ...[
                  FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(orderData['driverId']).get(),
                  builder: (context, driverSnapshot) {
                  if (driverSnapshot.connectionState == ConnectionState.waiting) {
                  return Text('${localizations?.driverInfo ?? 'Driver Info'}: ${localizations?.loading ?? 'Loading...'}');
                  }
                  if (driverSnapshot.hasError || !driverSnapshot.hasData || !driverSnapshot.data!.exists) {
                  return Text('${localizations?.driverInfo ?? 'Driver Info'}: ${localizations?.notAvailable ?? 'Not Available'}');
                  }
                  final driverData = driverSnapshot.data!.data() as Map<String, dynamic>;
                  final driverUsername = driverData['username'] ?? 'N/A';
                  final driverPhoneNumber = driverData['phoneNumber'] ?? 'N/A';
                  return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('${localizations?.driverUsername ?? 'Driver Username'}: $driverUsername'),
                  Text('${localizations?.driverPhoneNumber ?? 'Driver Phone'}: $driverPhoneNumber'),
                  ],
                  );
                  },
                  ),
                  ] else ...[ // Driver view
                  Text('${localizations?.clientUsername ?? 'Client Username'}: ${orderData['clientUsername'] ?? 'N/A'}'),
                  Text('${localizations?.clientPhoneNumber ?? 'Client Phone'}: ${orderData['clientPhoneNumber'] ?? 'N/A'}'),
                  ],
                  Text('${localizations?.offeredPrice ?? 'Offered Price'}: ${orderData['offerPrice']}'),
                  if (orderData['requestedPassengers'] != null)
                  Text('${localizations?.requestedPassengers ?? 'Requested Passengers'}: ${orderData['requestedPassengers']}'),
                  if (orderData['isShipmentRequest'] == true)
                  Text(localizations?.isShipmentRequest ?? 'Is Shipment Request: Yes'),

                  // NEW: Display and link takeOverLocation
                  if (takeOverLocation != null && takeOverLocation['address'] != null && takeOverLocation['address'].isNotEmpty)
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('${localizations?.takeOverLocation ?? 'Take Over Location'}: ${takeOverLocation['address']}'),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                  onPressed: () => _openMapLink(takeOverLocation['latitude'], takeOverLocation['longitude']),
                  icon: Icon(Icons.location_on, color: Colors.white),
                  label: Text(
                  localizations?.viewOnMap ?? 'View on Map',
                  style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  ),
                  ],
                  )
                  else if (orderData['takeOverLocation'] != null && orderData['takeOverLocation'].isNotEmpty)
                  Text('${localizations?.takeOverLocation ?? 'Take Over Location'}: ${orderData['takeOverLocation']}'), // Fallback for old string format

                  if (orderData['clientComment'] != null && orderData['clientComment'].isNotEmpty)
                  Text('${localizations?.clientComment ?? 'Client Comment'}: ${orderData['clientComment']}'),
                  if (orderData['driverComment'] != null && orderData['driverComment'].isNotEmpty)
                  Text('${localizations?.driverComment ?? 'Driver Comment'}: ${orderData['driverComment']}'),
                  Text('${localizations?.sentAt ?? 'Sent At'}: ${_formatTimestamp(orderData['createdAt'] as Timestamp?)}'),
                  if (orderData['respondedAt'] != null)
                  Text('${localizations?.respondedAt ?? 'Responded At'}: ${_formatTimestamp(orderData['respondedAt'] as Timestamp?)}'),

                  // Remove Order Button for Client
                  if (_userRole == 'client' && (status == 'pending' || status == 'cancelled'))
                  Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                  onPressed: () => _removeOffer(orderDoc.id),
                  icon: Icon(Icons.delete_forever, color: Colors.white),
                  label: Text(
                  localizations?.removeOrder ?? 'Remove Order',
                  style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  ),
                  ),
                  ],
                  ),
                  ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
