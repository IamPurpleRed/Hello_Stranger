import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Userdata extends ChangeNotifier {
  int? id;
  DateTime? enrollTime;
  String? displayName;
  File? accountPhoto;
  String? realName;
  List? friendRequests;
  List? myRequests;
  List? friends;

  Userdata();

  Userdata decode(Map<String, dynamic> userdataMap) {
    id = userdataMap['id'];
    displayName = userdataMap['displayName'];
    realName = userdataMap['realName'];
    friends = userdataMap['friends'];
    myRequests = userdataMap['myRequests'];
    friendRequests = userdataMap['friendRequests'];

    /* NOTE: 若是 string，則需先將其轉換成 datetime 格式 */
    if (userdataMap['enrollTime'] is Timestamp) {
      userdataMap['enrollTime'] = (userdataMap['enrollTime'] as Timestamp).toDate();
    } else if (userdataMap['enrollTime'] is String) {
      userdataMap['enrollTime'] = DateTime.parse(userdataMap['enrollTime']);
    }

    notifyListeners();

    return this;
  }

  Userdata photo(File? photo) {
    accountPhoto = photo;
    notifyListeners();

    return this;
  }

  Userdata logout() {
    id = null;
    enrollTime = null;
    displayName = null;
    realName = null;
    accountPhoto = null;
    friends = null;
    myRequests = null;
    friendRequests = null;
    notifyListeners();

    return this;
  }
}
