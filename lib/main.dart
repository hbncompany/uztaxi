import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:uztaxi/auth_screen.dart';
// NEW IMPORT: Import the HomePage we created earlier
import 'home_page.dart';
import 'firebase_options.dart';
import 'localizations.dart';
// Note: table_calendar, intl, pie_chart, profile_page, notifications imports
// are kept for context but might not be directly used in this specific file's logic.
import 'dart:async'; // <--- ADDED THIS LINE FOR StreamSubscription

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
  final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await localNotificationsPlugin.initialize(initSettings);

  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );
  const platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await localNotificationsPlugin.show(
    0,
    message.notification?.title ?? 'New Notification',
    message.notification?.body ?? 'You have a new update!',
    platformChannelSpecifics,
    payload: jsonEncode(message.data),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Request notification permissions early in the app lifecycle
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('uz', 'UZ');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'uz';
    final countryCode = prefs.getString('country_code') ?? 'UZ';
    setState(() {
      _locale = Locale(languageCode, countryCode);
    });
  }

  void _setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode!);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales, // Use supportedLocales from AppLocalizations
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: AuthWrapper(onLocaleChange: _setLocale),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final bool allowGuestAccess;

  AuthWrapper({Key? key, required this.onLocaleChange, this.allowGuestAccess = false}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _authStateSubscription;
  StreamSubscription? _fcmTokenRefreshSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _saveFcmToken(user);
      }
    });

    _fcmTokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _saveFcmToken(user);
      }
    });

    // Attempt to save token immediately if user is already logged in on app start
    final initialUser = FirebaseAuth.instance.currentUser;
    if (initialUser != null) {
      _saveFcmToken(initialUser);
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _fcmTokenRefreshSubscription?.cancel();
    super.dispose();
  }

  Future<void> _saveFcmToken(User user) async {
    try {
      // It's good practice to ensure permissions are requested, though we do it in main too.
      // This check can prevent errors if permissions were revoked or not given initially.
      NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {

        String? fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          print('FCM Token: $fcmToken');
          await _firestore.collection('users').doc(user.uid).set({
            'fcmToken': fcmToken,
            'lastTokenUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print('FCM token saved successfully for user ${user.uid}');
        } else {
          print('Failed to get FCM token for user ${user.uid}.');
        }
      } else {
        print('Notification permissions not granted for user ${user.uid}. Cannot save FCM token.');
      }
    } catch (e) {
      print('Error saving FCM token for user ${user.uid}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If user is logged in OR guest access is explicitly allowed
        if (snapshot.hasData || widget.allowGuestAccess) {
          return HomePage(
            onLocaleChange: widget.onLocaleChange,
            allowGuestAccess: widget.allowGuestAccess,
          );
        }
        // If not logged in and guest access not allowed, go to AuthScreen
        return AuthScreen(
          onLocaleChange: widget.onLocaleChange,
        );
      },
    );
  }
}

// Keep InvitationsScreen as it was, no changes needed for FCM here directly
class InvitationsScreen extends StatefulWidget {
  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
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
            return const Center(child: CircularProgressIndicator());
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
            padding: const EdgeInsets.all(16),
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
                        title: Text(localizations?.loading ?? 'Loading...'));
                  }
                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return ListTile(
                        title: Text(localizations?.error ?? 'Error'));
                  }
                  final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>?;
                  final phoneNumber = userData?['phoneNumber'] ??
                      localizations?.notSet ??
                      'Not set';

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                          '${localizations?.invitationFrom ?? 'Invitation from'}: $phoneNumber'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await _acceptInvitation(
                                  primaryUserId, invitations[index].id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
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
