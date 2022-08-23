// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '/components/widgets.dart';
import '/config/constants.dart';
import '/config/palette.dart';
import '/config/userdata.dart';
import '/utils/firebase_communication.dart';

class AddFriendPage extends StatefulWidget {
  AddFriendPage({Key? key}) : super(key: key);

  final phoneController = TextEditingController();

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  Map<String, dynamic>? resultMap;
  bool showResultArea = false;
  String? resultDisplayName;
  File? resultPhoto;
  String buttonText = '發送交友請求';
  bool restrict = false; // 若搜尋之用戶有存在交友邀請清單、我的邀請清單、朋友清單三者之一，則為 true
  bool isWorking = false;

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double vh = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // 點擊螢幕任一處以轉移焦點
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('新增好友')),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: vw * 0.12,
            vertical: vh * 0.12,
          ),
          child: Column(
            children: [
              const SizedBox(
                width: double.infinity,
                child: AutoSizeText(
                  '請輸入欲加入好友的手機號碼：',
                  maxLines: 1,
                  style: TextStyle(fontSize: Constants.defaultTextSize),
                ),
              ),
              const SizedBox(height: 12.0),
              Stack(
                fit: StackFit.loose,
                children: [
                  Widgets.phoneTextField(
                    enabled: true,
                    controller: widget.phoneController,
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.search),
                      color: Palette.primaryColor,
                      splashRadius: Constants.defaultTextSize,
                      onPressed: searching,
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              if (showResultArea) resultArea(vw),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  /* INFO: 按下搜尋鍵後執行的工作 */
  Future<void> searching() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (widget.phoneController.text.length != 10) {
      Widgets.alertDialog(
        context,
        title: '格式錯誤',
        content: '您輸入的手機號碼格式有誤，請正確輸入10位數字！',
      );
      return;
    }

    String phone = '+886${widget.phoneController.text.substring(1)}';
    if (phone == FirebaseAuth.instance.currentUser!.phoneNumber) {
      Widgets.alertDialog(
        context,
        title: '我知道你在想什麼',
        content: '自己不能跟自己成為好友喔！',
      );
      return;
    }

    Map<String, dynamic>? data = await fetchMemberdataPublic(phone);
    if (data != null) {
      data['phone'] = phone;
      for (Map person in Provider.of<Userdata>(context, listen: false).friendRequests!) {
        if (person['phone'] == phone) {
          restrict = true;
          setState(() => buttonText = '好友已寄邀請');
          break;
        }
      }
      if (!restrict) {
        for (Map person in Provider.of<Userdata>(context, listen: false).myRequests!) {
          if (person['phone'] == phone) {
            restrict = true;
            setState(() => buttonText = '等待好友回覆');
            break;
          }
        }
      }
      if (!restrict) {
        for (Map person in Provider.of<Userdata>(context, listen: false).friends!) {
          if (person['phone'] == phone) {
            restrict = true;
            setState(() => buttonText = '已經成為好友');
            break;
          }
        }
      }
    }

    setState(() {
      resultMap = data;
      showResultArea = true;
      resultDisplayName = (data != null) ? data['displayName'] : null;
    });

    if (data != null) {
      File? photo;
      photo = await downloadMemberphoto(phone);
      setState(() => resultPhoto = photo);
    }
  }

  /* INFO: 搜尋結果區域，按下搜尋鍵後顯示 */
  Widget resultArea(double vw) {
    if (resultMap == null) {
      return const SizedBox(
        width: double.infinity,
        child: AutoSizeText(
          '該號碼尚未加入 Hello Stranger 喔~',
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Constants.defaultTextSize,
            color: Palette.secondaryColor,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox.square(
          dimension: vw * 0.4,
          child: ClipOval(child: (resultPhoto == null) ? Image.asset('assets/default_account_photo.png') : Image.file(resultPhoto!)),
        ),
        const SizedBox(height: 20.0),
        SizedBox(
          width: double.infinity,
          child: AutoSizeText(
            resultDisplayName!,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: Constants.headline3Size,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: (!restrict && !isWorking)
                  ? () async {
                      setState(() => isWorking = true);
                      await sendMyRequest(resultMap!, Provider.of<Userdata>(context, listen: false));
                      setState(() {
                        isWorking = false;
                        restrict = true;
                        buttonText = '已送出邀請';
                      });
                    }
                  : null,
              child: isWorking
                  ? const SpinKitThreeBounce(
                      color: Colors.white,
                      size: Constants.defaultTextSize,
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(fontSize: Constants.defaultTextSize),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
