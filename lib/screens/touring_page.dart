import 'dart:async';
import 'dart:convert';

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
  String hintText = '請接近任一裝置...';
  StreamSubscription<DiscoveredDevice>? scanStreamSub;
  DiscoveredDevice? targetDevice;
  Stream<ConnectionStateUpdate>? connectionStream;
  StreamSubscription<ConnectionStateUpdate>? connectionStreamSub;
  StreamSubscription<List<int>>? receiveStreamSub;
  List<int>? receiveData;
  String? url;

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  @override
  void dispose() {
    scanStreamSub = null;
    connectionStream = null;
    connectionStreamSub = null;
    receiveStreamSub = null;
    super.dispose();
  }

  void startScanning() {
    print('開始掃描工作');
    scanStreamSub = widget.ble.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) async {
      print(device.toString());
      if (device.name == 'Hello Stranger device A' && device.rssi >= -50) {
        print('偵測到裝置，將取消掃描工作');
        await scanStreamSub!.cancel();
        print('已取消掃描工作');
        setState(() {
          scanStreamSub = null;
          targetDevice = device;
          connectionStream = widget.ble.connectToAdvertisingDevice(
            id: targetDevice!.id,
            prescanDuration: const Duration(seconds: 1),
            withServices: [],
          );
          hintText = '偵測到裝置，連線中...';
        });
        startConnecting();
      }
    });
  }

  void startConnecting() {
    bool flag = false; // true => 連線成功
    print('開始連線工作');
    Future.delayed(const Duration(seconds: 3), () async {
      if (!flag) {
        print('連線工作逾時，將取消連線工作');
        await connectionStreamSub!.cancel();
        print('已取消連線工作');
        setState(() {
          connectionStream = null;
          connectionStreamSub = null;
          hintText = '請接近任一裝置...';
        });
        startScanning();
      }
    });

    connectionStreamSub = connectionStream!.listen((event) async {
      if (event.connectionState == DeviceConnectionState.connected) {
        print('連線成功');
        flag = true;
        setState(() => hintText = '正在取得資料，請待在原地...');
        QualifiedCharacteristic txCharacteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse('6E400001-B5A3-F393-E0A9-E50E24DCCA9E'),
          characteristicId: Uuid.parse('6E400003-B5A3-F393-E0A9-E50E24DCCA9E'),
          deviceId: event.deviceId,
        );
        startReceiving(txCharacteristic);
      }
    });
  }

  void startReceiving(QualifiedCharacteristic txCharacteristic) {
    bool flag = false; // true => 有收到資料
    print('開始監聽裝置tx');
    Future.delayed(const Duration(seconds: 3), () async {
      if (!flag) {
        print('裝置tx無回應，將取消監聽裝置tx');
        await receiveStreamSub!.cancel();
        print('已取消監聽裝置tx');
        print('裝置tx無回應，將取消連線工作');
        await connectionStreamSub!.cancel();
        print('已取消連線工作');
        setState(() {
          receiveStreamSub = null;
          connectionStream = null;
          connectionStreamSub = null;
          hintText = '請接近任一裝置...';
        });
        startScanning();
      }
    });

    receiveStreamSub = widget.ble.subscribeToCharacteristic(txCharacteristic).listen((asciiArr) async {
      print('拿到資料了！將取消監聽裝置tx');
      flag = true;
      await receiveStreamSub!.cancel();
      print('已取消監聽裝置tx');
      print('拿到資料了！將取消連線工作');
      await connectionStreamSub!.cancel();
      print('已取消連線工作');
      setState(() {
        receiveStreamSub = null;
        connectionStream = null;
        connectionStreamSub = null;
        url = const AsciiDecoder().convert(asciiArr);
        hintText = '請接近任一裝置...';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double vh = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Center(
          child: (url != null) ? resultArea(vh, vw) : noResultArea(vw),
        ),
      ),
    );
  }

  Widget noResultArea(double vw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: vw * 0.1),
      child: Column(
        children: [
          const Expanded(child: SizedBox()),
          Text(
            hintText,
            style: const TextStyle(fontSize: Constants.defaultTextSize),
          ),
          const Expanded(child: SizedBox()),
          SizedBox(
            width: vw * 0.8,
            child: ElevatedButton(
              child: const Text(
                '離開導覽模式',
                style: TextStyle(fontSize: Constants.defaultTextSize),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget resultArea(double vh, double vw) {
    return Column(
      children: [
        SizedBox(
          width: vw,
          height: vh * 0.4,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Image.network('https://www.freecodecamp.org/news/content/images/size/w2000/2021/08/aTag.png'),
          ),
        ),
        Text(url!, style: const TextStyle(fontSize: Constants.headline1Size)),
        const Expanded(child: SizedBox()),
        SizedBox(
          width: vw * 0.8,
          child: ElevatedButton(
            child: const Text(
              '繼續尋找裝置',
              style: TextStyle(fontSize: Constants.defaultTextSize),
            ),
            onPressed: () {
              setState(() => url = null);
              startScanning();
            },
          ),
        ),
        const SizedBox(height: 10.0),
        SizedBox(
          width: vw * 0.8,
          child: ElevatedButton(
            child: const Text(
              '離開導覽模式',
              style: TextStyle(fontSize: Constants.defaultTextSize),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
