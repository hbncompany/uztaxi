import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'localizations.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPhoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _usernameController = TextEditingController();
  String _verificationId = '';
  bool _isPhoneVerificationSent = false;
  File? _profileImage;
  bool _isAdmin = false;
  bool _isLoading = true;
  bool _isAdminPanelExpanded = false;
  String? _selectedEditOption;

  final List<String> _editOptions = [
    'Username',
    'Email',
    'Password',
    'Phone Number',
    'Profile Photo',
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadUserData();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true);
      setState(() {
        _isAdmin = idTokenResult.claims?['admin'] == true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _usernameController.text = doc.data()?['username'] ?? '';
        });
      }
    }
  }

  Future<void> _updateEmail(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_newEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.enterNewEmail ?? 'Enter new email',
          ),
        ),
      );
      return;
    }

    try {
      await user.updateEmail(_newEmailController.text);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'email': _newEmailController.text},
        SetOptions(merge: true),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.emailUpdated ?? 'Email updated',
          ),
        ),
      );
      setState(() {
        _newEmailController.clear();
        _selectedEditOption = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.updateError ?? 'Update error'}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _updatePassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.enterNewPassword ??
                'Enter new password',
          ),
        ),
      );
      return;
    }

    try {
      await user.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.passwordUpdated ?? 'Password updated',
          ),
        ),
      );
      setState(() {
        _newPasswordController.clear();
        _selectedEditOption = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.updateError ?? 'Update error'}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _verifyNewPhoneNumber(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.emailNotVerified ??
                'Email must be verified to change phone number',
          ),
        ),
      );
      return;
    }

    if (_newPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.enterNewPhone ??
                'Enter new phone number',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _newPhoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await user.updatePhoneNumber(credential);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
            {'phoneNumber': _newPhoneController.text},
            SetOptions(merge: true),
          );
          setState(() {
            _isPhoneVerificationSent = false;
            _selectedEditOption = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.phoneUpdated ??
                    'Phone number updated',
              ),
            ),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.message ??
                    (AppLocalizations.of(context)?.phoneVerificationError ??
                        'Phone verification error'),
              ),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isPhoneVerificationSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.smsCodeSent ?? 'SMS code sent',
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.error ?? 'Error'}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _updatePhoneNumber(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.enterSmsCode ?? 'Enter SMS code',
          ),
        ),
      );
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text,
      );
      await user.updatePhoneNumber(credential);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'phoneNumber': _newPhoneController.text},
        SetOptions(merge: true),
      );
      setState(() {
        _isPhoneVerificationSent = false;
        _newPhoneController.clear();
        _codeController.clear();
        _selectedEditOption = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.phoneUpdated ??
                'Phone number updated',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.updateError ?? 'Update error'}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _updateUsername(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.username ?? 'Enter username',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'username': _usernameController.text},
        SetOptions(merge: true),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.usernameUpdated ?? 'Username updated',
          ),
        ),
      );
      setState(() {
        _usernameController.clear();
        _selectedEditOption = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.updateError ?? 'Update error'}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfileImage(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _profileImage == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos/${user.uid}.jpg');
      await storageRef.putFile(_profileImage!);
      final photoUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'photoUrl': photoUrl},
        SetOptions(merge: true),
      );
      setState(() {
        _profileImage = null;
        _selectedEditOption = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.photoUpdated ??
                'Profile photo updated',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.updateError ?? 'Update error'}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      await FirebaseStorage.instance
          .ref()
          .child('profile_photos/${user.uid}.jpg')
          .delete()
          .catchError((e) {});
      await user.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.accountDeleted ?? 'Account deleted',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.error ?? 'Error'}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _toggleBlockUser(String uid, bool isBlocked) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'isBlocked': !isBlocked},
        SetOptions(merge: true),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !isBlocked
                ? (AppLocalizations.of(context)?.userBlocked ?? 'User blocked')
                : (AppLocalizations.of(context)?.userUnblocked ??
                    'User unblocked'),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.error ?? 'Error'}: $e',
          ),
        ),
      );
    }
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    List<Color> colors = const [Color(0xFF2196F3), Color(0xFF26A69A)],
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localizations?.profileTitle ?? 'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xffc1f1e5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: localizations?.userDataTab ?? 'User Data'),
              Tab(text: localizations?.editDataTab ?? 'Edit Data'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: Color(0xFFFF9800),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // User Data Tab
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF2196F3),
                                              Color(0xFF26A69A)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(4),
                                        child: user != null
                                            ? StreamBuilder<DocumentSnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(user.uid)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  String photoUrl = '';
                                                  if (snapshot.hasData &&
                                                      snapshot.data!.exists) {
                                                    final data =
                                                        snapshot.data!.data()
                                                            as Map<String,
                                                                dynamic>?;
                                                    photoUrl = data != null &&
                                                            data.containsKey(
                                                                'photoUrl')
                                                        ? data['photoUrl'] ?? ''
                                                        : '';
                                                  }
                                                  return CircleAvatar(
                                                    radius: 60,
                                                    backgroundImage: photoUrl
                                                            .isNotEmpty
                                                        ? CachedNetworkImageProvider(
                                                            photoUrl)
                                                        : AssetImage(
                                                                'assets/images/default_profile.png')
                                                            as ImageProvider,
                                                  );
                                                },
                                              )
                                            : CircleAvatar(
                                                radius: 60,
                                                backgroundImage: AssetImage(
                                                    'assets/images/default_profile.png'),
                                              ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  if (user != null) ...[
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        String username = '';
                                        String email = user.email ??
                                            localizations?.notSet ??
                                            'Not set';
                                        String phoneNumber = user.phoneNumber ??
                                            localizations?.notSet ??
                                            'Not set';
                                        if (snapshot.hasData &&
                                            snapshot.data!.exists) {
                                          final data = snapshot.data!.data()
                                              as Map<String, dynamic>?;
                                          print(data);
                                          username = data != null &&
                                                  data.containsKey('username')
                                              ? data['username'] ?? ''
                                              : '';
                                          email = data != null &&
                                                  data.containsKey('email')
                                              ? data['email'] ??
                                                  user.email ??
                                                  localizations?.notSet ??
                                                  'Not set'
                                              : user.email ??
                                                  localizations?.notSet ??
                                                  'Not set';
                                          phoneNumber = data != null &&
                                                  data.containsKey(
                                                      'phoneNumber')
                                              ? data['phoneNumber'] ??
                                                  user.phoneNumber ??
                                                  localizations?.notSet ??
                                                  'Not set'
                                              : user.phoneNumber ??
                                                  localizations?.notSet ??
                                                  'Not set';
                                        }
                                        return Column(
                                          children: [
                                            Text(
                                              username.isNotEmpty
                                                  ? username
                                                  : localizations?.notSet ??
                                                      'Not set',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              email,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[600]),
                                            ),
                                            Text(
                                              phoneNumber,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        FadeInUp(
                          child: _buildGradientButton(
                            text: localizations?.logout ?? 'Logout',
                            icon: Icons.logout,
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pop(context);
                            },
                            colors: [Color(0xFFFF9800), Color(0xFFF44336)],
                          ),
                        ),
                        SizedBox(height: 12),
                        FadeInUp(
                          delay: Duration(milliseconds: 100),
                          child: _buildGradientButton(
                            text: localizations?.deleteAccount ??
                                'Delete Account',
                            icon: Icons.delete_forever,
                            onPressed: () => _deleteAccount(context),
                            colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit Data Tab
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInLeft(
                          child: Text(
                            localizations?.editDataTab ?? 'Edit Data',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInLeft(
                          delay: Duration(milliseconds: 100),
                          child: DropdownButton<String>(
                            value: _selectedEditOption,
                            hint: Text(localizations?.selectDataToEdit ??
                                'Select data to edit'),
                            isExpanded: true,
                            items: _editOptions.map((option) {
                              String localizedOption = option;
                              switch (option) {
                                case 'Username':
                                  localizedOption =
                                      localizations?.username ?? 'Username';
                                  break;
                                case 'Email':
                                  localizedOption =
                                      localizations?.email ?? 'Email';
                                  break;
                                case 'Password':
                                  localizedOption =
                                      localizations?.password ?? 'Password';
                                  break;
                                case 'Phone Number':
                                  localizedOption =
                                      localizations?.phone ?? 'Phone Number';
                                  break;
                                case 'Profile Photo':
                                  localizedOption =
                                      localizations?.profilePhoto ??
                                          'Profile Photo';
                                  break;
                              }
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(localizedOption),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedEditOption = value;
                                _newEmailController.clear();
                                _newPasswordController.clear();
                                _newPhoneController.clear();
                                _codeController.clear();
                                _usernameController.clear();
                                _profileImage = null;
                                _isPhoneVerificationSent = false;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        if (_selectedEditOption == 'Username') ...[
                          FadeInLeft(
                            delay: Duration(milliseconds: 200),
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText:
                                    localizations?.username ?? 'Username',
                                prefixIcon: Icon(Icons.person,
                                    color: Color(0xFF2196F3)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInLeft(
                            delay: Duration(milliseconds: 300),
                            child: _buildGradientButton(
                              text: localizations?.updateUsernameButton ??
                                  'Update Username',
                              icon: Icons.update,
                              onPressed: () => _updateUsername(context),
                            ),
                          ),
                        ],
                        if (_selectedEditOption == 'Email') ...[
                          FadeInLeft(
                            delay: Duration(milliseconds: 200),
                            child: TextField(
                              controller: _newEmailController,
                              decoration: InputDecoration(
                                labelText:
                                    localizations?.newEmail ?? 'New email',
                                prefixIcon:
                                    Icon(Icons.email, color: Color(0xFF2196F3)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInLeft(
                            delay: Duration(milliseconds: 300),
                            child: _buildGradientButton(
                              text: localizations?.updateEmailButton ??
                                  'Update Email',
                              icon: Icons.email,
                              onPressed: () => _updateEmail(context),
                            ),
                          ),
                        ],
                        if (_selectedEditOption == 'Password') ...[
                          FadeInLeft(
                            delay: Duration(milliseconds: 200),
                            child: TextField(
                              controller: _newPasswordController,
                              decoration: InputDecoration(
                                labelText: localizations?.newPassword ??
                                    'New password',
                                prefixIcon:
                                    Icon(Icons.lock, color: Color(0xFF2196F3)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInLeft(
                            delay: Duration(milliseconds: 300),
                            child: _buildGradientButton(
                              text: localizations?.updatePasswordButton ??
                                  'Update Password',
                              icon: Icons.lock,
                              onPressed: () => _updatePassword(context),
                            ),
                          ),
                        ],
                        if (_selectedEditOption == 'Phone Number') ...[
                          FadeInLeft(
                            delay: Duration(milliseconds: 200),
                            child: TextField(
                              controller: _newPhoneController,
                              decoration: InputDecoration(
                                labelText: localizations?.newPhone ??
                                    'New phone number (+998)',
                                prefixIcon:
                                    Icon(Icons.phone, color: Color(0xFF2196F3)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          SizedBox(height: 12),
                          FadeInLeft(
                            delay: Duration(milliseconds: 300),
                            child: _buildGradientButton(
                              text: localizations?.verifyNewPhoneButton ??
                                  'Verify New Phone',
                              icon: Icons.phone,
                              onPressed: () => _verifyNewPhoneNumber(context),
                            ),
                          ),
                          if (_isPhoneVerificationSent) ...[
                            SizedBox(height: 12),
                            FadeInLeft(
                              delay: Duration(milliseconds: 400),
                              child: TextField(
                                controller: _codeController,
                                decoration: InputDecoration(
                                  labelText:
                                      localizations?.smsCode ?? 'SMS code',
                                  prefixIcon:
                                      Icon(Icons.sms, color: Color(0xFF2196F3)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(height: 12),
                            FadeInLeft(
                              delay: Duration(milliseconds: 500),
                              child: _buildGradientButton(
                                text: localizations?.updatePhoneButton ??
                                    'Update Phone Number',
                                icon: Icons.check,
                                onPressed: () => _updatePhoneNumber(context),
                              ),
                            ),
                          ],
                        ],
                        if (_selectedEditOption == 'Profile Photo') ...[
                          FadeInLeft(
                            delay: Duration(milliseconds: 200),
                            child: _buildGradientButton(
                              text: localizations?.pickPhoto ??
                                  'Pick Profile Photo',
                              icon: Icons.image,
                              onPressed: _pickImage,
                            ),
                          ),
                          if (_profileImage != null) ...[
                            SizedBox(height: 12),
                            FadeInLeft(
                              delay: Duration(milliseconds: 300),
                              child: _buildGradientButton(
                                text: localizations?.uploadPhoto ??
                                    'Upload Profile Photo',
                                icon: Icons.upload,
                                onPressed: () => _uploadProfileImage(context),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: _isAdmin
            ? FadeInUp(
                delay: Duration(milliseconds: 200),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          localizations?.adminSection ?? 'Admin Panel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            _isAdminPanelExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Color(0xFF2196F3),
                          ),
                          onPressed: () {
                            setState(() {
                              _isAdminPanelExpanded = !_isAdminPanelExpanded;
                            });
                          },
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: Container(),
                        secondChild: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              final users = snapshot.data!.docs;
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: users.length,
                                itemBuilder: (context, index) {
                                  final userData = users[index].data()
                                      as Map<String, dynamic>;
                                  final uid = users[index].id;
                                  final isBlocked =
                                      userData['isBlocked'] ?? false;
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Color(0xFF2196F3),
                                        child: Text(
                                          userData['username']
                                                  ?.substring(0, 1)
                                                  .toUpperCase() ??
                                              'U',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text(
                                        userData['username'] ?? 'No username',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Email: ${userData['email'] ?? 'N/A'}\nPhone: ${userData['phoneNumber'] ?? 'N/A'}',
                                      ),
                                      trailing: Switch(
                                        value: isBlocked,
                                        onChanged: (value) =>
                                            _toggleBlockUser(uid, isBlocked),
                                        activeColor: Color(0xFF2196F3),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        crossFadeState: _isAdminPanelExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
