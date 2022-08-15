import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '/components/main_frame.dart';
import '/config/constants.dart';
import '/config/palette.dart';
import '/config/userdata.dart';
import '/firebase_options.dart';
import '/screens/add_friend_page.dart';
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

  /* INFO: 確認本地端資料 */
  Map<String, dynamic>? userdataMap;
  final appDir = await getApplicationDocumentsDirectory();
  final userdataFile = File('${appDir.path}/userdata.json');
  File? accountPhoto = File('${appDir.path}/account_photo.jpg');
  if (userdataFile.existsSync() && FirebaseAuth.instance.currentUser != null) {
    // NOTE: 本地有 userdata.json，且 Firebase 有 currentUser，登入才成立
    final userdataStr = await userdataFile.readAsString();
    userdataMap = jsonDecode(userdataStr);
    userdataMap!['enrollTime'] = DateTime.parse(userdataMap['enrollTime']); // String -> Datetime
  } else if (userdataFile.existsSync()) {
    // NOTE: 本地有 userdata.json，但 Firebase 沒有 currentUser
    await userdataFile.delete();
    if (accountPhoto.existsSync()) {
      await accountPhoto.delete();
    }
  } else {
    // NOTE: Firebase 有 currentUser，但本地沒有 userdata.json
    await FirebaseAuth.instance.signOut();
  }

  if (!accountPhoto.existsSync()) {
    accountPhoto = null;
  }
  /* --- END --- */

  runApp(
    ChangeNotifierProvider<Userdata>(
      create: (context) => Userdata(map: userdataMap, photo: accountPhoto),
      child: const HelloStranger(),
    ),
  );
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
      initialRoute: (FirebaseAuth.instance.currentUser != null) ? '/main' : '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/enroll': (context) => EnrollPage(),
        '/main': (context) => const MainFrame(),
        '/main/addFriend': (context) => AddFriendPage(),
      },
    );
  }
}
