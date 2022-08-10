import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/config/constants.dart';

class Widgets {
  /* INFO: 手機號碼專用輸入格 */
  static TextField phoneTextField({
    required bool enabled,
    required controller,
  }) {
    return TextField(
      enabled: enabled,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: const TextStyle(fontSize: Constants.defaultTextSize),
      decoration: const InputDecoration(
        labelText: '手機號碼',
        hintText: '09XXXXXXXX',
        prefixIcon: Icon(Icons.phone_android),
      ),
    );
  }

  /* INFO: 登入頁面按鈕 */
  static ElevatedButton loginButton(bool isWorking, String text, Function() function) {
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
  static void alertDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
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
}
