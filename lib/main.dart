import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/config/constants.dart';
import '/config/palette.dart';
import '/firebase_options.dart';
import '/screens/enroll_page.dart';
import '/screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]); // 鎖定螢幕方向只能為垂直(網頁版不會鎖定)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HelloStranger());
}

class HelloStranger extends StatelessWidget {
  const HelloStranger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Stranger',
      theme: ThemeData(
        primaryColor: Palette.primaryColor,
        scaffoldBackgroundColor: Palette.backgroundColor,
        buttonTheme: ButtonThemeData(
          buttonColor: Palette.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: Constants.defaultTextSize,
          ),
          contentPadding: const EdgeInsets.all(6.0),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Palette.inputEnableColor,
            ),
            borderRadius: BorderRadius.circular(35.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Palette.inputDisableColor,
            ),
            borderRadius: BorderRadius.circular(35.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Palette.secondaryColor,
            ),
            borderRadius: BorderRadius.circular(35.0),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/enroll': (context) => EnrollPage(),
      },
    );
  }
}
