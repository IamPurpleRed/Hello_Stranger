import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/config/page_status.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PageStatus(),
      child: Consumer<PageStatus>(
        builder: (context, page, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(page.title),
            ),
          );
        },
      ),
    );
  }
}
