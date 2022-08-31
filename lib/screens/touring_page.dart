import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hello_stranger/config/constants.dart';

class TouringPage extends StatefulWidget {
  TouringPage({Key? key}) : super(key: key);

  final ble = FlutterReactiveBle();

  @override
  State<TouringPage> createState() => _TouringPageState();
}

class _TouringPageState extends State<TouringPage> {
  late StreamSubscription<DiscoveredDevice> scanStream;
  DiscoveredDevice? found;
  Stream<ConnectionStateUpdate>? connectionStream;
  String string = '請接近裝置以開始導覽...';

  @override
  void initState() {
    super.initState();
    scanStream = widget.ble.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      print(device.toString());
      if (device.name == 'HS_test1') {
        scanStream.cancel();
        setState(() {
          found = device;
          connectionStream = widget.ble.connectToAdvertisingDevice(
            id: found!.id,
            prescanDuration: const Duration(seconds: 1),
            withServices: [],
          );
          string = '偵測到裝置，連線中...';
        });
        connect();
      }
    });
  }

  void connect() async {
    connectionStream!.listen((event) async {
      if (event.connectionState == DeviceConnectionState.connected) {
        setState(() {
          string = '連線成功，正在抓取資料...';
        });
        QualifiedCharacteristic txCharacteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse('6E400001-B5A3-F393-E0A9-E50E24DCCA9E'),
          characteristicId: Uuid.parse('6E400003-B5A3-F393-E0A9-E50E24DCCA9E'),
          deviceId: event.deviceId,
        );
        widget.ble.subscribeToCharacteristic(txCharacteristic).listen((data) {
          print(data.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network('https://www.freecodecamp.org/news/content/images/size/w2000/2021/08/aTag.png', width: vw),
              Text(
                string,
                style: const TextStyle(fontSize: Constants.defaultTextSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
