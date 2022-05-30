import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '/firebase_options.dart';
import '/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {'/login': (context) => LoginPage()},
    );
  }
}
