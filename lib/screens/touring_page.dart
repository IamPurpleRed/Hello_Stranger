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
import '/config/palette.dart';
import '/utils/local_storage_communication.dart';

class TouringPage extends StatefulWidget {
  TouringPage({Key? key, required this.accessibility, this.domain}) : super(key: key);

  final bool accessibility;
  final String? domain;
  final ble = FlutterReactiveBle();

  @override
  State<TouringPage> createState() => _TouringPageState();
}

class _TouringPageState extends State<TouringPage> {
  String hintText = '掃描中...';
  bool isWorking = false; // 若為 true，將不能點擊繼續掃描按鈕
  StreamSubscription<DiscoveredDevice>? scanStreamSub;
  String? uniqueId;
  String? type;
  String? title; // type A
  String? content; // type A
  String? href; // type A
  String? photoRef; // type A
  String? audioRef; // type A
  PlayerModel? playerModel;

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
    if (playerModel != null) playerModel!.dispose();
    super.dispose();
  }

  void startScanning() async {
    scanStreamSub = widget.ble.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) async {
      if (device.name.contains('HS-') && device.name.length == 15 && device.rssi >= -50) {
        await scanStreamSub!.cancel();
        setState(() {
          hintText = '偵測到裝置\n讀取資料中...';
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
            hintText = '雲端函式發生錯誤\n請離開導覽模式';
            isWorking = false;
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

      /* INFO: 檢查歷史足跡是否有相同 id 之資料，若有則需將較舊的刪除 */
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

      /* INFO: 顯示結果 */
      if (config['type'] == 'A') {
        setState(() {
          isWorking = false;
          title = config['title'];
          content = (config['content'] == '') ? null : config['content'];
          href = (config['href'] == '') ? null : config['href'];
          photoRef = (config['photoRef'] == '') ? null : config['photoRef'];
          audioRef = (config['audioRef'] == '') ? null : config['audioRef'];
          playerModel = (config['audioRef'] == '') ? null : PlayerModel();
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
        hintText = '發生錯誤\n可能是網路連線不穩定\n請重新掃描';
        isWorking = false;
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
        body: SafeArea(
          child: (type == null) ? noResultArea(vw, vh) : resultArea(vw, vh),
        ),
        floatingActionButton: (widget.accessibility || href == null)
            ? null
            : Padding(
                padding: EdgeInsets.only(top: vh * 0.35),
                child: FloatingActionButton(
                  child: const Icon(Icons.launch, color: Colors.white),
                  onPressed: () => launchUrl(Uri.parse(href!), mode: LaunchMode.externalApplication),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }

  Widget noResultArea(double vw, double vh) {
    return widget.accessibility
        ? Column(
            children: [
              Expanded(child: FittedBox(child: Text(hintText))),
              accessibilityButtons(vh),
            ],
          )
        : Column(
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
        accessibility: widget.accessibility,
        playerModel: playerModel!,
        uniqueId: uniqueId!,
        title: title!,
        content: content,
        photoRef: photoRef,
        audioRef: audioRef,
      );
    } else if (type == 'B') {
      colChildren = typeB(
        vw: vw,
        vh: vh,
        accessibility: widget.accessibility,
        title: '苓雅一路/\n文橫二路路口',
      );
    }

    if (widget.accessibility) {
      colChildren.add(accessibilityButtons(vh));
    } else {
      colChildren.add(const SizedBox(height: 15.0));
      colChildren.add(buttons(vw));
      colChildren.add(const SizedBox(height: 15.0));
    }

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
              onPressed: isWorking
                  ? null
                  : () {
                      setState(() {
                        hintText = '掃描中...';
                        isWorking = true;
                        uniqueId = null;
                        type = null;
                        title = null;
                        content = null;
                        href = null;
                        photoRef = null;
                        audioRef = null;
                        playerModel = null;
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

  Ink accessibilityButtons(double vh) {
    return Ink(
      height: vh * 0.5,
      color: Palette.secondaryColor,
      child: GestureDetector(
        onDoubleTap: isWorking
            ? null
            : () {
                setState(() {
                  hintText = '掃描中...';
                  isWorking = true;
                  uniqueId = null;
                  type = null;
                  title = null;
                  content = null;
                  href = null;
                  photoRef = null;
                  audioRef = null;
                  playerModel = null;
                });
                startScanning();
              },
        onLongPress: () => Navigator.pop(context),
        child: const FittedBox(
          child: Text(
            '繼續掃描\n/\n停止導覽',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
