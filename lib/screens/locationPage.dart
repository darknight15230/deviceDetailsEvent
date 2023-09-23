// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'dart:developer';
import 'dart:io';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import 'package:workmanager/workmanager.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition;
  GoogleMapController? _mapController; //contrller for Google map
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygon = {};
  final List<LatLng> _points = [];

  int? _batteryLevel;
  String? _identifier;
  String? _typeConnection;

  @override
  void initState() {
    _getCurrentPosition();
    _deviceDetails();
    Workmanager().registerPeriodicTask(
          "taskTwo",
          "backUp",
          frequency: const Duration(minutes: 15),
        );
    super.initState();
  }

  _checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      _typeConnection = "Datos Moviles";
    } else if (connectivityResult == ConnectivityResult.wifi) {
      _typeConnection = "Wi-Fi";
    }
  }

  Future<void> _deviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    _checkConnection();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        setState(() {
          _identifier = build.androidId;
          _batteryLevel = AndroidBatteryInfo().batteryLevel;
        });
        log('Android $_identifier');
        log("Android baterry level $_batteryLevel");
        log(_typeConnection!);
        //Secure storage

        // await secureStorage.write(key: 'identifier', value: identifier);
        // String identificador = await secureStorage.read(key: 'identifier');
        //UUID for Android

      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        setState(() {
          _identifier = data.identifierForVendor;
        }); //UUID for iOS
        log('iOS ${data.name}');
        log('iOS ${data.systemVersion}');
        log('iOS ${data.identifierForVendor}');
        //Secure storage
        //await secureStorage.write(key: 'identifier', value: identifier);
      }
    } on PlatformException {
      debugPrint('Failed to get platform version');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _setMarker(Position position) async {
    _markers.add(Marker(
      //add marker on google map
      markerId: MarkerId(position.toString()),
      position:
          LatLng(position.latitude, position.longitude), //position of marker
      infoWindow: const InfoWindow(
        //popup info
        title: 'My Custom Title ',
        snippet: 'My Custom Subtitle',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 17),
        //17 is new zoom level
      ),
    );
  }

  Future<void> _drawPolygon(Position position) async {
    _points.add(LatLng(position.latitude, position.longitude));
    _polygon.add(Polygon(
      // given polygonId
      polygonId: const PolygonId('1'),
      // initialize the list of points to display polygon
      points: _points,
      // given color to polygon
      fillColor: Colors.transparent,
      // given border color to polygon
      strokeColor: Colors.blueAccent,
      strokeWidth: 4,
    ));
  }

  _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      //_getAddressFromLatLng(position);
      _setMarker(position);
      _drawPolygon(position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final cron = Cron();

    // cron.schedule(Schedule.parse('0 * * * * *'), () async {
    //   _getCurrentPosition();
    // });

    Timer.periodic(const Duration(seconds: 20), (timer) {
      //Este codigo se ejecuta cada 20 segundos
      _getCurrentPosition();
      print("hola ${DateTime.now()}");
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Example"),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : _drawMap(_currentPosition!),
    );
  }

  GoogleMap _drawMap(Position position) {
    //* Ejemplo de como sacar la latitud y longitud de el marcador que se creo */
    // for (int i = 0; i < markers.length; i++) {
    //   print(markers.toList()[i].position.latitude);
    //   print(markers.toList()[i].position.longitude);
    // }

    return GoogleMap(
      //Map widget from google_maps_flutter package
      zoomGesturesEnabled: true,
      zoomControlsEnabled: true, //enable Zoom in, out on map
      initialCameraPosition: CameraPosition(
        //innital position in map
        target:
            LatLng(position.latitude, position.longitude), //initial position
        zoom: 17.0, //initial zoom level
      ),
      markers: _markers, //markers to show on map
      mapType: MapType.normal,
      polygons: _polygon, //map type
      onMapCreated: (controller) {
        //method called when map is created
        setState(() {
          _mapController = controller;
        });
      },
    );
  }
}
