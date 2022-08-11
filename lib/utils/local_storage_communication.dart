import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '/config/userdata.dart';

/* INFO: Map<String, dynamic> -> JSON file */
Future<File> saveUserdataToJson(BuildContext context, Map<String, dynamic> userdataMap) async {
  if (userdataMap['enrollTime'] is Timestamp) {
    userdataMap['enrollTime'] = (userdataMap['enrollTime'] as Timestamp).toDate();
  }

  userdataMap['enrollTime'] = userdataMap['enrollTime'].toString();
  final appDir = await getApplicationDocumentsDirectory();
  File json = await File('${appDir.path}/userdata.json').create();
  await json.writeAsString(jsonEncode(userdataMap));

  return json;
}

/* INFO: File -> local image file */
Future<void> saveAccountPhotoFromFile(BuildContext context, File photo) async {
  Provider.of<Userdata>(context, listen: false).photo(photo);
  final appDir = await getApplicationDocumentsDirectory();
  await File('${appDir.path}/account_photo.jpg').create();
  await photo.copy('${appDir.path}/account_photo.jpg');
}
