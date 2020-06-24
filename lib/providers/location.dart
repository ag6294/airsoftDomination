import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'dart:async';

import '../utils/location.dart';

class UserLocation with ChangeNotifier {
  LocationData _userLocation;

  Timer _refreshTimer;

  void refreshUserLocation() {
    LocationUtils.getCurrentUserLocation().then((value) {
      print('[LocationProvider] Got Location');
      _userLocation = value;
      notifyListeners();
    });
  }

  UserLocation() {
    print('[LocationProvider] Creating new Location Provider');
    LocationUtils.getCurrentUserLocation().then((value) {
      _userLocation = value;
    }).then((value) {
      // _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      //   _refreshTimer.cancel();
      //   _refreshTimer = timer;
      // refreshUserLocation();
      // }
      // );
    });
  }

  LocationData get userLocation {
    refreshUserLocation();
    return _userLocation != null ? _userLocation : null;
  }

  void timerDispose() {
    if (_refreshTimer.isActive) _refreshTimer.cancel();
  }
}
