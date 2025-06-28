import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:url_launcher/url_launcher.dart'; // For opening external URLs
import 'localizations.dart'; // Ensure this path is correct


class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  String _userRole = 'client'; // Default, will be fetched

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  @override
  void dispose() {
    // Dispose of any controllers used in dialogs if they were stateful beyond their scope
    super.dispose();
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

  Future<void> _handleOfferAction(String offerId, String status, String driverComment) async {
    final localizations = AppLocalizations.of(context);
    try {
      await FirebaseFirestore.instance.collection('ride_offers').doc(offerId).update({
        'status': status,
        'driverComment': driverComment,
        'respondedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.offerStatusUpdated ?? 'Offer status updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations?.errorUpdatingOffer ?? 'Error updating offer'}: $e')),
      );
    }
  }

  void _showOfferActionDialog(String offerId, String actionType) {
    final localizations = AppLocalizations.of(context);
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(actionType == 'accept'
              ? (localizations?.acceptOffer ?? 'Accept Offer')
              : (localizations?.rejectOffer ?? 'Reject Offer')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(localizations?.addCommentOptional ?? 'Add a comment (optional):'),
              TextFormField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: localizations?.yourComment ?? 'Your comment...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                commentController.dispose();
              },
              child: Text(localizations?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _handleOfferAction(
                  offerId,
                  actionType == 'accept' ? 'accepted' : 'rejected',
                  commentController.text.trim(),
                );
                Navigator.of(dialogContext).pop();
                commentController.dispose();
              },
              child: Text(actionType == 'accept' ? (localizations?.accept ?? 'Accept') : (localizations?.reject ?? 'Reject')),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations?.notificationsTitle ?? 'Notifications'),
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
          child: Text(localizations?.loginRequired ?? 'Please log in to view notifications.'),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations?.notificationsTitle ?? 'Notifications'),
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

    return DefaultTabController(
      length: _userRole == 'driver' ? 2 : 1, // Drivers see "Offers" and "General", Clients only "General"
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations?.notificationsTitle ?? 'Notifications'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF26A69A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            tabs: _userRole == 'driver'
                ? [
              Tab(text: localizations?.rideOffers ?? 'Ride Offers'),
              Tab(text: localizations?.generalNotifications ?? 'General'),
            ]
                : [
              Tab(text: localizations?.generalNotifications ?? 'General'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: _userRole == 'driver'
              ? [
            // Driver Ride Offers Tab
            _buildDriverRideOffersTab(localizations),
            // General Notifications Tab
            _buildGeneralNotificationsTab(localizations),
          ]
              : [
            // Client General Notifications Tab
            _buildGeneralNotificationsTab(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralNotificationsTab(AppLocalizations? localizations) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${localizations?.error ?? 'Error'}: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(localizations?.noNotifications ?? 'No general notifications.'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final notificationDoc = snapshot.data!.docs[index];
            final notificationData = notificationDoc.data() as Map<String, dynamic>;

            // Basic display for general notifications
            return Card(
              key: ValueKey(notificationDoc.id), // Added Key
              margin: EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(notificationData['title'] ?? 'Notification'),
                subtitle: Text(notificationData['body'] ?? 'No content'),
                trailing: Text(notificationData['timestamp'] != null
                    ? DateFormat('HH:mm').format((notificationData['timestamp'] as Timestamp).toDate())
                    : ''),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDriverRideOffersTab(AppLocalizations? localizations) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ride_offers')
          .where('driverId', isEqualTo: currentUser!.uid)
          .where('status', isEqualTo: 'pending') // Only show pending offers here
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${localizations?.error ?? 'Error'}: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(localizations?.noPendingOffers ?? 'No pending ride offers.'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final offerDoc = snapshot.data!.docs[index];
            final offerData = offerDoc.data() as Map<String, dynamic>;

            DateTime offerCreatedAt;
            if (offerData['createdAt'] is Timestamp) {
              offerCreatedAt = (offerData['createdAt'] as Timestamp).toDate();
            } else {
              offerCreatedAt = DateTime.parse(offerData['createdAt'].toString());
            }
            final String formattedTime = DateFormat('HH:mm').format(offerCreatedAt);

            // Retrieve takeOverLocation
            final Map<String, dynamic>? takeOverLocation = offerData['takeOverLocation'] is Map
                ? offerData['takeOverLocation'] as Map<String, dynamic>
                : null;

            return Card(
                key: ValueKey(offerDoc.id), // Added Key
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                    localizations?.newRideOffer ?? 'New Ride Offer!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${localizations?.fromClient ?? 'From Client'}: ${offerData['clientUsername'] ?? offerData['clientPhoneNumber'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text('${localizations?.offeredPrice ?? 'Offered Price'}: ${offerData['offerPrice']}'),
                    if (offerData['requestedPassengers'] != null)
                Text('${localizations?.requestedPassengers ?? 'Requested Passengers'}: ${offerData['requestedPassengers']}'),
            if (offerData['isShipmentRequest'] == true)
            Text(localizations?.isShipmentRequest ?? 'Is Shipment Request: Yes'),

            // NEW: Display and link takeOverLocation for driver
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
            else if (offerData['takeOverLocation'] != null && offerData['takeOverLocation'].isNotEmpty && offerData['takeOverLocation'] is String)
            Text('${localizations?.takeOverLocation ?? 'Take Over Location'}: ${offerData['takeOverLocation']}'), // Fallback for old string format

            if (offerData['clientComment'] != null && offerData['clientComment'].isNotEmpty)
            Text('${localizations?.clientComment ?? 'Client Comment'}: ${offerData['clientComment']}'),
            Text('${localizations?.sentAt ?? 'Sent At'}: $formattedTime'),
            SizedBox(height: 12),
            Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
            ElevatedButton.icon(
            onPressed: () => _showOfferActionDialog(offerDoc.id, 'accept'),
            icon: Icon(Icons.check, color: Colors.white),
            label: Text(
            localizations?.accept ?? 'Accept',
            style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            ),
            SizedBox(width: 8),
            ElevatedButton.icon(
            onPressed: () => _showOfferActionDialog(offerDoc.id, 'reject'),
            icon: Icon(Icons.close, color: Colors.white),
            label: Text(
            localizations?.reject ?? 'Reject',
            style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
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
    );
  }
}

class InvitationsScreen extends StatefulWidget {
  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
            child: Text(localizations?.loginRequired ?? 'Please log in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.invitations ?? 'Invitations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('invitations')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child:
                Text(localizations?.error ?? 'Error: ${snapshot.error}'));
          }
          final invitations = snapshot.data?.docs ?? [];
          if (invitations.isEmpty) {
            return Center(
                child: Text(localizations?.noInvitations ?? 'No invitations'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              final invitation =
              invitations[index].data() as Map<String, dynamic>;
              final primaryUserId = invitation['primaryUserId'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(primaryUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                        key: ValueKey(invitations[index].id), // Added Key
                        title: Text(localizations?.loading ?? 'Loading...'));
                  }
                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return ListTile(
                        key: ValueKey(invitations[index].id), // Added Key
                        title: Text(localizations?.error ?? 'Error'));
                  }
                  final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>?;
                  final phoneNumber = userData?['phoneNumber'] ??
                      localizations?.notSet ??
                      'Not set';

                  return Card(
                    key: ValueKey(invitations[index].id), // Added Key
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                          '${localizations?.invitationFrom ?? 'Invitation from'}: $phoneNumber'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await _acceptInvitation(
                                  primaryUserId, invitations[index].id);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () async {
                              await _cancelInvitation(invitations[index].id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      localizations?.invitationCanceled ??
                                          'Invitation canceled'),
                                ),
                              );
                            },
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

  Future<void> _acceptInvitation(
      String primaryUserId, String invitationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'primaryUserId': primaryUserId});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(primaryUserId)
        .collection('familyMembers')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'phoneNumber': user.phoneNumber ?? '',
      'addedAt': DateTime.now().toIso8601String(),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('invitations')
        .doc(invitationId)
        .delete();
  }

  Future<void> _cancelInvitation(String invitationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('invitations')
          .doc(invitationId)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error canceling invitation: $e'),
        ),
      );
    }
  }
}
