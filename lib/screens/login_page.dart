import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/config/palette.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  PackageInfo? packageInfo;
  bool isPhoneInputArea = true; // 當前是否正在顯示 phoneInputArea
  bool isWorking = false; // 是否讓 button 顯示載入動畫
  String verificationId = ''; // 當使用者成功送出手機號碼後，將會從 Firebase 取得

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
        body: Stack(
          children: [
            Container(
              width: vw,
              height: vh,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0ED2F7), Color(0xFFB2FEFA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: vh * 0.4,
              left: vw * 0.1,
              child: Container(
                width: vw * 0.8,
                height: vh * 0.35,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
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

  /* INFO: 輸入格 */
  Padding textfield({required Icon prefixIcon, required String fieldName, required TextInputType keyboardType, required TextEditingController controller, required int maxLength}) {
    const double fontSize = 18.0;

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
        style: const TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: fieldName,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: fontSize),
          contentPadding: const EdgeInsets.all(6.0),
          prefixIcon: prefixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(35.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Palette.secondaryColor),
            borderRadius: BorderRadius.circular(35.0),
          ),
        ),
      ),
    );
  }

  /* INFO: 手機輸入介面 */
  Column phoneInputArea() {
    return Column(
      children: [
        textfield(
          prefixIcon: const Icon(Icons.phone_android),
          fieldName: '手機號碼',
          controller: widget.phoneController,
          keyboardType: TextInputType.number,
          maxLength: 10,
        ),
        TextButton(
          onPressed: verifyPhone,
          child: isWorking ? const SpinKitThreeBounce(color: Colors.white, size: 18.0) : Container(child: const Text('送出')),
        ),
      ],
    );
  }

  /* INFO: 拿手機號碼跟 Firebase 溝通 */
  void verifyPhone() async {
    setState(() {
      isWorking = true;
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+886${widget.phoneController.text.substring(1)}',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (FirebaseAuth.instance.currentUser == null) {
          print('login failed.');
        } else {
          print('login successful.');
        }
        setState(() {
          isWorking = false;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        } else {
          print('other error.');
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
        textfield(
          prefixIcon: const Icon(Icons.phone_android),
          fieldName: '驗證碼',
          controller: widget.otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        TextButton(
          onPressed: verifyOTP,
          child: isWorking ? const SpinKitThreeBounce(color: Colors.white, size: 18.0) : Container(child: const Text('送出')),
        ),
      ],
    );
  }

  /* INFO: 拿 OTP 跟 Firebase 溝通 */
  void verifyOTP() async {
    setState(() {
      isWorking = true;
    });
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: widget.otpController.text);
    await FirebaseAuth.instance.signInWithCredential(credential);
    if (FirebaseAuth.instance.currentUser == null) {
      print('login failed.');
    } else {
      print('login successful.');
    }
    setState(() {
      isWorking = false;
    });
  }
}
