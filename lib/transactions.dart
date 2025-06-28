import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'firebase_options.dart';
import 'localizations.dart';
import 'profile_page.dart';
import 'auth_screen.dart';
import 'notifications.dart';
import 'dart:convert';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  DateTimeRange? _selectedRange;
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _typeController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _selectedType;
  bool _isExpense = true;
  String? _editingTransactionId;
  final List<String> _defaultTypes = [
    'bank loan',
    'loan to friends',
    'salary',
    'loan from friends'
  ];
  List<String> _customTypes = [];

  @override
  void initState() {
    super.initState();
    _loadCustomTypes();
    _loadTransactions();
    _setupForegroundMessaging();
  }

  Future<void> _loadCustomTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final types = prefs.getStringList('custom_transaction_types') ?? [];
    setState(() {
      _customTypes = types;
    });
  }

  Future<void> _saveCustomTypes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_transaction_types', _customTypes);
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions') ?? '[]';
    // Load to ensure offline access, but Firestore is primary
  }

  Future<void> _saveTransaction(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (_amountController.text.isEmpty || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                localizations?.fillAllFields ?? 'Please fill in all fields')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Normalize phone number
    String? normalizedPhone = _phoneController.text.isNotEmpty
        ? _phoneController.text.replaceAll(RegExp(r'\s+'), '').startsWith('+')
            ? _phoneController.text.replaceAll(RegExp(r'\s+'), '')
            : '+${_phoneController.text.replaceAll(RegExp(r'\s+'), '')}'
        : null;

    final transactionData = {
      'amount': double.parse(_amountController.text),
      'type': _selectedType,
      'isExpense': _isExpense,
      'date': DateTime.now().toIso8601String(),
      'phoneNumber': normalizedPhone,
      'details': _detailsController.text,
    };

    bool shouldSendNotification = false;
    if (normalizedPhone != null) {
      // Show dialog to ask about sending notification
      shouldSendNotification = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title:
                  Text(localizations?.sendNotification ?? 'Send notification?'),
              content: Text(
                  '${localizations?.sendNotification ?? 'Send notification?'} ${normalizedPhone}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(localizations?.no ?? 'No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(localizations?.yes ?? 'Yes'),
                ),
              ],
            ),
          ) ??
          false;
    }

    try {
      // Save to Firestore
      String? transactionId;
      if (_editingTransactionId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(_editingTransactionId)
            .update(transactionData);
        transactionId = _editingTransactionId;
      } else {
        final docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .add(transactionData);
        transactionId = docRef.id;
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString('transactions') ?? '[]';
      final transactions = jsonDecode(transactionsJson) as List;
      if (_editingTransactionId != null) {
        final index =
            transactions.indexWhere((t) => t['id'] == _editingTransactionId);
        if (index != -1)
          transactions[index] = {
            ...transactionData,
            'id': _editingTransactionId
          };
      } else {
        transactions.add({...transactionData, 'id': transactionId});
      }
      await prefs.setString('transactions', jsonEncode(transactions));

      // Send notification if phone number exists and user confirmed
      if (shouldSendNotification && normalizedPhone != null) {
        String? queryPhone = normalizedPhone;
        if (!queryPhone.startsWith('+')) {
          queryPhone = '+$queryPhone';
        }
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phoneNumber', isEqualTo: queryPhone)
            .get();
        print(
            'Query for phone $queryPhone: ${snapshot.docs.length} users found');
        if (snapshot.docs.length > 1) {
          print('Multiple users found with phone $queryPhone:');
          snapshot.docs.forEach((doc) {
            print(' - UID: ${doc.id}, Data: ${doc.data()}');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(localizations?.multipleRecipients ??
                    'Multiple users found for this phone number')),
          );
        } else if (snapshot.docs.isNotEmpty) {
          final otherUser = snapshot.docs.first;
          final recipientUid = otherUser.id;
          print('Recipient UID: $recipientUid');
          final notificationData = {
            'fromUserId': user.uid,
            'transaction': transactionData,
            'transactionId': transactionId,
            'status': 'pending',
            'createdAt': DateTime.now().toIso8601String(),
          };
          await FirebaseFirestore.instance
              .collection('users')
              .doc(recipientUid)
              .collection('notifications')
              .add(notificationData);
          print('Notification created for user $recipientUid');
          final fcmToken = otherUser.data()['fcmToken'];
          if (fcmToken != null) {
            try {
              await FirebaseMessaging.instance.sendMessage(
                to: fcmToken,
                data: {
                  'title': localizations?.newTransaction ?? 'New Transaction',
                  'body': localizations?.newTransactionBody ??
                      'You have a new loan transaction to review.',
                },
              );
              print('FCM message sent to $fcmToken');
            } catch (e) {
              print('Error sending FCM message: $e');
            }
          } else {
            print('No FCM token found for user $recipientUid');
          }
        } else {
          print('No user found with phone $queryPhone');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    localizations?.recipientNotFound ?? 'Recipient not found')),
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(localizations?.transactionSaved ?? 'Transaction saved')),
      );
      setState(() {
        _amountController.clear();
        _phoneController.clear();
        _detailsController.clear();
        _selectedType = null;
        _isExpense = true;
        _editingTransactionId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations?.error ?? 'Error'}: $e')),
      );
      print('Error saving transaction: $e');
    }
  }

  Future<void> _deleteTransaction(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .delete();

    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions') ?? '[]';
    final transactions = jsonDecode(transactionsJson) as List;
    transactions.removeWhere((t) => t['id'] == id);
    await prefs.setString('transactions', jsonEncode(transactions));
  }

  Future<void> _addCustomType(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (_typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                localizations?.fillAllFields ?? 'Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _customTypes.add(_typeController.text);
      _typeController.clear();
    });
    await _saveCustomTypes();
  }

  Future<void> _deleteCustomType(String type) async {
    setState(() {
      _customTypes.remove(type);
    });
    await _saveCustomTypes();
  }

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

  void _setupForegroundMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      localNotificationsPlugin.show(
        0,
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? 'You have a new update!',
        platformChannelSpecifics,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened app from notification: ${message.messageId}');
      // Navigate to TransactionScreen or NotificationsScreen if needed
    });
  }

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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations?.transactionTitle ?? 'Expenses/Income'),
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
              Tab(text: localizations?.budgetOverview ?? 'Budget Overview'),
              Tab(
                  text: localizations?.transactionHistory ??
                      'Transaction History'),
              Tab(text: localizations?.enterTransaction ?? 'Enter Transaction'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: Color(0xFFFF9800),
          ),
        ),
        body: TabBarView(
          children: [
            // Budget Overview Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildGradientButton(
                    text: localizations?.selectPeriod ?? 'Select Period',
                    icon: Icons.calendar_today,
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (range != null) {
                        setState(() {
                          _selectedRange = range;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('transactions')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text(localizations?.error ?? 'Error');
                      }
                      final transactions = snapshot.data?.docs ?? [];
                      double totalIncome = 0;
                      double totalExpense = 0;
                      final now = DateTime.now();
                      final start = _selectedRange?.start ??
                          DateTime(now.year, now.month - 1, now.day);
                      final end = _selectedRange?.end ?? now;

                      // Aggregate transactions by type for pie chart
                      final typeTotals = <String, double>{};
                      for (var doc in transactions) {
                        final data = doc.data() as Map<String, dynamic>;
                        final date = DateTime.parse(data['date']);
                        if (date.isAfter(start) && date.isBefore(end)) {
                          if (data['isExpense']) {
                            totalExpense += data['amount'];
                            final type = data['type'] ?? 'Unknown';
                            typeTotals[type] =
                                (typeTotals[type] ?? 0) + data['amount'];
                          } else {
                            totalIncome += data['amount'];
                            final type = data['type'] ?? 'Unknown';
                            typeTotals[type] =
                                (typeTotals[type] ?? 0) + data['amount'];
                          }
                        }
                      }
                      final balance = totalIncome - totalExpense;

                      // Prepare data for pie_chart
                      final categories = [
                        {
                          'name': 'Marketing',
                          'type': 'bank loan',
                          'color': Colors.orange
                        },
                        {
                          'name': 'HR',
                          'type': 'loan to friends',
                          'color': Colors.blue
                        },
                        {
                          'name': 'Administration',
                          'type': 'salary',
                          'color': Colors.yellow
                        },
                        {
                          'name': 'Finance',
                          'type': 'loan from friends',
                          'color': Colors.green
                        },
                        {
                          'name': 'Add Your Text Here',
                          'type': null,
                          'color': Colors.grey
                        },
                      ];

                      final dataMap = <String, double>{};
                      final colorList = <Color>[];
                      for (var category in categories) {
                        final type = category['type'] as String?;
                        final name = category['name'] as String;
                        final color = category['color'] as Color;
                        final amount =
                            type != null ? (typeTotals[type] ?? 0.0) : 0.0;
                        if (amount > 0) {
                          // pie_chart requires non-zero values
                          dataMap[name] = amount;
                          colorList.add(color);
                        }
                      }

                      return Column(
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    localizations?.budgetOverview ??
                                        'Budget Overview',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 16),
                                  dataMap.isNotEmpty
                                      ? SizedBox(
                                          height: 200,
                                          child: PieChart(
                                            dataMap: dataMap,
                                            colorList: colorList,
                                            chartRadius: 100,
                                            chartType: ChartType.ring,
                                            legendOptions: LegendOptions(),
                                            chartValuesOptions:
                                                ChartValuesOptions(
                                              showChartValues: true,
                                              showChartValuesInPercentage: true,
                                              decimalPlaces: 1,
                                            ),
                                          ),
                                        )
                                      : Text(localizations?.noData ??
                                          'No data available'),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: categories.map((category) {
                                      final type = category['type'] as String?;
                                      final amount = type != null
                                          ? (typeTotals[type] ?? 0.0)
                                          : 0.0;
                                      if (amount > 0) {
                                        return LegendItem(
                                          color: category['color'] as Color,
                                          text: category['name'] as String,
                                        );
                                      }
                                      return SizedBox.shrink();
                                    }).toList(),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '${localizations?.totalIncome ?? 'Total Income'}: \$${totalIncome.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.green),
                                  ),
                                  Text(
                                    '${localizations?.totalExpenses ?? 'Total Expenses'}: \$${totalExpense.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.red),
                                  ),
                                  Text(
                                    '${localizations?.balance ?? 'Balance'}: \$${balance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: balance >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Transaction History Tab
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('transactions')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(localizations?.error ?? 'Error'));
                }
                final transactions = snapshot.data?.docs ?? [];
                final now = DateTime.now();
                final start = _selectedRange?.start ??
                    DateTime(now.year, now.month - 1, now.day);
                final end = _selectedRange?.end ?? now;

                final filteredTransactions = transactions.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final date = DateTime.parse(data['date']);
                  return date.isAfter(start) && date.isBefore(end);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final doc = filteredTransactions[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final date = DateTime.parse(data['date']);
                    return ListTile(
                      title: Text(
                          '${data['type']} (\$${data['amount'].toStringAsFixed(2)})'),
                      subtitle: Text(
                        '${data['isExpense'] ? localizations?.expense ?? 'Expense' : localizations?.income ?? 'Income'} - ${DateFormat.yMMMd().format(date)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                _editingTransactionId = doc.id;
                                _amountController.text =
                                    data['amount'].toString();
                                _selectedType = data['type'];
                                _isExpense = data['isExpense'];
                                _phoneController.text =
                                    data['phoneNumber'] ?? '';
                                _detailsController.text = data['details'] ?? '';
                              });
                              DefaultTabController.of(context)?.animateTo(2);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await _deleteTransaction(doc.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // Enter Transaction Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: localizations?.amount ?? 'Amount',
                      prefixIcon: Icon(Icons.money, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText:
                          localizations?.transactionType ?? 'Transaction Type',
                      prefixIcon:
                          Icon(Icons.category, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: [
                      ..._defaultTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          )),
                      ..._customTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text(localizations?.expense ?? 'Expense'),
                        selected: _isExpense,
                        onSelected: (selected) {
                          setState(() {
                            _isExpense = true;
                          });
                        },
                        selectedColor: Colors.red[100],
                      ),
                      SizedBox(width: 16),
                      ChoiceChip(
                        label: Text(localizations?.income ?? 'Income'),
                        selected: !_isExpense,
                        onSelected: (selected) {
                          setState(() {
                            _isExpense = false;
                          });
                        },
                        selectedColor: Colors.green[100],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: localizations?.phone ?? 'Phone number (+998)',
                      prefixIcon: Icon(Icons.phone, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      labelText: localizations?.details ?? 'Details',
                      prefixIcon: Icon(Icons.note, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  _buildGradientButton(
                    text: localizations?.saveTransaction ?? 'Save Transaction',
                    icon: Icons.save,
                    onPressed: () => _saveTransaction(context),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  Text(
                    localizations?.manageTypes ?? 'Manage Transaction Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      labelText:
                          localizations?.newType ?? 'New Transaction Type',
                      prefixIcon: Icon(Icons.add, color: Color(0xFF2196F3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildGradientButton(
                    text: localizations?.addType ?? 'Add Type',
                    icon: Icons.add_circle,
                    onPressed: () => _addCustomType(context),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _customTypes.length,
                    itemBuilder: (context, index) {
                      final type = _customTypes[index];
                      return ListTile(
                        title: Text(type),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _deleteCustomType(type);
                          },
                        ),
                      );
                    },
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

// Widget for legend items
class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
