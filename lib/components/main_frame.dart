import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/config/userdata.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;

    return Consumer<Userdata>(
      builder: (context, userdata, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('首頁')),
          body: SizedBox(
            width: vw * 0.7,
            height: vw * 0.7,
            child: ClipOval(
              child: FittedBox(
                fit: BoxFit.fill,
                child: (userdata.accountPhoto == null) ? Image.asset('assets/default_account_photo.png') : Image.file(userdata.accountPhoto!),
              ),
            ),
          ),
        );
      },
    );
  }
}
