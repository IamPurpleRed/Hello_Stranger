import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '/config/constants.dart';
import '/config/palette.dart';
import '/components/widgets.dart';

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
        appBar: AppBar(
          backgroundColor: Palette.primaryColor,
          title: const Text('註冊'),
        ),
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
                child: SizedBox(
                  width: vw * 0.5,
                  height: vw * 0.5,
                  child: accountPhotoArea(vw, vh),
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
                child: Center(
                  child: ElevatedButton(
                    onPressed: registerAccount,
                    child: const Text(
                      '註冊帳號',
                      style: TextStyle(fontSize: Constants.defaultTextSize),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /* INFO: 使用者頭貼 */
  Stack accountPhotoArea(double vw, double vh) {
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
          child: ClipOval(
            child: Container(
              width: vw * 0.15,
              height: vw * 0.15,
              color: Palette.secondaryColor,
              child: IconButton(
                icon: LayoutBuilder(
                  builder: (context, constraints) => Icon(
                    Icons.image_search,
                    size: constraints.maxWidth,
                  ),
                ),
                color: Colors.white,
                splashRadius: vw * 0.06,
                onPressed: pickAndCropImage,
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
      Widgets.dialog(
        context,
        title: '上傳圖片失敗',
        content: '原因：${e.message ?? '未知的錯誤'}',
      );
      return;
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      //aspectRatioPresets: [CropAspectRatioPreset.square],
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
      setState(() {
        accountPhoto = File(croppedFile.path);
      });
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

  Future<void> registerAccount() async {
    if (widget.displayNameController.text == '') {
      Widgets.dialog(
        context,
        title: '註冊失敗',
        content: '暱稱為必填欄位！',
      );

      return;
    }

    var db = FirebaseFirestore.instance;
    Map<String, dynamic> userdata = {
      'id': 0, // 尚未向 Firestore 取得
      'enrollTime': DateTime.now().toUtc(),
      'displayName': widget.displayNameController.text,
      'realName': widget.realNameController.text,
      'friends': [],
      'friendRequests': [],
      'blacklists': [],
    };

    db.runTransaction((transaction) async {
      final memberCountDoc = db.collection('variables').doc('memberCount');
      final snapshot = await transaction.get(memberCountDoc); // 取得目前會員總數，以賦予 id 給新會員
      int newMemberCount = snapshot.get('value') + 1;
      transaction.update(memberCountDoc, {'value': newMemberCount});
      return newMemberCount;
    }).then(
      (value) {
        userdata['id'] = value;
        var user = FirebaseAuth.instance.currentUser;
        db.collection('users').doc(user!.phoneNumber).set(userdata); // 寫入userdata 至 Firestore
      },
      onError: (e) {
        Widgets.dialog(
          context,
          title: '註冊失敗',
          content: e,
        );
      },
    );
  }
}
