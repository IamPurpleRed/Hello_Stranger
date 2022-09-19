import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

/* INFO: 從本地取得 history.json 解析之陣列 */
Future<List> getHistoryList() async {
  File json = File('${(await getAppDir()).path}/history.json');
  return jsonDecode(await json.readAsString());
}

/* INFO: 檢查本地是否有 history.json，若無則建立 */
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

/* INFO: 在一般導覽模式下，掃描到裝置之後的紀錄動作 */
Future<void> addItemToHistoryFile(Map item) async {
  File json = File('${(await getAppDir()).path}/history.json');
  List list = jsonDecode(await json.readAsString());
  if (list.isNotEmpty) {
    if (list[list.length - 1]['deviceId'] == item['deviceId']) {
      list[list.length - 1]['datetime'] = item['datetime'];
    } else {
      list.add(item);
    }
  } else {
    list.add(item);
  }
  await json.writeAsString(jsonEncode(list));
}

/* INFO: 在一般導覽模式下，根據 photoRef 取得掃描到裝置之圖片 */
Future<Image> downloadDeviceImage(DateTime dt, String photoRef) async {
  final res = await Dio().get<List<int>>(
    photoRef,
    options: Options(responseType: ResponseType.bytes),
  );

  return Image.memory(Uint8List.fromList(res.data!));
}
