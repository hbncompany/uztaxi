import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:animate_do/animate_do.dart';
import 'localizations.dart';
import 'main.dart'; // Assuming AuthWrapper is defined here
import 'package:uztaxi/home_page.dart';

class AuthScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  AuthScreen({required this.onLocaleChange});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _resetEmailController = TextEditingController();

  // New controllers for driver-specific fields
  final _carNumberController = TextEditingController();
  final _carTypeController = TextEditingController();

  String _verificationId = '';
  bool _isPhoneVerificationSent = false;
  bool _usePhoneLogin = false;

  // New state for user role selection
  String _selectedRole = 'client'; // Default to client

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _usernameController.dispose();
    _resetEmailController.dispose();
    _carNumberController.dispose(); // Dispose new controllers
    _carTypeController.dispose(); // Dispose new controllers
    super.dispose();
  }

  Future<void> _saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
            {
              'fcmToken': token,
              if (user.phoneNumber != null) 'phoneNumber': user.phoneNumber,
            },
            SetOptions(merge: true),
          );
          print('FCM token saved for user ${user.uid}: $token');
        } else {
          print('No FCM token available for user ${user.uid}');
        }
      } catch (e) {
        print('Error saving FCM token for user ${user.uid}: $e');
      }
    }
  }

  Future<void> _loginWithEmail(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                localizations?.fillAllFields ?? 'Please fill in all fields'),
          ),
        );
      }
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await _saveFcmToken();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.loginSuccess ?? 'Login successful'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AuthWrapper(onLocaleChange: widget.onLocaleChange),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations?.error ?? 'Error'}: $e'),
          ),
        );
      }
    }
  }

  Future<void> _startPhoneLogin(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (_phoneController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                localizations?.fillAllFields ?? 'Please fill in all fields'),
          ),
        );
      }
      return;
    }

    try {
      String normalizedPhone =
          _phoneController.text.replaceAll(RegExp(r'\s+'), '');
      if (!normalizedPhone.startsWith('+')) {
        normalizedPhone = '+$normalizedPhone';
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: normalizedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _saveFcmToken();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(localizations?.loginSuccess ?? 'Login successful'),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AuthWrapper(onLocaleChange: widget.onLocaleChange),
              ),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message ?? (localizations?.error ?? 'Error')),
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isPhoneVerificationSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations?.smsCodeSent ?? 'SMS code sent'),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations?.error ?? 'Error'}: $e'),
          ),
        );
      }
    }
  }

  Future<void> _completePhoneLogin(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (_codeController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.enterSmsCode ?? 'Enter SMS code'),
          ),
        );
      }
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _saveFcmToken();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.loginSuccess ?? 'Login successful'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AuthWrapper(onLocaleChange: widget.onLocaleChange),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations?.error ?? 'Error'}: $e'),
          ),
        );
      }
    }
  }

  Future<void> _register(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (_usernameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        (_selectedRole == 'driver' &&
            (_carNumberController.text.isEmpty ||
                _carTypeController.text.isEmpty))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                localizations?.fillAllFields ?? 'Please fill in all fields'),
          ),
        );
      }
      return;
    }

    if (!_isPhoneVerificationSent) {
      try {
        String normalizedPhone =
            _phoneController.text.replaceAll(RegExp(r'\s+'), '');
        if (!normalizedPhone.startsWith('+')) {
          normalizedPhone = '+$normalizedPhone';
        }

        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: normalizedPhone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _completeRegistration(context, credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.message ?? (localizations?.error ?? 'Error')),
                ),
              );
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            if (mounted) {
              setState(() {
                _verificationId = verificationId;
                _isPhoneVerificationSent = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations?.smsCodeSent ?? 'SMS code sent'),
                ),
              );
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations?.error ?? 'Error'}: $e'),
            ),
          );
        }
      }
    } else {
      if (_codeController.text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations?.enterSmsCode ?? 'Enter SMS code'),
            ),
          );
        }
        return;
      }

      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: _codeController.text,
        );
        await _completeRegistration(context, credential);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations?.error ?? 'Error'}: $e'),
            ),
          );
        }
      }
    }
  }

  Future<void> _completeRegistration(
      BuildContext context, PhoneAuthCredential credential) async {
    final localizations = AppLocalizations.of(context);
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await user.linkWithCredential(
          EmailAuthProvider.credential(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );

        await user.sendEmailVerification();

        String normalizedPhone =
            _phoneController.text.replaceAll(RegExp(r'\s+'), '');
        if (!normalizedPhone.startsWith('+')) {
          normalizedPhone = '+$normalizedPhone';
        }

        // Prepare user data for Firestore
        Map<String, dynamic> userData = {
          'username': _usernameController.text,
          'phoneNumber': normalizedPhone,
          'email': _emailController.text,
          'isBlocked': false,
          'role': _selectedRole, // Save the selected role
        };

        // Add driver-specific fields if the role is driver
        if (_selectedRole == 'driver') {
          userData['carNumber'] = _carNumberController.text;
          userData['carType'] = _carTypeController.text;
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
              userData,
              SetOptions(merge: true),
            );

        await _saveFcmToken();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations?.registerSuccess ??
                  'Registration successful. Please verify your email.'),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AuthWrapper(onLocaleChange: widget.onLocaleChange),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations?.error ?? 'Error'}: $e'),
          ),
        );
      }
    }
  }

  Future<void> _linkEmailAndPassword(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                localizations?.fillAllFields ?? 'Please fill in all fields'),
          ),
        );
      }
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.linkWithCredential(
          EmailAuthProvider.credential(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
        await user.sendEmailVerification();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': _emailController.text,
        }, SetOptions(merge: true));
        await _saveFcmToken();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations?.emailRegisterSuccess ??
                  'Email registration successful'),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AuthWrapper(onLocaleChange: widget.onLocaleChange),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations?.userNotFound ?? 'User not found'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(localizations?.emailLinkError ?? 'Error linking email'),
          ),
        );
      }
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (_resetEmailController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.enterEmail ?? 'Enter email'),
          ),
        );
      }
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _resetEmailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                localizations?.resetEmailSent ?? 'Password reset email sent'),
          ),
        );
        _resetEmailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations?.error ?? 'Reset email error'}: $e'),
          ),
        );
      }
    }
  }

  void _showResetPasswordDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.resetPassword ?? 'Reset Password'),
        content: TextField(
          controller: _resetEmailController,
          decoration: InputDecoration(
            labelText: localizations?.enterEmail ?? 'Enter email',
            prefixIcon: Icon(Icons.email, color: Color(0xFF2196F3)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _resetPassword(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              localizations?.sendResetLink ?? 'Send Reset Link',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FadeInUp(
      child: Container(
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations?.authTitle ?? 'Login and Registration'),
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
            tabs: [
              Tab(text: localizations?.loginTab ?? 'Login'),
              Tab(text: localizations?.registerTab ?? 'Register'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: Color(0xFFFF9800),
          ),
        ),
        body: TabBarView(
          children: [
            // Login Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  FadeInUp(
                    child: CheckboxListTile(
                      title: Text(localizations?.usePhoneLogin ??
                          'Use phone number to log in'),
                      value: _usePhoneLogin,
                      onChanged: (value) {
                        setState(() {
                          _usePhoneLogin = value ?? false;
                          _emailController.clear();
                          _phoneController.clear();
                          _passwordController.clear();
                          _codeController.clear();
                          _isPhoneVerificationSent = false;
                        });
                      },
                    ),
                  ),
                  if (!_usePhoneLogin) ...[
                    FadeInUp(
                      delay: Duration(milliseconds: 100),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: localizations?.email ?? 'Email',
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
                    SizedBox(height: 16),
                    FadeInUp(
                      delay: Duration(milliseconds: 200),
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: localizations?.password ?? 'Password',
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
                  ] else ...[
                    FadeInUp(
                      delay: Duration(milliseconds: 100),
                      child: TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText:
                              localizations?.phone ?? 'Phone number (+998)',
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
                    if (_isPhoneVerificationSent) ...[
                      SizedBox(height: 16),
                      FadeInUp(
                        delay: Duration(milliseconds: 200),
                        child: TextField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: localizations?.smsCode ?? 'SMS code',
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
                    ],
                  ],
                  SizedBox(height: 8),
                  FadeInUp(
                    delay: Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: () => _showResetPasswordDialog(context),
                      child: Text(
                        localizations?.forgotPassword ?? 'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  FadeInUp(
                    delay: Duration(milliseconds: 400),
                    child: _buildGradientButton(
                      text: localizations?.loginButton ?? 'Login',
                      icon: Icons.login,
                      onPressed: () => _usePhoneLogin
                          ? _isPhoneVerificationSent
                              ? _completePhoneLogin(context)
                              : _startPhoneLogin(context)
                          : _loginWithEmail(context),
                    ),
                  ),
                  SizedBox(height: 16),
                  FadeInUp(
                    delay: Duration(milliseconds: 500),
                    child: _buildGradientButton(
                      text: localizations?.continueWithoutLogin ??
                          'Continue without login',
                      icon: Icons.arrow_forward,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthWrapper(
                              onLocaleChange: widget.onLocaleChange,
                              allowGuestAccess: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Register Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  FadeInUp(
                    delay: Duration(milliseconds: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.selectRole ?? 'Select Role:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(localizations?.client ?? 'Client'),
                                value: 'client',
                                groupValue: _selectedRole,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text(localizations?.driver ?? 'Driver'),
                                value: 'driver',
                                groupValue: _selectedRole,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Driver-specific fields
                  if (_selectedRole == 'driver') ...[
                    SizedBox(height: 16),
                    FadeInUp(
                      delay: Duration(milliseconds: 500),
                      child: TextField(
                        controller: _carNumberController,
                        decoration: InputDecoration(
                          labelText: localizations?.carNumber ?? 'Car Number',
                          prefixIcon: Icon(Icons.directions_car,
                              color: Color(0xFF2196F3)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    SizedBox(height: 16),
                    FadeInUp(
                      delay: Duration(milliseconds: 600),
                      child: TextField(
                        controller: _carTypeController,
                        decoration: InputDecoration(
                          labelText: localizations?.carType ?? 'Car Type',
                          prefixIcon:
                              Icon(Icons.car_rental, color: Color(0xFF2196F3)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                  if (_isPhoneVerificationSent) ...[
                    SizedBox(height: 16),
                    FadeInUp(
                      delay: Duration(milliseconds: 700),
                      child: TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: localizations?.smsCode ?? 'SMS code',
                          prefixIcon: Icon(Icons.sms, color: Color(0xFF2196F3)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  FadeInUp(
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: localizations?.username ?? 'Username',
                        prefixIcon:
                            Icon(Icons.person, color: Color(0xFF2196F3)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  FadeInUp(
                    delay: Duration(milliseconds: 100),
                    child: TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText:
                            localizations?.newPhone ?? 'Phone number (+998)',
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF2196F3)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(height: 16),
                  FadeInUp(
                    delay: Duration(milliseconds: 200),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: localizations?.email ?? 'Email',
                        prefixIcon: Icon(Icons.email, color: Color(0xFF2196F3)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(height: 16),
                  FadeInUp(
                    delay: Duration(milliseconds: 300),
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: localizations?.password ?? 'Password',
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF2196F3)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(height: 16),
                  FadeInUp(
                    delay: Duration(milliseconds: 800),
                    child: _buildGradientButton(
                      text: _isPhoneVerificationSent
                          ? (localizations?.verifyAndRegisterButton ??
                              'Verify and Register')
                          : (localizations?.registerTab ?? 'Register'),
                      icon: Icons.person_add,
                      onPressed: () => _register(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
