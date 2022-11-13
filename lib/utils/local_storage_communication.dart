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

/* INFO: 儲存使用者頭貼 */
Future<File> saveUserphoto(File photo) async {
  File jpg = File('${(await getAppDir()).path}/userphoto.jpg');
  await jpg.create();
  await photo.copy('${(await getAppDir()).path}/userphoto.jpg');

  return jpg;
}

/* INFO: 檢查本地是否有 history.json，若無則建立 */
Future<void> historyFileCheck() async {
  File json = File('${(await getAppDir()).path}/history.json');
  if (!json.existsSync()) {
    await json.create();
    await json.writeAsString('[]');
  }
}

/* INFO: 從本地取得 history.json 解析之陣列 */
Future<List> getHistoryList() async {
  File json = File('${(await getAppDir()).path}/history.json');
  return jsonDecode(await json.readAsString());
}

/* INFO: 更新 history.json */
Future<void> updateHistoryFile(List list) async {
  File json = File('${(await getAppDir()).path}/history.json');
  await json.writeAsString(jsonEncode(list));
}

/* INFO: 刪除指定資料夾 */
Future<void> deleteDirectory(String path) async {
  Directory dir = Directory('${(await getAppDir()).path}/$path');
  if (dir.existsSync()) await dir.delete(recursive: true);
}

/* INFO: 刪除所有檔案 (登出) */
Future<void> deleteAllFile() async {
  File f = File('${(await getAppDir()).path}/history.json');
  await f.writeAsString('[]');

  f = File('${(await getAppDir()).path}/userphoto.jpg');
  if (f.existsSync()) await f.delete();

  Directory d = Directory('${(await getAppDir()).path}/history');
  if (d.existsSync()) await d.delete(recursive: true);
}

/* INFO: 在一般導覽模式下，根據 photoRef 取得掃描到裝置之圖片 */
/* NOTE: type A */
Future<Image> downloadDeviceImage(String uniqueId, String photoRef) async {
  final res = await Dio().get<List<int>>(
    photoRef,
    options: Options(responseType: ResponseType.bytes),
  );
  String rootPath = (await getAppDir()).path;
  await Directory('$rootPath/history').create();
  await Directory('$rootPath/history/$uniqueId').create();
  File jpg = File('$rootPath/history/$uniqueId/photo.jpg');
  await jpg.create();
  await jpg.writeAsBytes(res.data!);

  return Image.file(jpg);
}

/* INFO: 在一般導覽模式下，根據 photoRef 取得掃描到裝置之音檔 */
/* NOTE: type A */
Future<File> downloadDeviceAudio(String uniqueId, String audioRef) async {
  final res = await Dio().get<List<int>>(
    audioRef,
    options: Options(responseType: ResponseType.bytes),
  );
  String rootPath = (await getAppDir()).path;
  await Directory('$rootPath/history').create();
  await Directory('$rootPath/history/$uniqueId').create();
  File mp3 = File('$rootPath/history/$uniqueId/audio.mp3');
  await mp3.create();
  await mp3.writeAsBytes(res.data!);

  return mp3;
}
