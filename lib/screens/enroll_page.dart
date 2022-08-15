// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_stranger/utils/firebase_communication.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/userdata.dart';
import '/components/widgets.dart';
import '/components/progress_dialog/progress_dialog.dart';
import '/components/progress_dialog/progress_dialog_model.dart';
import '/config/constants.dart';
import '/config/palette.dart';
import '/utils/local_storage_communication.dart';

class EnrollPage extends StatefulWidget {
  EnrollPage({Key? key}) : super(key: key);

  final ImagePicker picker = ImagePicker();
  final displayNameController = TextEditingController();
  final realNameController = TextEditingController();

  @override
  State<EnrollPage> createState() => _EnrollPageState();
}

class _EnrollPageState extends State<EnrollPage> {
  File? accountPhoto;

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double vh = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // 點擊螢幕任一處以轉移焦點
      child: Scaffold(
        appBar: AppBar(title: const Text('註冊')),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: vh * 0.05),
                child: const AutoSizeText(
                  '歡迎新朋友，讓大家知道你是誰吧！',
                  style: TextStyle(fontSize: Constants.defaultTextSize),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: SizedBox.square(
                  dimension: vw * 0.5,
                  child: accountPhotoArea(vw),
                ),
              ),
              SizedBox(height: vh * 0.05),
              Center(
                child: SizedBox(
                  width: vw * 0.7,
                  child: inputArea(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: vh * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: (accountPhoto == null)
                          ? null
                          : () {
                              setState(() => accountPhoto = null);
                            },
                      child: const Text(
                        '重置圖片',
                        style: TextStyle(fontSize: Constants.defaultTextSize),
                      ),
                    ),
                    SizedBox(width: vw * 0.1),
                    ElevatedButton(
                      onPressed: registerAccount,
                      child: const Text(
                        '確認送出',
                        style: TextStyle(fontSize: Constants.defaultTextSize),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /* INFO: 使用者頭貼 */
  Stack accountPhotoArea(double vw) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipOval(
            child: FittedBox(
              fit: BoxFit.fill,
              child: (accountPhoto == null) ? Image.asset('assets/default_account_photo.png') : Image.file(accountPhoto!),
            ),
          ),
        ),
        Positioned(
          left: vw * 0.35,
          bottom: 0,
          child: SizedBox.square(
            dimension: vw * 0.15,
            child: ElevatedButton(
              onPressed: pickAndCropImage,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10.0),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Icon(
                  Icons.image_search,
                  size: constraints.maxWidth,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* INFO: 選擇並裁剪照片 */
  Future<void> pickAndCropImage() async {
    XFile? pickedImage;

    try {
      pickedImage = await widget.picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage == null) {
        return; // 使用者沒有或是取消選取照片
      }
    } on PlatformException catch (e) {
      Widgets.alertDialog(
        context,
        title: '上傳圖片失敗',
        content: '原因：${e.message ?? '未知的錯誤'}',
      );
      return;
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 500,
      maxHeight: 500,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪您的帳戶圖片',
          toolbarColor: Palette.primaryColor,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Palette.secondaryColor,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: '裁剪您的帳戶圖片',
          doneButtonTitle: '讚啦',
          cancelButtonTitle: '取消',
        ),
      ],
    );
    if (croppedFile == null) {
      return; // 使用者取消
    } else {
      setState(() => accountPhoto = File(croppedFile.path));
    }
  }

  /* INFO: 輸入格區域 */
  Column inputArea() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: TextField(
            controller: widget.displayNameController,
            style: const TextStyle(fontSize: Constants.defaultTextSize),
            decoration: const InputDecoration(
              labelText: '暱稱 (必填)',
              hintText: '公開顯示的名稱',
              prefixIcon: Icon(Icons.person),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: TextField(
            controller: widget.realNameController,
            style: const TextStyle(fontSize: Constants.defaultTextSize),
            decoration: const InputDecoration(
              labelText: '真實姓名 (選填)',
              hintText: '方便好友辨認',
              prefixIcon: Icon(Icons.badge),
            ),
          ),
        ),
      ],
    );
  }

  /* INFO: 註冊帳號 */
  Future<void> registerAccount() async {
    if (widget.displayNameController.text == '') {
      Widgets.alertDialog(
        context,
        title: '註冊失敗',
        content: '暱稱為必填欄位！',
      );

      return;
    }

    var progress = ProgressDialogModel(0, '1/4: 與雲端建立連線');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (context) => progress,
          child: const ProgressDialog(),
        );
      },
    );

    final db = FirebaseFirestore.instance;
    await db.runTransaction((transaction) async {
      /* Step 1: 取得目前用戶總數 */
      final memberCountDoc = db.collection('variables').doc('memberCount');
      final snapshot = await transaction.get(memberCountDoc);
      final int newMemberCount = snapshot.get('value') + 1;

      /* Step 2: 準備 userdata */
      progress.update(0.25, '2/4: 初始用戶資料');
      Map<String, dynamic> userdataPublicMap = {
        'id': newMemberCount, // 賦予新用戶之 id = 目前用戶總數 + 1
        'enrollTime': DateTime.now().toUtc(),
        'displayName': widget.displayNameController.text,
      };
      Map<String, dynamic> userdataPrivateMap = {
        'realName': widget.realNameController.text,
      };

      /* Step 3: 上傳 userdata 和帳戶圖片至 Firebase */
      progress.update(0.5, '3/4: 上傳資料至雲端');
      if (accountPhoto != null) {
        uploadAccountPhoto(accountPhoto!);
      }
      uploadUserdataPublic(userdataPublicMap);
      uploadUserdataPrivate(userdataPrivateMap);

      /* Step 4: 儲存 userdata 和帳戶圖片至本地 */
      progress.update(0.75, '4/4: 寫入資料至本地');
      Provider.of<Userdata>(context, listen: false).updateUserdataPublic = userdataPublicMap;
      Provider.of<Userdata>(context, listen: false).updateUserdataPrivate = userdataPrivateMap;
      Provider.of<Userdata>(context, listen: false).friendRequests = [];
      Provider.of<Userdata>(context, listen: false).myRequests = [];
      Provider.of<Userdata>(context, listen: false).friends = [];
      await saveUserdataMapToJson(Provider.of<Userdata>(context).map);
      if (accountPhoto != null) {
        Provider.of<Userdata>(context, listen: false).updateAccountPhoto = accountPhoto;
        await saveAccountPhotoFromFile(accountPhoto!);
      }

      transaction.update(memberCountDoc, {'value': newMemberCount});
    }).then((value) {
      progress.update(1, '大功告成！');
    }).catchError((e) {
      if (e is PlatformException || e is TimeoutException) {
        progress.hasError(e.message!);
      } else {
        progress.hasError(e.toString());
      }
    });
  }
}
