import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

import '/components/device_type.dart';
import '/components/player/player_model.dart';
import '/config/constants.dart';
import '/utils/local_storage_communication.dart';

class TouringPage extends StatefulWidget {
  TouringPage({Key? key, this.domain}) : super(key: key);

  final String? domain;
  final ble = FlutterReactiveBle();
  final playerModel = PlayerModel();

  @override
  State<TouringPage> createState() => _TouringPageState();
}

class _TouringPageState extends State<TouringPage> {
  String hintText = '掃描中...';
  StreamSubscription<DiscoveredDevice>? scanStreamSub;
  String? uniqueId;
  DateTime? dt;
  String? type;
  String? title; // type A
  String? content; // type A
  String? href; // type A
  String? photoRef; // type A
  String? audioRef; // type A

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
    widget.playerModel.dispose();
    super.dispose();
  }

  void startScanning() async {
    scanStreamSub = widget.ble.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) async {
      if (device.name.contains('HS-') && device.name.length == 15 && device.rssi >= -50) {
        await scanStreamSub!.cancel();
        setState(() {
          hintText = '偵測到裝置，讀取資料中...';
          scanStreamSub = null;
          uniqueId = device.name.substring(3);
        });
        await getDeviceConfig();
      }
    });
  }

  Future<void> getDeviceConfig() async {
    try {
      /* INFO: 取得資料 */
      late Map config;
      if (widget.domain == null) {
        final configRes = await FirebaseFunctions.instanceFor(region: 'asia-east1').httpsCallable('getDeviceConfig').call({
          'deviceId': uniqueId,
        });
        if (configRes.data['code'] == 1) {
          setState(() {
            hintText = '雲端函式發生錯誤，請離開導覽模式';
            uniqueId = null;
          });
          return;
        } else if (configRes.data['code'] == 2) {
          startScanning();
          setState(() {
            hintText = '掃描中...';
            uniqueId = null;
          });
          return;
        }
        config = configRes.data['config'];
      } else {
        final configRes = await Dio().get('${widget.domain}/devices%2F$uniqueId%2Fconfig.json?alt=media');
        config = configRes.data;
      }

      /* INFO: 檢查歷史足跡是否有相同 id 之資料，若有則需刪除 */
      List historyList = await getHistoryList();
      for (var item in historyList) {
        if (item['uniqueId'] == uniqueId) {
          historyList.remove(item);
          await deleteDirectory('history/${item['deviceId']}');
          break;
        }
      }

      /* INFO: 加入新的內容到 historyList */
      config['datetime'] = DateTime.now().toString();
      historyList.add(config);
      updateHistoryFile(historyList);

      if (config['type'] == 'A') {
        setState(() {
          dt = DateTime.parse(config['datetime']);
          title = config['title'];
          content = config['content'];
          href = (config['href'] == '') ? null : config['href'];
          photoRef = (config['photoRef'] == '') ? null : config['photoRef'];
          audioRef = (config['audioRef'] == '') ? null : config['audioRef'];
          type = 'A';
        });
      } else {
        setState(() {
          hintText = '掃描中...';
          uniqueId = null;
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
        body: (type == null) ? noResultArea(vw) : resultArea(vw, vh),
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

  Widget noResultArea(double vw) {
    return Column(
      children: [
        const Expanded(child: SizedBox()),
        Text(
          hintText,
          style: const TextStyle(fontSize: Constants.defaultTextSize),
        ),
        const Expanded(child: SizedBox()),
        buttons(vw),
        const SizedBox(height: 15.0),
      ],
    );
  }

  Widget resultArea(vw, vh) {
    List<Widget> colChildren = [];
    if (type == 'A') {
      colChildren = typeA(
        vw: vw,
        vh: vh,
        playerModel: widget.playerModel,
        uniqueId: uniqueId!,
        title: title!,
        content: content,
        photoRef: photoRef,
        audioRef: audioRef,
      );
    }
    colChildren.add(const SizedBox(height: 15.0));
    colChildren.add(buttons(vw));
    colChildren.add(const SizedBox(height: 15.0));

    return Column(children: colChildren);
  }

  Padding buttons(double vw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: vw * 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: vw * 0.38,
            child: ElevatedButton(
              onPressed: (uniqueId == null)
                  ? null
                  : () {
                      setState(() {
                        hintText = '掃描中...';
                        uniqueId = null;
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
            width: vw * 0.38,
            child: ElevatedButton(
              child: const Text(
                '停止導覽',
                style: TextStyle(fontSize: Constants.defaultTextSize),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
