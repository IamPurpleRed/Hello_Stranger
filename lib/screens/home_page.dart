import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hello_stranger/config/userdata.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '/components/widgets.dart';
import '/config/constants.dart';
import '/config/palette.dart';
import '/screens/touring_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QRViewController? qrController;
  String? url;

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // 點擊螢幕任一處以轉移焦點
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: vw * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '開始導覽',
                  style: TextStyle(
                    fontSize: Constants.headline1Size,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                AutoSizeText(
                  '戴上耳機，保持藍芽跟網路開啟，就是這麼簡單！',
                  maxLines: 2,
                  style: TextStyle(fontSize: Constants.headline3Size),
                ),
                SizedBox(height: 10.0),
                AutoSizeText(
                  '※ 進入導覽模式後，將會關閉螢幕休眠',
                  maxLines: 1,
                  style: TextStyle(
                    color: Palette.secondaryColor,
                    fontSize: Constants.defaultTextSize,
                  ),
                ),
                AutoSizeText(
                  '※ 不會儲存在指定導覽模式收到的資料',
                  maxLines: 1,
                  style: TextStyle(
                    color: Palette.secondaryColor,
                    fontSize: Constants.defaultTextSize,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '我想進行非公開或特定的主題導覽：',
                  style: TextStyle(fontSize: Constants.defaultTextSize),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    if (!await permission()) {
                      Widgets.alertDialog(
                        context,
                        title: '無法進入導覽模式',
                        content: '請確認藍芽是否有開啟，並前往設定查看是否允許 Hello Stranger 相關權限',
                      );
                      return;
                    } else {
                      showScanner(vw);
                    }
                  },
                  child: SizedBox(
                    width: vw * 0.8,
                    child: const Text(
                      '指定導覽',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: Constants.defaultTextSize),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '我想隨便亂走，探索這個世界：',
                  style: TextStyle(fontSize: Constants.defaultTextSize),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: vw * 0.8,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!await permission()) {
                        Widgets.alertDialog(
                          context,
                          title: '無法進入導覽模式',
                          content: '請確認藍芽是否有開啟，並前往設定查看是否允許 Hello Stranger 相關權限',
                        );
                        return;
                      } else {
                        Navigator.pushNamed(context, '/main/touring');
                      }
                    },
                    child: const Text(
                      '一般導覽',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: Constants.defaultTextSize),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> permission() async {
    if (!await FlutterBluePlus.instance.isOn) return false;

    if (Platform.isAndroid) {
      List<bool> status = [
        await Permission.bluetoothScan.status.isGranted,
        await Permission.bluetoothConnect.status.isGranted,
      ];

      if (!status[0]) {
        status[0] = await Permission.bluetoothScan.request().isGranted;
      }

      if (!status[1]) {
        status[1] = await Permission.bluetoothConnect.request().isGranted;
      }

      return (status[0] && status[1]) ? true : false;
    } else {
      if (!await Permission.bluetooth.isGranted) {
        return (await Permission.bluetooth.request().isGranted) ? true : false;
      }

      return true;
    }
  }

  void showScanner(double vh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '請掃描主辦方提供的 QR code',
              style: TextStyle(
                color: Colors.white,
                fontSize: Constants.defaultTextSize,
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox.square(
              dimension: 250.0,
              child: QRView(
                key: GlobalKey(debugLabel: 'QR'),
                onQRViewCreated: (QRViewController controller) {
                  qrController = controller;
                  controller.scannedDataStream.listen((scanData) {
                    if (scanData.code != null) {
                      qrController!.dispose();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TouringPage(
                            accessibility: Provider.of<Userdata>(context, listen: false).accessibility!,
                            domain: scanData.code,
                          ),
                        ),
                      );
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
