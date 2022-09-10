import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Userdata extends ChangeNotifier {
  int? id;
  DateTime? enrollTime;
  String? displayName;
  String? realName;
  bool? hasPhoto;
  File? userphoto;

  set importFromFirebase(Map map) {
    id = map['id'];
    enrollTime = Timestamp(map['enrollTime']['_seconds'], map['enrollTime']['_nanoseconds']).toDate();
    displayName = map['displayName'];
    realName = map['realName'];
    hasPhoto = map['hasPhoto'];
    notifyListeners();
  }

  set updateUserphoto(File? photo) {
    userphoto = photo;
    notifyListeners();
  }

  Userdata logout() {
    id = null;
    enrollTime = null;
    displayName = null;
    realName = null;
    hasPhoto = null;
    userphoto = null;
    // 使用者存在 Cloud Firestore 的 fcmToken 要移除
    notifyListeners();

    return this;
  }
}
