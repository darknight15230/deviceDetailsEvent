import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_example/helpers/get_device_info.dart';
import 'package:location_example/models/system_details.dart';
import 'package:workmanager/workmanager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // Workmanager().registerPeriodicTask(
    //   "taskTwo",
    //   "backUp",
    //   frequency: const Duration(minutes: 15),
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('HomeScreen'),
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.abc),onPressed: () {
        Workmanager().registerPeriodicTask(
          "taskTwo",
          "backUp",
          frequency: const Duration(minutes: 15),
        );
      }),
    );
  }
}
