// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '/firebase_options.dart';
import '/utils/local_storage_communication.dart';

/* NOTE: 
    - download -> 下載並儲存
    - fetch -> 僅下載
    - save -> 僅儲存
*/

/* INFO: App 啟動時針對 Firebase 的初始化工作 */
Future<void> firebaseInit() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(announcement: true);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/* INFO: App 在背景執行的通知推播 callback function */
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/* INFO: 取得 Firebase 登入狀態 */
FirebaseAuth getFirebaseAuthInstance() => FirebaseAuth.instance;

/* INFO: 取得使用者手機號碼 */
String getPhone() => FirebaseAuth.instance.currentUser!.phoneNumber!;

/* INFO: 取得 FCM token */
Future<String?> getFcmToken() async => await FirebaseMessaging.instance.getToken();

/* INFO: 從 Cloud Storage 下載使用者頭貼並儲存 */
Future<File> downloadUserphoto() async {
  File jpg = File('${(await getAppDir()).path}/userphoto.jpg');
  await jpg.create();

  final photoRef = FirebaseStorage.instance.ref().child('accountPhotos/${getPhone()}.jpg');
  await photoRef.writeToFile(jpg);

  return jpg;
}

/* INFO: 上傳使用者頭貼至 Cloud Storage */
Future<void> uploadUserphoto(File photo) async {
  final photoRef = FirebaseStorage.instance.ref().child('accountPhotos/${getPhone()}.jpg');
  final task = photoRef.putFile(
    photo,
    SettableMetadata(contentType: "image/jpeg"),
  );
  await task.timeout(
    const Duration(seconds: 30),
    onTimeout: () async {
      await task.cancel();
      throw TimeoutException('圖片上傳逾時，若您的網路不穩定，請先避免上傳圖片');
    },
  );
}

Future<Widget> downloadDeviceImage(String deviceId) async {
  final data = await FirebaseStorage.instance.ref('devices/$deviceId/image.jpg').getData();
  return Image.memory(data!);
}
