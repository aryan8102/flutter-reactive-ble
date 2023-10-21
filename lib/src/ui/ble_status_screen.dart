import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleStatusScreen extends StatelessWidget {
   BleStatusScreen({required this.status, Key? key}) : super(key: key);

  final BleStatus status;
  final flutterReactiveBle = FlutterReactiveBle();

  String determineText(BleStatus status) {
    switch (status) {
      case BleStatus.unsupported:
        return "This device does not support Bluetooth";
      case BleStatus.unauthorized:
        return "Authorize the FlutterReactiveBle example app to use Bluetooth and location";
      case BleStatus.poweredOff:
        return "Bluetooth is powered off on your device turn it on";
      case BleStatus.locationServicesDisabled:
        return "Enable location services";
      case BleStatus.ready:
        return "Bluetooth is up and running";
      default:
        return "Waiting to fetch Bluetooth status $status";
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          child: Center(
            child: InkWell(
              onTap: (){
                flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
                  //code for handling results
                }, onError: () {
                  //code for handling error
                });
              },
              child: Text(determineText(status),
              ),
            ),


          ),

        ),

      );
}
