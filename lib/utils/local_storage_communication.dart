import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

/* NOTE: 
    - download -> 下載並儲存
    - fetch -> 僅下載
    - save -> 僅儲存
*/

/* INFO: 儲存完整使用者資料 */
Future<File> saveUserdataMap(Map<String, dynamic> userdataMap) async {
  if (userdataMap['enrollTime'] is Timestamp) {
    userdataMap['enrollTime'] = (userdataMap['enrollTime'] as Timestamp).toDate();
  }

  userdataMap['enrollTime'] = userdataMap['enrollTime'].toString();
  final appDir = await getApplicationDocumentsDirectory();
  File json = File('${appDir.path}/userdata.json');
  await json.create();
  await json.writeAsString(jsonEncode(userdataMap));

  return json;
}

/* INFO: 儲存使用者頭貼 */
Future<File> saveUserphoto(File photo) async {
  final appDir = await getApplicationDocumentsDirectory();
  File jpg = File('${appDir.path}/userphoto.jpg');
  await jpg.create();
  await photo.copy('${appDir.path}/userphoto.jpg');

  return jpg;
}

/* INFO: 刪除儲存在本地的檔案 */
Future<void> deleteFile(String path) async {
  final appDir = await getApplicationDocumentsDirectory();
  File file = File('${appDir.path}/$path');
  if (file.existsSync()) {
    await file.delete();
  }
}

Future<void> checkAccountPhotoModifiedDate() async {
  final appDir = await getApplicationDocumentsDirectory();
  Directory dir = Directory('${appDir.path}/accountPhoto');
  if (!dir.existsSync()) {
    await dir.create();
  }
  await dir.list().toList().then((list) async {
    for (var file in list) {
      file.statSync().modified;
    }
  });
}
