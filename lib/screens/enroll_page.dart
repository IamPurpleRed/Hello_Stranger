// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '/config/userdata.dart';
import '/components/widgets.dart';
import '/components/progress_dialog/progress_dialog.dart';
import '/components/progress_dialog/progress_dialog_model.dart';
import '/config/constants.dart';
import '/config/palette.dart';
import '/utils/firebase_communication.dart';
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
  File? userphoto;
  bool accessibility = false;

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
                      onPressed: (userphoto == null)
                          ? null
                          : () {
                              setState(() => userphoto = null);
                            },
                      child: const Text(
                        '重置圖片',
                        style: TextStyle(fontSize: Constants.defaultTextSize),
                      ),
                    ),
                    SizedBox(width: vw * 0.1),
                    ElevatedButton(
                      onPressed: registerTask,
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
              child: (userphoto == null) ? Image.asset('assets/default_account_photo.png') : Image.file(userphoto!),
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
      setState(() => userphoto = File(croppedFile.path));
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
              prefixIcon: Icon(Icons.badge),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Checkbox(
                value: accessibility,
                onChanged: (value) {
                  setState(() => accessibility = value!);
                },
              ),
              const Text('視障人士介面', style: TextStyle(fontSize: Constants.defaultTextSize)),
            ],
          ),
        ),
      ],
    );
  }

  /* INFO: 註冊帳號 */
  Future<void> registerTask() async {
    if (widget.displayNameController.text == '') {
      Widgets.alertDialog(
        context,
        title: '註冊失敗',
        content: '暱稱為必填欄位！',
      );

      return;
    }

    var progress = ProgressDialogModel(0, '向伺服器發送註冊請求');
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

    try {
      final enrollRes = await FirebaseFunctions.instanceFor(region: 'asia-east1').httpsCallable('enroll').call({
        'phone': getPhone(),
        'displayName': widget.displayNameController.text,
        'realName': widget.realNameController.text,
        'accessibility': accessibility,
        'fcmToken': await getFcmToken(),
        'hasPhoto': (userphoto != null),
      });
      if (enrollRes.data['code'] == 1) {
        throw Exception('雲端函式發生錯誤');
      }

      progress.update(0.25, '上傳帳戶圖片');
      if (userphoto != null) {
        await uploadUserphoto(userphoto!);
      }

      progress.update(0.5, '驗證註冊資料');
      final loginRes = await FirebaseFunctions.instanceFor(region: 'asia-east1').httpsCallable('login').call({
        'phone': getPhone(),
        'fcmToken': await getFcmToken(),
      });
      if (loginRes.data['code'] == 1) {
        throw Exception('雲端函式發生錯誤');
      }
      Provider.of<Userdata>(context, listen: false).importFromFirebase = loginRes.data['userdata'];

      progress.update(0.75, '寫入資料至本地');
      if (userphoto != null) {
        Provider.of<Userdata>(context, listen: false).updateUserphoto = userphoto;
        await saveUserphoto(userphoto!);
      }

      progress.update(1, '大功告成！');
    } catch (e) {
      progress.hasError(e.toString());
    }
  }
}
