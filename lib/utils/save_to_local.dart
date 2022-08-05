// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '/config/userdata.dart';

/* INFO: map -> Userdata instance & local JSON file */
Future<void> saveUserdata(Map<String, dynamic> userdataMap, BuildContext context) async {
  if (userdataMap['enrollTime'] is Timestamp) {
    userdataMap['enrollTime'] = (userdataMap['enrollTime'] as Timestamp).toDate();
  } else if (userdataMap['enrollTime'] is String) {
    userdataMap['enrollTime'] = DateTime.parse(userdataMap['enrollTime']);
  }
  Provider.of<Userdata>(context, listen: false).decode(userdataMap); // convert to Userdata instance

  userdataMap['enrollTime'] = userdataMap['enrollTime'].toString();
  final appDir = await getApplicationDocumentsDirectory();
  await File('${appDir.path}/userdata.json').create();
  await File('${appDir.path}/userdata.json').writeAsString(jsonEncode(userdataMap));
}

/* INFO: 儲存用戶大頭貼至本地 (來自 File 格式的變數) */
Future<void> saveAccountPhotoFromFile(File photo, BuildContext context) async {
  Provider.of<Userdata>(context, listen: false).photo(photo);
  final appDir = await getApplicationDocumentsDirectory();
  await File('${appDir.path}/account_photo.jpg').create();
  await photo.copy('${appDir.path}/account_photo.jpg');
}

/* INFO: 儲存用戶大頭貼至本地 (來自 Firebase) */
Future<void> saveAccountPhotoFromFirebase(String phone, BuildContext context) async {
  final appDir = await getApplicationDocumentsDirectory();
  File accountPhoto = File('${appDir.path}/account_photo.jpg');
  final photoRef = FirebaseStorage.instance.ref().child('accountPhoto/$phone.jpg');
  final task = photoRef.writeToFile(accountPhoto);
  await task.timeout(
    const Duration(seconds: 30),
    onTimeout: () async {
      await task.cancel();
      throw TimeoutException('您已成功登入，但圖片下載逾時，請至網路穩定的地方再繼續使用 Hello Stranger！');
    },
  );

  Provider.of<Userdata>(context, listen: false).photo(accountPhoto);
}
