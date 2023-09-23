import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_example/helpers/get_device_info.dart';
import 'package:location_example/models/system_details.dart';
import 'package:location_example/screens/home_page.dart';
import 'package:workmanager/workmanager.dart';
import 'screens/locationPage.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    //* Your background task logic goes here
    print("inicio de la tarea ${DateTime.now()}");
    GetDeviceInfo getDeviceInfo = GetDeviceInfo();
    print("despues de declarar la clase para obtener los detalles");
    Position? position = await getDeviceInfo.getCurrentPosition();
    print("despues de obtener la posicion");
    double lat = position?.latitude ?? 214.00;
    print("despues de obtener la latitud $lat");
    double long = position?.longitude ?? -35.09;
    print("despues de obtener la longtidu: $long");
    String? uUID = await getDeviceInfo.getUUID() ?? "";
    print("despues de obtener el UUID $uUID");
    String? typeConnection =
        await getDeviceInfo.checkConnection() ?? "No connection";
    print("despues de obtener el tipo de conexion $typeConnection");
    int? batteryLvl = getDeviceInfo.getBatteryLvl() ?? 0;
    print("despues de obtener el nivel de bateria $batteryLvl");

    SystemDetails sysDetails = SystemDetails(
        nivelBateria: batteryLvl,
        tipoSenal: typeConnection,
        uuid: uUID,
        latitud: lat,
        longitud: long);
    print("class: $sysDetails");

    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Location Demo',
      debugShowCheckedModeBanner: false,
      home: LocationScreen(),
    );
  }
}
