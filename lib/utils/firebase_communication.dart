// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '/components/progress_dialog/progress_dialog_model.dart';
import '/config/userdata.dart';
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
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    announcement: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/* INFO: 取得 FCM token */
Future<String?> getFcmToken() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  return fcmToken;
}

/* INFO: App 在背景執行的通知推播 callback function */
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

/* INFO: 從 Cloud Firestore 下載完整使用者資料 */
Future<Map<String, dynamic>?> fetchUserdata() async {
  final db = FirebaseFirestore.instance;
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final ref = db.collection('users').doc(phone);

  final userDoc = await ref.get();
  if (!userDoc.exists) return null;

  Map<String, dynamic> userdataMap = userDoc.data()!;

  await ref.collection('private').doc('realName').get().then((doc) {
    userdataMap['realName'] = doc.data()!['value'];
  });

  await ref.collection('friendRequests').get().then((collection) {
    userdataMap['friendRequests'] = collection.docs.map((doc) => doc.data()).toList();
  });

  await ref.collection('myRequests').get().then((collection) {
    userdataMap['myRequests'] = collection.docs.map((doc) => doc.data()).toList();
  });

  await ref.collection('friends').get().then((collection) {
    userdataMap['friends'] = collection.docs.map((doc) => doc.data()).toList();
  });

  return userdataMap;
}

/* INFO: 註冊用戶 */
Future<void> registerAccount(BuildContext context, {required ProgressDialogModel progress, required Map<String, dynamic> userdataPublicMap, required Map<String, dynamic> userdataPrivateMap, File? userphoto}) async {
  final db = FirebaseFirestore.instance;
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  await db.runTransaction((transaction) async {
    /* Step 1: 取得目前用戶總數 */
    final memberCountDoc = db.collection('variables').doc('memberCount');
    final snapshot = await transaction.get(memberCountDoc);
    final int newMemberCount = snapshot.get('value') + 1;

    /* Step 2: 準備 userdata */
    progress.update(0.25, '2/4: 初始用戶資料');
    userdataPublicMap['id'] = newMemberCount; // 賦予新用戶之 id = 目前用戶總數 + 1

    /* Step 3: 上傳 userdata 和帳戶圖片至 Firebase */
    progress.update(0.5, '3/4: 上傳資料至雲端');
    if (userphoto != null) {
      await uploadUserphoto(userphoto);
    }
    final publicRef = db.collection('users').doc(phone);
    transaction.set(publicRef, userdataPublicMap);
    final realNameRef = db.collection('users').doc(phone).collection('private').doc('realName');
    transaction.set(realNameRef, {'value': userdataPrivateMap['realName']});
    final fcmTokenRef = db.collection('users').doc(phone).collection('private').doc('fcmToken');
    transaction.set(fcmTokenRef, {'value': userdataPrivateMap['fcmToken']});

    /* Step 4: 儲存 userdata 和帳戶圖片至本地 */
    progress.update(0.75, '4/4: 寫入資料至本地');
    Provider.of<Userdata>(context, listen: false).updateUserdataPublic = userdataPublicMap;
    Provider.of<Userdata>(context, listen: false).updateUserdataPrivate = userdataPrivateMap;
    Provider.of<Userdata>(context, listen: false).friendRequests = [];
    Provider.of<Userdata>(context, listen: false).myRequests = [];
    Provider.of<Userdata>(context, listen: false).friends = [];
    await saveUserdataMap(Provider.of<Userdata>(context, listen: false).map);
    if (userphoto != null) {
      Provider.of<Userdata>(context, listen: false).updateUserphoto = userphoto;
      await saveUserphoto(userphoto);
    }

    transaction.update(memberCountDoc, {'value': newMemberCount});
  }).then((value) {
    progress.update(1, '大功告成！');
  }).catchError((e) {
    deleteFile('userdata.json');
    deleteFile('userphoto.jpg');
    progress.hasError(e.toString());
  });
}

/* INFO: 上傳使用者公開資料至 Cloud Firestore */
void uploadUserdataPublic(Map<String, dynamic> map) {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final ref = db.collection('users').doc(phone);
  batch.update(ref, map);
  batch.commit();
}

