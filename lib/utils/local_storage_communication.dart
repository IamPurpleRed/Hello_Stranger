import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/* NOTE: 
    - download -> 下載並儲存
    - fetch -> 僅下載
    - save -> 僅儲存
*/

/* INFO: 取得本地 App 資料夾路徑 */
Future<Directory> getAppDir() async => await getApplicationDocumentsDirectory();

/* INFO: 從本地取得使用者頭貼，若無則回傳 null */
Future<File?> getUserphoto() async {
  File jpg = File('${(await getAppDir()).path}/userphoto.jpg');
  return (jpg.existsSync()) ? jpg : null;
}

Future historyFileCheck() async {
  File json = File('${(await getAppDir()).path}/history.json');
  if (!json.existsSync()) {
    await json.create();
    await json.writeAsString('[]');
  }
}

/* INFO: 儲存使用者頭貼 */
Future<File> saveUserphoto(File photo) async {
  File jpg = File('${(await getAppDir()).path}/userphoto.jpg');
  await jpg.create();
  await photo.copy('${(await getAppDir()).path}/userphoto.jpg');

  return jpg;
}

/* INFO: 刪除儲存在本地的檔案 */
Future<void> deleteFile(String path) async {
  File file = File('${(await getAppDir()).path}/$path');
  if (file.existsSync()) {
    await file.delete();
  }
}

Future<Image> saveDeviceImage(DateTime dt, String photoRef) async {
  final res = await Dio().get<List<int>>(
    photoRef,
    options: Options(responseType: ResponseType.bytes),
  );
  File jpg = File('${(await getAppDir()).path}/${dt.millisecondsSinceEpoch}.jpg');
  await jpg.create();
  await jpg.writeAsBytes(res.data!);

  return Image.file(jpg);
}

Future<void> addItemToHistoryFile(Map item) async {
  File json = File('${(await getAppDir()).path}/history.json');
  List list = jsonDecode(await json.readAsString());
  list.add(item);
  await json.writeAsString(jsonEncode(list));
}
