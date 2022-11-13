// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_stranger/config/constants.dart';
import 'package:hello_stranger/config/palette.dart';
import 'package:hello_stranger/screens/login_page.dart';
import 'package:provider/provider.dart';

import '/config/userdata.dart';

class MoreInfoPage extends StatelessWidget {
  const MoreInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double vh = MediaQuery.of(context).size.height;
    final userphoto = Provider.of<Userdata>(context, listen: false).userphoto;
    final displayName = Provider.of<Userdata>(context, listen: false).displayName;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: vh * 0.08),
      child: Column(
        children: [
          Center(
            child: SizedBox.square(
              dimension: vw * 0.4,
              child: ClipOval(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: (userphoto == null) ? Image.asset('assets/default_account_photo.png') : Image.file(userphoto),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            displayName!,
            style: const TextStyle(fontSize: Constants.headline2Size),
          ),
          const SizedBox(height: 40.0),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: vw * 0.1),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ListTile(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Palette.dividerColor),
                    ),
                    leading: const Icon(Icons.logout),
                    title: const Text('登出', style: TextStyle(fontSize: Constants.defaultTextSize)),
                    dense: true,
                    onTap: () => showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    String title = '即將登出';
    String content = '確定要登出嗎？將會清除所有資料';
    var dialog = (Platform.isAndroid)
        ? AlertDialog(
            title: Text(title),
            content: Text(content),
            scrollable: true,
            actions: [
              TextButton(
                child: const Text('確啦'),
                onPressed: () async {
                  await Provider.of<Userdata>(context, listen: false).logout();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              TextButton(
                child: const Text('先不要'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          )
        : CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: const Text('確啦'),
                onPressed: () async {
                  await Provider.of<Userdata>(context, listen: false).logout();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              TextButton(
                child: const Text('先不要'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }
}
