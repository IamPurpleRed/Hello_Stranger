import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/utils/firebase_communication.dart';
import '/utils/local_storage_communication.dart';

class Userdata extends ChangeNotifier {
  int? id;
  DateTime? enrollTime;
  String? displayName;
  String? realName;
  bool? accessibility;
  bool? hasPhoto;
  File? userphoto;

  set importFromFirebase(Map map) {
    id = map['id'];
    enrollTime = Timestamp(map['enrollTime']['_seconds'], map['enrollTime']['_nanoseconds']).toDate();
    displayName = map['displayName'];
    realName = map['realName'];
    accessibility = map['accessibility'];
    hasPhoto = map['hasPhoto'];
    notifyListeners();
  }

  set updateUserphoto(File? photo) {
    userphoto = photo;
    notifyListeners();
  }

  Future<void> logout() async {
    id = null;
    enrollTime = null;
    displayName = null;
    realName = null;
    accessibility = null;
    hasPhoto = null;
    userphoto = null;
    // TODO: 使用者存在 Cloud Firestore 的 fcmToken 要移除
    notifyListeners();
    await deleteAllFile();
    await getFirebaseAuthInstance().signOut();
  }
}