/* INFO: 上傳使用者私人資料至 Cloud Firestore */
void uploadUserdataPrivate(Map<String, dynamic> map) {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;

  if (map['realName'] != null) {
    final ref = db.collection('users').doc(phone).collection('private').doc('realName');
    batch.set(ref, {'value': map['realName']});
  }

  if (map['fcmToken'] != null) {
    final ref = db.collection('users').doc(phone).collection('private').doc('fcmToken');
    batch.set(ref, {'value': map['fcmToken']});
  }

  batch.commit();
}

/* INFO: 上傳使用者頭貼至 Cloud Storage */
Future<void> uploadUserphoto(File photo) async {
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final photoRef = FirebaseStorage.instance.ref().child('accountPhoto/$phone.jpg');
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

/* INFO: 從 Cloud Storage 下載使用者頭貼並儲存 */
Future<File?> downloadUserphoto() async {
  final appDir = await getApplicationDocumentsDirectory();
  File jpg = File('${appDir.path}/userphoto.jpg');
  await jpg.create();

  final phone = FirebaseAuth.instance.currentUser!.phoneNumber!;
  final photoRef = FirebaseStorage.instance.ref().child('accountPhoto/$phone.jpg');
  try {
    await photoRef.writeToFile(jpg);
  } on FirebaseException catch (e) {
    await jpg.delete();
    if (e.code == 'object-not-found') {
      return null;
    } else {
      rethrow;
    }
  }

  return jpg;
}

/* INFO: 利用 phone 參數從 Cloud Firestore 下載該用戶公開資料，若無結果將會回傳 null */
Future<Map<String, dynamic>?> fetchMemberdataPublic(String phone) async {
  final db = FirebaseFirestore.instance;
  final ref = db.collection('users').doc(phone);
  final userDoc = await ref.get();
  if (!userDoc.exists) {
    return null;
  } else {
    return userDoc.data();
  }
}

/* INFO: 利用 phone 參數從 Cloud Storage 下載該用戶頭貼並儲存，若無結果將會回傳 null */
Future<File?> downloadMemberphoto(String phone) async {
  final appDir = await getApplicationDocumentsDirectory();
  File jpg = File('${appDir.path}/accountPhoto/$phone.jpg');
  await jpg.create();

  final photoRef = FirebaseStorage.instance.ref().child('accountPhoto/$phone.jpg');
  try {
    await photoRef.writeToFile(jpg);
  } on FirebaseException catch (e) {
    await jpg.delete();
    if (e.code == 'object-not-found') {
      return null;
    }
  }

  return jpg;
}

/* INFO: 發送交友邀請給 phone 參數之用戶 */
Future<void> sendMyRequest(Map<String, dynamic> map, Userdata userdata) async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  final myPhone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final myRef = db.collection('users').doc(myPhone).collection('myRequests').doc(map['phone']);
  final targetRef = db.collection('users').doc(map['phone']).collection('friendRequests').doc(myPhone);

  batch.set(myRef, {
    'phone': map['phone'],
    'displayName': map['displayName'],
  });
  batch.set(targetRef, {
    'phone': myPhone,
    'displayName': userdata.displayName,
    'realName': userdata.realName,
  });

  await batch.commit();
}

/* INFO: 接受交友邀請 */
Future<void> acceptFriendRequest(Map<String, dynamic> map, Userdata userdata) async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  final myPhone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final myRef = db.collection('users').doc(myPhone);
  final targetRef = db.collection('users').doc(map['phone']);
  final chatroomRef = db.collection('chatrooms').doc();
  map['chatroom'] = chatroomRef.id;

  batch.delete(myRef.collection('friendRequests').doc(map['phone']));
  batch.delete(targetRef.collection('myRequests').doc(myPhone));
  batch.set(myRef.collection('friends').doc(map['phone']), map);
  batch.set(targetRef.collection('friends').doc(myPhone), {
    'phone': myPhone,
    'displayName': userdata.displayName,
    'realName': userdata.realName,
    'chatroom': chatroomRef.id,
  });
  batch.set(chatroomRef, {
    'members': [myPhone, map['phone']],
  });

  await batch.commit();
}

/* INFO: 建立新訊息 */
Future<void> createMessage(String friendPhone, String content) async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  final myPhone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final ref = db.collection('users').doc(myPhone).collection('friends').doc(friendPhone);

  batch.update(ref, {'message': content});

  await batch.commit();
}
