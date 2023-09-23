import 'package:flutter/material.dart';

import 'dart:developer';
import 'dart:io';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class GetDeviceInfo {
  Position? currentPosition;
  int? batteryLevel;
  String? identifier;
  String? typeConnection;

  Future<String?> checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return typeConnection = "Datos Moviles";
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return typeConnection = "Wi-Fi";
    } else if (connectivityResult == ConnectivityResult.none) {
      return typeConnection = "No Connection";
    }
    return null;
  }

  int? getBatteryLvl() {
    batteryLevel = AndroidBatteryInfo().batteryLevel;

    return batteryLevel;
  }

  Future<String?> getUUID() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;

        return identifier = build.androidId;
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        return identifier = data.identifierForVendor;
        //UUID for iOS
      }
    } on PlatformException {
      debugPrint('Failed to get platform version');
      return null;
    }

    return null;
  }

  Future<bool> handleLocationPermission() async {
    bool? serviceEnabled;
    LocationPermission permission;
    print("antes de preguntar por el servicio de ubicacion");
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("service is enabled: $serviceEnabled");
      if (!serviceEnabled) {
        return false;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
      return true;
    } on Exception catch (e) {
      // Anything else that is an exception
      print('Unknown exception: $e');
    } catch (e) {
      // No specified type, handles all
      print('Something really unknown: $e');
    }

    return false;
  }

  Future<Position?> getCurrentPosition() async {
    print("dentro de la funcion que obtiene la posicion");
    final hasPermission = await handleLocationPermission();
    print("despues de preguntar por el permiso");
    if (!hasPermission) return null;
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return currentPosition;
    } on Exception catch (e) {
      // Anything else that is an exception
      print('Unknown exception: $e');
    } catch (e) {
      // No specified type, handles all
      print('Something really unknown: $e');
    }

    return null;
  }
}
