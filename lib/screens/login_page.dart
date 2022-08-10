// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '/config/constants.dart';
import '/components/widgets.dart';
import '/config/palette.dart';
import '/utils/save_to_local.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  final phoneController = TextEditingController();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  PackageInfo? packageInfo;
  bool isPhoneInputArea = true; // 若為 true 則顯示手機輸入介面，false 則顯示驗證碼輸入介面
  bool isWorking = false; // 是否讓 button 顯示載入動畫
  String verificationId = ''; // 當使用者成功送出手機號碼後，將會從 Firebase 取得
  String otpCode = '';

  @override
  void initState() {
    super.initState();
    initPackageInfo();
  }

  void initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double vh = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // 點擊螢幕任一處以轉移焦點
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Container(
              width: vw,
              height: vh,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Palette.primaryColor, Palette.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: vh * 0.15,
              left: (vw - vh * 0.15) / 2,
              child: SizedBox(
                width: vh * 0.15,
                height: vh * 0.15,
                child: Image.asset('assets/app_logo_foreground.png'),
              ),
            ),
            Positioned(
              top: vh * 0.32,
              left: vw * 0.1,
              child: Container(
                width: vw * 0.8,
                height: vh * 0.38,
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Palette.backgroundColor,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: isPhoneInputArea ? phoneInputArea() : otpInputArea(),
              ),
            ),
            Positioned(
              bottom: 20.0,
              child: SizedBox(
                width: vw,
                child: Text(
                  'version: ${packageInfo?.version}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* INFO: 手機輸入介面 */
  Column phoneInputArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const AutoSizeText(
              'Welcome Back !',
              style: TextStyle(
                fontSize: Constants.headline1Size,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 10.0),
            const AutoSizeText(
              '一支手機號碼，即可使用所有功能',
              style: TextStyle(fontSize: Constants.contentSize),
              maxLines: 1,
            ),
            const SizedBox(height: 30.0),
            Widgets.phoneTextField(
              enabled: !isWorking,
              controller: widget.phoneController,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [Widgets.loginButton(isWorking, '送出', verifyPhone)],
        ),
      ],
    );
  }

  /* INFO: 拿手機號碼跟 Firebase 溝通 */
  Future<void> verifyPhone() async {
    if (widget.phoneController.text.length != 10) {
      Widgets.alertDialog(
        context,
        title: '無法傳送認證簡訊',
        content: '您輸入的手機號碼格式有誤，請正確輸入10位數字！',
      );
      return;
    }

    setState(() => isWorking = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+886${widget.phoneController.text.substring(1)}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        setState(() => isWorking = true);
        await FirebaseAuth.instance.signInWithCredential(credential);
        Fluttertoast.showToast(
          msg: '成功自動輸入驗證碼',
          timeInSecForIosWeb: 3,
        );

        await tasksAfterLogin();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          Widgets.alertDialog(
            context,
            title: '無法傳送認證簡訊',
            content: '您輸入的手機號碼格式有誤，請正確輸入10位數字！',
          );
        } else {
          Widgets.alertDialog(
            context,
            title: '發生錯誤',
            content: '${e.code}: ${e.message}',
          );
        }
        setState(() => isWorking = false);
      },
      codeSent: (String id, int? resendToken) {
        setState(() {
          isWorking = false;
          verificationId = id;
          isPhoneInputArea = false; // 跳轉至 OTP 驗證畫面
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /* INFO: OTP 輸入介面 */
  Column otpInputArea() {
    return Column(
      children: [
        const Text(
          '快完成了！',
          style: TextStyle(
            fontSize: Constants.headline1Size,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        const AutoSizeText(
          'Hello Stranger 已經發送簡訊至您的手機，請輸入 6 位數驗證碼',
          style: TextStyle(fontSize: Constants.contentSize),
          maxLines: 2,
        ),
        const SizedBox(height: 30.0),
        Expanded(
          child: PinCodeTextField(
            appContext: context,
            enabled: !isWorking,
            length: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (code) {
              setState(() => otpCode = code);
            },
            onCompleted: (code) {
              setState(() => otpCode = code);
              verifyOTP();
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              activeColor: Palette.secondaryColor,
              selectedColor: Palette.primaryColor,
              inactiveColor: Colors.grey,
              disabledColor: Colors.grey.shade300,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isWorking
                  ? null
                  : () {
                      setState(() => isPhoneInputArea = true);
                    },
              child: const Text(
                '上一頁',
                style: TextStyle(fontSize: Constants.defaultTextSize),
              ),
            ),
            Widgets.loginButton(isWorking, '驗證', verifyOTP),
          ],
        ),
      ],
    );
  }

  /* INFO: 拿 OTP 跟 Firebase 溝通 */
  Future<void> verifyOTP() async {
    setState(() => isWorking = true);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        Widgets.alertDialog(
          context,
          title: '驗證失敗',
          content: '您輸入的驗證碼有誤，請重新輸入！',
        );
      } else if (e.code == 'session-expired') {
        Widgets.alertDialog(
          context,
          title: '驗證失敗',
          content: '憑證已過期，請回到上一頁重新發送驗證碼！',
        );
      } else {
        Widgets.alertDialog(
          context,
          title: '發生錯誤',
          content: '${e.code}: ${e.message}',
        );
      }
      setState(() => isWorking = false);

      return;
    }

    await tasksAfterLogin();
  }

  /* INFO: 登入成功後，若已是成員則從雲端下載資料，否則導向至註冊頁面 */
  Future<void> tasksAfterLogin() async {
    try {
      var db = FirebaseFirestore.instance;
      var phone = FirebaseAuth.instance.currentUser!.phoneNumber;
      final doc = await db.collection('users').doc(phone).get();
      if (doc.exists) {
        await saveUserdata(doc.data()!, context);
        await saveAccountPhotoFromFirebase(phone!, context);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/enroll');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'storage/object-not-found') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        rethrow;
      }
    } on TimeoutException catch (e) {
      Widgets.alertDialog(
        context,
        title: '網路連線不佳',
        content: e.toString(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      Widgets.alertDialog(
        context,
        title: '發生錯誤',
        content: e.toString(),
      );
      setState(() => isWorking = false);
    }
  }
}
