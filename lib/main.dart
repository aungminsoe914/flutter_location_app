import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Checker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Location Check-In/Out'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _locationStatus = 'No location data';
  Position? _currentPosition;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = 'Location services are disabled.';
      });
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationStatus = 'Location permissions are denied';
        });
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationStatus = 'Location permissions are permanently denied, we cannot request permissions.';
      });
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationStatus = 'Lat: ${position.latitude}, Long: ${position.longitude}';
        print("$_locationStatus-------------------------------------------");
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Could not get location: $e';
      });
    }
  }

  void _checkIn() async {
    await _getCurrentLocation();
    if (_currentPosition != null) {
      setState(() {
        _checkInTime = DateTime.now();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked in successfully')),
      );
    }
  }

  void _checkOut() async {
    await _getCurrentLocation();
    if (_currentPosition != null) {
      setState(() {
        _checkOutTime = DateTime.now();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked out successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _checkIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Check In', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Check Out', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 40),
            Text(
              _locationStatus,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (_checkInTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text('Checked in: ${_checkInTime!.toLocal()}'),
              ),
            if (_checkOutTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Checked out: ${_checkOutTime!.toLocal()}'),
              ),
          ],
        ),
      ),
    );
  }
}