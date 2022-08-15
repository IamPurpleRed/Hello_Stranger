import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

/* INFO: cloud_firestore -> Map<String, dynamic> */
Future<Map<String, dynamic>?> fetchUserdataToMap() async {
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

/* INFO: cloud_storage -> File(image) & local image file */
// NOTE: 若 fileName 參數未填寫，將視同為登入作業 -> 自己的照片
// NOTE: 若使用者沒有圖片，將觸發 FirebaseException: storage/object-not-found
Future<File> fetchAccountPhotoToFile({String? phone}) async {
  final appDir = await getApplicationDocumentsDirectory();
  late File photo;
  if (phone == null) {
    photo = File('${appDir.path}/account_photo.jpg');
  } else {
    photo = File('${appDir.path}/accountPhoto/$phone.jpg');
  }

  if (!photo.existsSync()) {
    await photo.create(recursive: true);
  }

  if (phone == null) {
    phone = FirebaseAuth.instance.currentUser!.phoneNumber!;
    final photoRef = FirebaseStorage.instance.ref().child('accountPhoto/$phone.jpg');
    final task = photoRef.writeToFile(photo);
    await task.timeout(
      const Duration(seconds: 30),
      onTimeout: () async {
        await task.cancel();
        throw TimeoutException('您已成功登入，但圖片下載逾時，請至網路穩定的地方再繼續使用 Hello Stranger！');
      },
    );
  } else {
    final photoRef = FirebaseStorage.instance.ref().child('accountPhoto/$phone.jpg');
    await photoRef.writeToFile(photo);
  }

  return photo;
}

/* INFO: Map<String, dynamic> -> cloud_firestore */
Future<void> uploadUserdataPublic(Map<String, dynamic> map) async {
  final db = FirebaseFirestore.instance;
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final ref = db.collection('users').doc(phone);
  await ref.set(map);
}

/* INFO: Map<String, dynamic> -> cloud_firestore */
Future<void> uploadUserdataPrivate(Map<String, dynamic> map) async {
  final db = FirebaseFirestore.instance;
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final ref = db.collection('users').doc(phone);
  await ref.collection('private').doc('realName').set({'value': map['realName']});
}

/* INFO: File(image) -> cloud_storage */
Future<void> uploadAccountPhoto(File photo) async {
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

/* INFO: 尋找該手機號碼的公開資料，若不是會員將會回傳 null */
Future<Map<String, dynamic>?> getMemberPublicData(String phone) async {
  final db = FirebaseFirestore.instance;
  final ref = db.collection('users').doc(phone);
  final userDoc = await ref.get();
  if (!userDoc.exists) {
    return null;
  } else {
    return userDoc.data();
  }
}
