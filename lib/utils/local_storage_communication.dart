import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

/* INFO: Map<String, dynamic> -> local JSON file */
Future<File> saveUserdataMapToJson(Map<String, dynamic> userdataMap) async {
  if (userdataMap['enrollTime'] is Timestamp) {
    userdataMap['enrollTime'] = (userdataMap['enrollTime'] as Timestamp).toDate();
  }

  userdataMap['enrollTime'] = userdataMap['enrollTime'].toString();
  final appDir = await getApplicationDocumentsDirectory();
  File json = File('${appDir.path}/userdata.json');
  if (!json.existsSync()) {
    await json.create();
  }
  await json.writeAsString(jsonEncode(userdataMap));

  return json;
}

/* INFO: File -> local image file */
Future<File> saveAccountPhotoFromFile(File photo) async {
  final appDir = await getApplicationDocumentsDirectory();
  File file = File('${appDir.path}/account_photo.jpg');
  if (!file.existsSync()) {
    await file.create();
  }
  await photo.copy('${appDir.path}/account_photo.jpg');

  return file;
}
