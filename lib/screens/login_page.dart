import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '/config/constants.dart';
import '/config/palette.dart';
import '/components/widgets.dart';

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
                  colors: [Palette.primaryColor, Palette.primaryGradientColor],
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
      children: [
        const Text(
          'Welcome Back !',
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        const Text(
          '一支手機號碼，即可使用所有功能',
          style: TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 30.0),
        Expanded(
          child: TextField(
            enabled: !isWorking,
            controller: widget.phoneController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: const TextStyle(fontSize: Constants.textFieldFontSize),
            decoration: const InputDecoration(
              hintText: '手機號碼',
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Widgets.loginButton(isWorking, '送出', verifyPhone)],
        ),
      ],
    );
  }

  /* INFO: 拿手機號碼跟 Firebase 溝通 */
  void verifyPhone() async {
    if (widget.phoneController.text.length != 10) {
      Widgets.dialog(
        context,
        title: '無法傳送認證簡訊',
        content: '您輸入的手機號碼格式有誤，請正確輸入10位數字！',
      );
      return;
    }

    setState(() {
      isWorking = true;
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+886${widget.phoneController.text.substring(1)}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() {
          Navigator.pushReplacementNamed(context, '/enroll');
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          Widgets.dialog(
            context,
            title: '無法傳送認證簡訊',
            content: '您輸入的手機號碼格式有誤，請正確輸入10位數字！',
          );
        } else {
          Widgets.dialog(
            context,
            title: '發生錯誤',
            content: '${e.code}: ${e.message}',
          );
        }
        setState(() {
          isWorking = false;
        });
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
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        const Text(
          'Hello Stranger 已經發送簡訊至您的手機，請輸入 6 位數驗證碼',
          style: TextStyle(fontSize: 16.0),
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
              setState(() {
                otpCode = code;
              });
            },
            onCompleted: (code) {
              setState(() {
                otpCode = code;
              });
              verifyOTP();
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              activeColor: Palette.secondaryColor,
              selectedColor: Palette.primaryColor,
              inactiveColor: Colors.grey,
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
                      setState(() {
                        isPhoneInputArea = true;
                      });
                    },
              child: const Text('上一頁'),
            ),
            Widgets.loginButton(isWorking, '驗證', verifyOTP),
          ],
        ),
      ],
    );
  }

  /* INFO: 拿 OTP 跟 Firebase 溝通 */
  void verifyOTP() async {
    setState(() {
      isWorking = true;
    });
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        Widgets.dialog(
          context,
          title: '驗證失敗',
          content: '您輸入的驗證碼有誤，請重新輸入！',
        );
      } else if (e.code == 'session-expired') {
        Widgets.dialog(
          context,
          title: '驗證失敗',
          content: '憑證已過期，請回到上一頁重新發送驗證碼！',
        );
      } else {
        Widgets.dialog(
          context,
          title: '發生錯誤',
          content: '${e.code}: ${e.message}',
        );
      }
      setState(() {
        isWorking = false;
      });

      return;
    }

    setState(() {
      Navigator.pushReplacementNamed(context, '/enroll');
    });
  }
}
