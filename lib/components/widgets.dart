import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/config/constants.dart';

class Widgets {
  /* INFO: 登入頁面按鈕 */
  static Widget loginButton(bool isWorking, String text, Function() function) {
    return ElevatedButton(
      onPressed: isWorking ? null : function,
      child: isWorking
          ? const SpinKitThreeBounce(
              color: Colors.white,
              size: Constants.defaultTextSize,
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: Constants.defaultTextSize,
              ),
            ),
    );
  }

  /* INFO: 提示方塊（使用者僅可按確認） */
  static void alertDialog(BuildContext context, {required String title, required String content}) {
    var dialog = (Platform.isAndroid)
        ? AlertDialog(
            title: Text(title),
            content: Text(content),
            scrollable: true,
            actions: [
              TextButton(
                child: const Text('確認'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          )
        : CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: const Text('確認'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );

    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  static void progressIndicator() {
    Container(
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(),
    );
  }
}
