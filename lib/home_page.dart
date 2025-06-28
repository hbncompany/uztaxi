import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'localizations.dart'; // Ensure this path is correct
// import 'main.dart'; // Assuming AuthWrapper and other common definitions are here - typically not needed here directly
import 'profile_page.dart'; // Import ProfilePage
import 'notifications.dart'; // Import NotificationsScreen and InvitationsScreen
import 'add_ride_screen.dart'; // Import the AddRideScreen
import 'my_rides_screen.dart'; // Import the MyRidesScreen
import 'book_ride_screen.dart'; // Import the BookRideScreen
import 'my_orders_screen.dart'; // Import the MyOrdersScreen
import 'package:uztaxi/auth_screen.dart'; // Correct path

class HomePage extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final bool allowGuestAccess;

  HomePage({required this.onLocaleChange, this.allowGuestAccess = false});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _userRole =
      'guest'; // Default to guest if not logged in or data not fetched yet

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    // No explicit listeners or controllers that need disposal in this specific _HomePageState,
    // as _fetchUserData uses a Future and StreamBuilders manage their own subscriptions internally.
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    // If guest access is allowed and there's no current user, treat as guest
    if (widget.allowGuestAccess && FirebaseAuth.instance.currentUser == null) {
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() {
          _userRole = 'guest';
          _isLoading = false;
        });
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          if (mounted) { // Check if the widget is still mounted before calling setState
            setState(() {
              _userData = userDoc.data();
              _userRole = _userData?['role'] ??
                  'client'; // Default to client if role not set
              _isLoading = false;
            });
          }
        } else {
          // User exists in Auth but not in Firestore, default to client
          if (mounted) { // Check if the widget is still mounted before calling setState
            setState(() {
              _userRole = 'client';
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
        if (mounted) { // Check if the widget is still mounted before calling setState on error
          setState(() {
            _isLoading = false;
            // In case of error, still try to show some content, maybe default to client
            _userRole = 'client';
          });
        }
      }
    } else {
      // No authenticated user, but not explicitly allowed as guest (should not happen if AuthWrapper works)
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() {
          _userRole = 'guest';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FadeInUp(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
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
      ),
    );
  }

  Widget _buildDriverHomePage(AppLocalizations? localizations) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeInDown(
            child: Text(
              localizations?.welcomeDriver ?? 'Welcome, Driver!',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          FadeInLeft(
            delay: Duration(milliseconds: 100),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations?.driverDetails ?? 'Your Details:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF26A69A)),
                    ),
                    SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.person,
                      label: localizations?.username ?? 'Username',
                      value: _userData?['username'] ?? 'N/A',
                    ),
                    _buildDetailRow(
                      icon: Icons.phone,
                      label: localizations?.phone ?? 'Phone',
                      value: _userData?['phoneNumber'] ?? 'N/A',
                    ),
                    _buildDetailRow(
                      icon: Icons.email,
                      label: localizations?.email ?? 'Email',
                      value: _userData?['email'] ?? 'N/A',
                    ),
                    _buildDetailRow(
                      icon: Icons.directions_car,
                      label: localizations?.carNumber ?? 'Car Number',
                      value: _userData?['carNumber'] ?? 'N/A',
                    ),
                    _buildDetailRow(
                      icon: Icons.car_rental,
                      label: localizations?.carType ?? 'Car Type',
                      value: _userData?['carType'] ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          FadeInUp(
            delay: Duration(milliseconds: 200),
            child: Text(
              localizations?.driverUtilities ?? 'Driver Utilities:',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          // Add Ride Button
          _buildGradientButton(
            text: localizations?.addRide ?? 'Add Ride',
            icon: Icons.add_road,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddRideScreen()),
              );
            },
          ),
          // My Rides Button
          _buildGradientButton(
            text: localizations?.myRides ?? 'My Rides',
            icon: Icons.list_alt,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyRidesScreen()),
              );
            },
          ),
          // My Orders Button for Driver
          _buildGradientButton(
            text: localizations?.myOrders ?? 'My Orders',
            icon: Icons.assignment,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrdersScreen()),
              );
            },
          ),
          _buildGradientButton(
            text: localizations?.viewAvailableRides ?? 'View Available Rides',
            icon: Icons.search,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(localizations?.featureComingSoon ??
                        'Feature coming soon!')),
              );
            },
          ),
          _buildGradientButton(
            text: localizations?.viewYourShipments ?? 'View Your Shipments',
            icon: Icons.local_shipping,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(localizations?.featureComingSoon ??
                        'Feature coming soon!')),
              );
            },
          ),
          _buildGradientButton(
            text: localizations?.goOnline ?? 'Go Online',
            icon: Icons.online_prediction,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(localizations?.featureComingSoon ??
                        'Feature coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClientHomePage(AppLocalizations? localizations) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeInDown(
            child: Text(
              localizations?.welcomeClient ?? 'Welcome, Client!',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          if (_userData != null)
            FadeInLeft(
              delay: Duration(milliseconds: 100),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.clientDetails ?? 'Your Details:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF26A69A)),
                      ),
                      SizedBox(height: 10),
                      _buildDetailRow(
                        icon: Icons.person,
                        label: localizations?.username ?? 'Username',
                        value: _userData?['username'] ?? 'N/A',
                      ),
                      _buildDetailRow(
                        icon: Icons.phone,
                        label: localizations?.phone ?? 'Phone',
                        value: _userData?['phoneNumber'] ?? 'N/A',
                      ),
                      _buildDetailRow(
                        icon: Icons.email,
                        label: localizations?.email ?? 'Email',
                        value: _userData?['email'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(height: 24),
          FadeInUp(
            delay: Duration(milliseconds: 200),
            child: Text(
              localizations?.clientUtilities ?? 'Client Utilities:',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          // Book a Ride Button
          _buildGradientButton(
            text: localizations?.bookARide ?? 'Book a Ride',
            icon: Icons.book_online,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BookRideScreen(onLocaleChange: widget.onLocaleChange)),
              );
            },
          ),
          // View Your Rides Button (Existing)
          _buildGradientButton(
            text: localizations?.viewYourRides ?? 'View Your Rides',
            icon: Icons.history,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(localizations?.featureComingSoon ??
                        'Feature coming soon!')),
              );
            },
          ),
          // My Orders Button for Client
          _buildGradientButton(
            text: localizations?.myOrders ?? 'My Orders',
            icon: Icons.receipt_long,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrdersScreen()),
              );
            },
          ),
          _buildGradientButton(
            text: localizations?.trackShipment ?? 'Track Shipment',
            icon: Icons.track_changes,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(localizations?.featureComingSoon ??
                        'Feature coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHomePage(AppLocalizations? localizations) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeInDown(
            child: Text(
              localizations?.welcomeGuest ?? 'Welcome, Guest!',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          FadeInUp(
            delay: Duration(milliseconds: 100),
            child: Text(
              localizations?.guestUtilities ?? 'Guest Utilities:',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          _buildGradientButton(
            text: localizations?.signUpNow ?? 'Sign Up Now',
            icon: Icons.person_add,
            onPressed: () {
              // Navigate back to AuthScreen (register tab)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AuthScreen(onLocaleChange: widget.onLocaleChange),
                ),
              );
            },
          ),
          _buildGradientButton(
            text: localizations?.loginNow ?? 'Login Now',
            icon: Icons.login,
            onPressed: () {
              // Navigate back to AuthScreen (login tab)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AuthScreen(onLocaleChange: widget.onLocaleChange),
                ),
              );
            },
          ),
          _buildGradientButton(
            text: localizations?.learnMore ?? 'Learn More',
            icon: Icons.info_outline,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(localizations?.featureComingSoon ??
                        'Feature coming soon!')),
              );
            },
          ),
          // For guests to browse rides without logging in
          _buildGradientButton(
            text: localizations?.browseRides ?? 'Browse Rides',
            icon: Icons.search,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BookRideScreen(
                        onLocaleChange:
                        widget.onLocaleChange)), // Guests can also browse
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF2196F3), size: 20),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800]),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to show login required snackbar
  void _showLoginRequiredSnackBar(
      BuildContext context, AppLocalizations? localizations) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations?.loginRequired ??
            'Please log in to access this feature'),
        action: SnackBarAction(
          label: localizations?.loginButton ?? 'Login',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AuthScreen(onLocaleChange: widget.onLocaleChange),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = widget.allowGuestAccess ||
        user == null; // Determine if current session is guest

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.homeTitle ?? 'Home'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              if (isGuest) {
                _showLoginRequiredSnackBar(context, localizations);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                );
              }
            },
            tooltip: localizations?.notificationsTitle ?? 'Notifications',
          ),
          IconButton(
            icon: Icon(Icons.mail, color: Colors.white),
            onPressed: () {
              if (isGuest) {
                _showLoginRequiredSnackBar(context, localizations);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvitationsScreen(),
                  ),
                );
              }
            },
            tooltip: localizations?.invitations ?? 'Invitations',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF26A69A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isGuest
                        ? (localizations?.welcomeGuest ?? 'Welcome, Guest!')
                        : (_userData?['username'] ??
                        user?.email ??
                        localizations?.profileTitle ??
                        'Profile'),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  if (!isGuest && user != null)
                    Text(
                      user.email ?? (localizations?.notSet ?? 'Not Set'),
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  if (!isGuest && _userData?['phoneNumber'] != null)
                    Text(
                      _userData?['phoneNumber'],
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                ],
              ),
            ),
            // Language selection
            ListTile(
              leading: Icon(Icons.language),
              title: Text(localizations?.language ?? 'Language'),
              trailing: DropdownButton<Locale>(
                value: Localizations.localeOf(context),
                items: AppLocalizations.supportedLocales.map((Locale locale) {
                  return DropdownMenuItem<Locale>(
                    value: locale,
                    child: Text(
                      locale.languageCode == 'en'
                          ? 'English'
                          : locale.languageCode == 'ru'
                          ? 'Русский'
                          : 'O‘zbek',
                      style: TextStyle(color: Colors.black87),
                    ),
                  );
                }).toList(),
                onChanged: (Locale? locale) {
                  if (locale != null) {
                    widget.onLocaleChange(locale);
                  }
                },
              ),
            ),
            // Profile page navigation
            if (!isGuest)
              ListTile(
                leading: Icon(Icons.person),
                title: Text(localizations?.profileTitle ?? 'Profile'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
            // Logout button
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(localizations?.logout ?? 'Logout'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                if (FirebaseAuth.instance.currentUser != null) {
                  await FirebaseAuth.instance.signOut();
                }
                // Always navigate back to AuthScreen after logout or if guest clicks logout
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AuthScreen(onLocaleChange: widget.onLocaleChange),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3))))
          : _userRole == 'driver'
          ? _buildDriverHomePage(localizations)
          : _userRole == 'client'
          ? _buildClientHomePage(localizations)
          : _buildGuestHomePage(localizations),
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
                        key: ValueKey(invitations[index].id), // Ensure key is present
                        title: Text(localizations?.loading ?? 'Loading...'));
                  }
                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return ListTile(
                        key: ValueKey(invitations[index].id), // Ensure key is present
                        title: Text(localizations?.error ?? 'Error'));
                  }
                  final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>?;
                  final phoneNumber = userData?['phoneNumber'] ??
                      localizations?.notSet ??
                      'Not set';

                  return Card(
                    key: ValueKey(invitations[index].id), // Ensure key is present
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
