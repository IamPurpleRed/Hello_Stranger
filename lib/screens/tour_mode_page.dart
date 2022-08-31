// ignore_for_file: use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hello_stranger/config/constants.dart';
import 'package:hello_stranger/config/palette.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class TourModePage extends StatefulWidget {
  const TourModePage({Key? key}) : super(key: key);

  @override
  State<TourModePage> createState() => _TourModePageState();
}

class _TourModePageState extends State<TourModePage> {
  QRViewController? qrController;
  String? url;

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double vh = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // 點擊螢幕任一處以轉移焦點
      child: Scaffold(
        appBar: AppBar(title: const Text('導覽模式')),
        body: Padding(
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
                    maxLines: 3,
                    style: TextStyle(fontSize: Constants.headline3Size),
                  ),
                  SizedBox(height: 10.0),
                  AutoSizeText(
                    '※ 進入導覽模式後，將會關閉螢幕休眠',
                    maxLines: 3,
                    style: TextStyle(
                      color: Palette.secondaryColor,
                      fontSize: Constants.contentSize,
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
                    onPressed: () => showScanner(vw),
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
                      onPressed: () {
                        Navigator.pushNamed(context, '/main/tourMode/touring');
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
      ),
    );
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
                      Navigator.pop(context);
                      setState(() {
                        url = scanData.code;
                      });
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
