import 'dart:io';

import 'package:flutter/material.dart';

class Userdata extends ChangeNotifier {
  int? id;
  DateTime? enrollTime;
  String? displayName;
  String? realName;
  File? accountPhoto;
  List? friends;
  List? friendRequests;
  List? blacklists;
  Map? messages;

  Userdata();

  Userdata decode(Map<String, dynamic> userdataMap) {
    id = userdataMap['id'];
    displayName = userdataMap['displayName'];
    realName = userdataMap['realName'];
    friends = userdataMap['friends'];
    friendRequests = userdataMap['friendRequests'];
    blacklists = userdataMap['blacklists'];
    messages = userdataMap['messages'];

    // NOTE: 若是string，則需先將其轉換成datetime格式
    if (userdataMap['enrollTime'] is String) {
      enrollTime = DateTime.parse(userdataMap['enrollTime']);
    } else {
      enrollTime = userdataMap['enrollTime'];
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
    friendRequests = null;
    blacklists = null;
    messages = null;
    notifyListeners();

    return this;
  }
}
