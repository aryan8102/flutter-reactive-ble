import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qwer/src/ble/ble_device_connector.dart';
import 'package:qwer/src/ble/ble_device_interactor.dart';
import 'package:qwer/src/ble/ble_scanner.dart';
import 'package:qwer/src/ble/ble_status_monitor.dart';
import 'package:provider/provider.dart';
import 'package:qwer/src/ui/ble_status_screen.dart';
import 'package:qwer/src/ui/device_list.dart';

import 'src/ble/ble_logger.dart';

const _themeColor = Colors.lightGreen;
Future<void> getLocation() async {
  LocationPermission permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied) {
    // Handle denied permission
  } else if (permission == LocationPermission.whileInUse) {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print(position);
  }
}
// void discoverBluetoothDevices() async {
//   // Initialize the Bluetooth instance
//   final ble = FlutterReactiveBle();
//   final peripheralScanner = ble.p;
//
//   // Scan for devices
//   final scanResult = peripheralScanner.scan(
//     withServices: [], // Provide a list of service UUIDs to filter devices by services
//   );
//
//   // Listen to scan results
//   final subscription = scanResult.listen((scanData) {
//     final device = scanData.peripheral.device;
//     print('Discovered device: ${device.name}, ${device.id}');
//
//     // Do something with the discovered device, e.g., add it to a list
//     // or display it in your app's user interface.
//   });
//
//   // After a specific duration, stop scanning
//   await Future.delayed(Duration(seconds: 10));
//   await subscription.cancel();
// }
Future<void> getNEARBYDEVICE() async {
var permission = await Permission.bluetoothScan.request();

  if (permission == LocationPermission.denied) {
    // Handle denied permission
  } else if (permission == LocationPermission.whileInUse) {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print(position);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final _ble = FlutterReactiveBle();
  final _bleLogger = BleLogger(ble: _ble);
  final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  final _monitor = BleStatusMonitor(_ble);
  final _connector = BleDeviceConnector(
    ble: _ble,
    logMessage: _bleLogger.addToLog,
  );
  final _serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: (deviceId) async {
      await _ble.discoverAllServices(deviceId);
      return _ble.getDiscoveredServices(deviceId);
    },
    logMessage: _bleLogger.addToLog,
  );
  getLocation();
  getNEARBYDEVICE();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _scanner),
        Provider.value(value: _monitor),
        Provider.value(value: _connector),
        Provider.value(value: _serviceDiscoverer),
        Provider.value(value: _bleLogger),
        StreamProvider<BleScannerState?>(
          create: (_) => _scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => _monitor.state,
          initialData: BleStatus.unknown,
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => _connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Reactive BLE example',
        color: _themeColor,
        theme: ThemeData(primarySwatch: _themeColor),
        home: const HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(
        builder: (_, status, __) {
          if (status == BleStatus.ready) {
            return const DeviceListScreen();
          } else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}
