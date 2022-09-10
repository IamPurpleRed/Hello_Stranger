import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

/* NOTE: 
    - download -> 下載並儲存
    - fetch -> 僅下載
    - save -> 僅儲存
*/

Future<Directory> getAppDir() async => await getApplicationDocumentsDirectory();

/* INFO: 儲存完整使用者資料 */
Future<File> saveUserdataMap(Map<String, dynamic> userdataMap) async {
  if (userdataMap['enrollTime'] is Timestamp) {
    userdataMap['enrollTime'] = (userdataMap['enrollTime'] as Timestamp).toDate();
  }

  userdataMap['enrollTime'] = userdataMap['enrollTime'].toString();
  File json = File('${(await getAppDir()).path}/userdata.json');
  await json.create();
  await json.writeAsString(jsonEncode(userdataMap));

  return json;
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
