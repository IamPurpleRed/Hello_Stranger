import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

import '/config/constants.dart';
import '/utils/local_storage_communication.dart';

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
  String? title; // type A
  String? content; // type A
  String? href; // type A
  String? photoRef; // type A

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    startScanning();
  }

  @override
  void dispose() {
    Wakelock.disable();
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

  Future<void> getDeviceConfig() async {
    try {
      late Map config;

      if (widget.domain == null) {
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
        config = configRes.data['config'];
      } else {
        final configRes = await Dio().get('${widget.domain}/devices%2F$deviceId%2Fconfig.json?alt=media');
        config = configRes.data;
      }

      config['datetime'] = DateTime.now();
      if (config['type'] == 'A') {
        setState(() {
          type = 'A';
          dt = config['datetime'];
          title = config['title'];
          content = config['content'];
          href = (config['href'] == '') ? null : config['href'];
          photoRef = (config['photoRef'] == '') ? null : config['photoRef'];
        });
        await addItemToHistoryFile({
          'datetime': config['datetime'].toString(),
          'title': config['title'],
          'content': config['content'],
          'href': config['href'],
        });
      } else {
        setState(() {
          hintText = '掃描中...';
          deviceId = null;
        });
        startScanning();
      }
    } catch (e) {
      setState(() {
        hintText = '網路連線不穩定，請重新掃描';
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
        floatingActionButton: (href == null)
            ? null
            : Padding(
                padding: EdgeInsets.only(top: vh * 0.3),
                child: FloatingActionButton(
                  child: const Icon(Icons.launch, color: Colors.white),
                  onPressed: () => launchUrl(Uri.parse(href!), mode: LaunchMode.externalApplication),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
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
                      href = null;
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

  Widget typeA(vw, vh) {
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
        const SizedBox(height: 20.0),
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
}
