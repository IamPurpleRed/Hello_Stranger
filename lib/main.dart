import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/components/main_frame.dart';
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
        colorScheme: const ColorScheme.light().copyWith(
          primary: Palette.primaryColor, // ThemeData 中的 primaryColor 參數日後將會被移除
          secondary: Palette.secondaryColor, // ThemeData 中的 accent 參數已被棄用
        ),
        scaffoldBackgroundColor: Palette.backgroundColor,
        disabledColor: Colors.grey.shade300, // for checkbox
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Palette.secondaryGradientColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(6.0),
          floatingLabelStyle: const TextStyle(
            color: Palette.secondaryColor,
          ),
          prefixIconColor: Colors.grey,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Palette.secondaryColor,
            ),
            borderRadius: BorderRadius.circular(35.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(35.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(35.0),
          ),
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: Constants.defaultTextSize,
          ),
        ),
      ),
      initialRoute: /*(FirebaseAuth.instance.currentUser != null) ? '/home' : */ '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/enroll': (context) => EnrollPage(),
        '/home': (context) => const MainFrame(),
      },
    );
  }
}
