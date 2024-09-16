import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;

  Future<void> updateLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check if the app has permission to access location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Get the current latitude and longitude
      Position position = await Geolocator.getCurrentPosition();
      log('Current Position: ${position.toString()}');

      _latitude = position.latitude;
      _longitude = position.longitude;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', _latitude!);
      await prefs.setDouble('longitude', _longitude!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Error updating location: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _latitude = prefs.getDouble('latitude');
    _longitude = prefs.getDouble('longitude');
    notifyListeners();
  }
}
