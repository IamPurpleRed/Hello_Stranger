import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hello_stranger/utils/local_storage_communication.dart';

import '/config/constants.dart';

class TouringPage extends StatefulWidget {
  TouringPage({Key? key, this.domain}) : super(key: key);

  final String? domain;
  final ble = FlutterReactiveBle();

  @override
  State<TouringPage> createState() => _TouringPageState();
}

class _TouringPageState extends State<TouringPage> {
  String hintText = '掃描中...';
  StreamSubscription<DiscoveredDevice>? scanStreamSub;
  String? deviceId;
  DateTime? dt;
  String? type;
  String? title;
  String? content;
  String? photoRef;

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  @override
  void dispose() {
    scanStreamSub = null;
    super.dispose();
  }

  void startScanning() {
    scanStreamSub = widget.ble.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) async {
      if (device.name.contains('HS-') && device.name.length == 15 && device.rssi >= -50) {
        await scanStreamSub!.cancel();
        setState(() {
          hintText = '偵測到裝置，讀取資料中...';
          scanStreamSub = null;
          deviceId = device.name.substring(3);
        });
        await getDeviceConfig();
      }
    });
  }

  Future getDeviceConfig() async {
    try {
      final configRes = await FirebaseFunctions.instanceFor(region: 'asia-east1').httpsCallable('getDeviceConfig').call({
        'deviceId': deviceId,
      });
      if (configRes.data['code'] == 1) {
        setState(() {
          hintText = '雲端函式發生錯誤，請離開導覽模式';
          deviceId = null;
        });
        return;
      } else if (configRes.data['code'] == 2) {
        startScanning();
        setState(() {
          hintText = '掃描中...';
          deviceId = null;
        });
        return;
      }

      if (configRes.data['config']['type'] == 'A') {
        setState(() {
          type = 'A';
          dt = DateTime.now();
          title = configRes.data['config']['title'];
          content = configRes.data['config']['content'];
          photoRef = (configRes.data['config']['photoRef'] == '') ? null : configRes.data['config']['photoRef'];
        });
      } else {
        startScanning();
        setState(() {
          hintText = '掃描中...';
          deviceId = null;
        });
      }
    } catch (e) {
      setState(() {
        hintText = '網路連線不穩定，請離開導覽模式';
        deviceId = null;
      });
    }
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
        body: (type == null) ? noResultArea(vw) : typeA(vw, vh),
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
          buttons(vw),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget typeA(double vw, double vh) {
    return Column(
      children: [
        SizedBox(
          width: vw,
          height: vh * 0.4,
          child: FittedBox(
            fit: BoxFit.fill,
            child: (photoRef != null)
                ? FutureBuilder(
                    initialData: Image.asset('assets/loading_image.gif'),
                    future: saveDeviceImage(dt!, photoRef!),
                    builder: (context, snapshot) => snapshot.data as Widget,
                  )
                : Image.asset('assets/no_image.png'),
          ),
        ),
        const SizedBox(height: 10.0),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: vw * 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: const TextStyle(fontSize: Constants.headline1Size, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      content!,
                      style: const TextStyle(fontSize: Constants.contentSize, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                buttons(vw),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row buttons(double vw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: vw * 0.35,
          child: ElevatedButton(
            onPressed: (deviceId == null)
                ? null
                : () {
                    setState(() {
                      hintText = '掃描中...';
                      deviceId = null;
                      dt = null;
                      type = null;
                      title = null;
                      content = null;
                      photoRef = null;
                    });
                    startScanning();
                  },
            child: const Text(
              '繼續掃描',
              style: TextStyle(fontSize: Constants.defaultTextSize),
            ),
          ),
        ),
        SizedBox(
          width: vw * 0.35,
          child: ElevatedButton(
            child: const Text(
              '停止導覽',
              style: TextStyle(fontSize: Constants.defaultTextSize),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
