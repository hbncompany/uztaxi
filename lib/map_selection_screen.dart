import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'localizations.dart'; // Ensure this path is correct

class MapSelectionScreen extends StatefulWidget {
  final Map<String, dynamic>? initialLocation;
  final Function(Locale) onLocaleChange; // Propagate locale change function

  const MapSelectionScreen({
    Key? key,
    this.initialLocation,
    required this.onLocaleChange,
  }) : super(key: key);

  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lonController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialLocation?['address'] ?? '');
    _latController = TextEditingController(text: (widget.initialLocation?['latitude'] ?? '').toString());
    _lonController = TextEditingController(text: (widget.initialLocation?['longitude'] ?? '').toString());
  }

  @override
  void dispose() {
    _addressController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _openGoogleMapsExternal() async {
    // Attempt to open Google Maps with current coordinates if available, otherwise a general location
    String urlString;
    if (_latController.text.isNotEmpty && _lonController.text.isNotEmpty) {
      urlString = 'https://www.google.com/maps/search/?api=1&query=${_latController.text},${_lonController.text}';
    } else {
      urlString = 'https://www.google.com/maps/@41.2995,69.2401,15z'; // Default to Tashkent, Uzbekistan
    }

    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication); // Opens in external map app if available
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.cannotLaunchMap ?? 'Could not launch map.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.selectTakeOverLocation ?? 'Select Take Over Location'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations?.mapSelectionInstructionsTitle ?? 'How to Select Location:',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      localizations?.mapSelectionInstructionsDetail ??
                          '1. Tap "Open Google Maps" below.\n'
                              '2. In Google Maps, find your desired location.\n'
                              '3. Tap and hold on the map to drop a pin. This will show coordinates (latitude, longitude) and an address.\n'
                              '4. Copy these values and paste them into the fields below.\n'
                              '5. Tap "Select Location" to confirm.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _openGoogleMapsExternal,
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: Text(localizations?.openGoogleMaps ?? 'Open Google Maps to Pick',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      localizations?.manualInput ?? 'Or enter coordinates manually:',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: localizations?.locationAddress ?? 'Location Address (e.g., Street, City)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _latController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: localizations?.latitude ?? 'Latitude',
                        hintText: 'e.g., 41.2995',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _lonController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: localizations?.longitude ?? 'Longitude',
                        hintText: 'e.g., 69.2401',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _addressController.clear();
                              _latController.clear();
                              _lonController.clear();
                              Navigator.pop(context, null); // Return null on clear
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(localizations?.clear ?? 'Clear'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              double? lat = double.tryParse(_latController.text);
                              double? lon = double.tryParse(_lonController.text);
                              String address = _addressController.text.trim();

                              if (address.isEmpty || lat == null || lon == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(localizations?.enterValidLocationData ?? 'Please enter a valid address, latitude, and longitude.')),
                                );
                                return;
                              }
                              Navigator.pop(context, {
                                'address': address,
                                'latitude': lat,
                                'longitude': lon,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF26A69A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 5,
                            ),
                            child: Text(localizations?.select ?? 'Select Location'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
