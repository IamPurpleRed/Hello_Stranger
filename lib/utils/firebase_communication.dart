import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import '/config/userdata.dart';

/* NOTE: 
    - download -> 下載並儲存
    - fetch -> 僅下載
    - save -> 僅儲存
*/

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

/* INFO: 上傳使用者公開資料至 Cloud Firestore */
void uploadUserdataPublic(Transaction transaction, Map<String, dynamic> map) {
  final db = FirebaseFirestore.instance;
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final ref = db.collection('users').doc(phone);
  transaction.set(ref, map);
}

/* INFO: 上傳使用者私人資料至 Cloud Firestore */
void uploadUserdataPrivate(Transaction transaction, Map<String, dynamic> map) {
  final db = FirebaseFirestore.instance;
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final ref = db.collection('users').doc(phone).collection('private').doc('realName');
  transaction.set(ref, {'value': map['realName']});
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

Future<void> acceptFriendRequest(Map<String, dynamic> map, Userdata userdata) async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  final myPhone = FirebaseAuth.instance.currentUser!.phoneNumber;
  final myRef = db.collection('users').doc(myPhone);
  final targetRef = db.collection('users').doc(map['phone']);

  batch.delete(myRef.collection('friendRequests').doc(map['phone']));
  batch.delete(targetRef.collection('myRequests').doc(myPhone));
  batch.set(myRef.collection('friends').doc(map['phone']), map);
  batch.set(targetRef.collection('friends').doc(myPhone), {
    'phone': myPhone,
    'displayName': userdata.displayName,
    'realName': userdata.realName,
  });

  await batch.commit();
}
