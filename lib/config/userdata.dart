import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Userdata extends ChangeNotifier {
  int? id;
  DateTime? enrollTime;
  String? displayName;
  String? realName;
  List<Map<String, dynamic>>? friendRequests;
  List<Map<String, dynamic>>? myRequests;
  List<Map<String, dynamic>>? friends;

  File? accountPhoto;

  Userdata({Map<String, dynamic>? map, File? photo}) {
    if (map != null) {
      id = map['id'];
      enrollTime = DateTime.parse(map['enrollTime']);
      displayName = map['displayName'];
      realName = map['realName'];
      friendRequests = map['friendRequests'];
      myRequests = map['myRequests'];
      friends = map['friends'];
    }
    accountPhoto = photo;
    notifyListeners();
  }

  Map<String, dynamic> get map {
    return {
      'id': id,
      'enrollTime': enrollTime,
      'displayName': displayName,
      'realName': realName,
      'friendRequests': friendRequests,
      'myRequests': myRequests,
      'friends': friends,
    };
  }

  set importFromCloudFirestore(Map<String, dynamic> map) {
    id = map['id'];
    enrollTime = (map['enrollTime'] as Timestamp).toDate();
    displayName = map['displayName'];
    realName = map['realName'];
    friendRequests = map['friendRequests'];
    myRequests = map['myRequests'];
    friends = map['friends'];
    notifyListeners();
  }

  set updateUserdataPublic(Map<String, dynamic> map) {
    id = map['id'];
    enrollTime = map['enrollTime'];
    displayName = map['displayName'];
    notifyListeners();
  }

  set updateUserdataPrivate(Map<String, dynamic> map) {
    realName = map['realName'];
    notifyListeners();
  }

  set updateFriendRequests(List<Map<String, dynamic>> list) {
    friendRequests = list;
    notifyListeners();
  }

  set updateMyRequests(List<Map<String, dynamic>> list) {
    myRequests = list;
    notifyListeners();
  }

  set updateFriends(List<Map<String, dynamic>> list) {
    friends = list;
    notifyListeners();
  }

  set updateAccountPhoto(File? photo) {
    accountPhoto = photo;
    notifyListeners();
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
