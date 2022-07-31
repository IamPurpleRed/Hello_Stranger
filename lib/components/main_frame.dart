import 'package:flutter/material.dart';
import 'package:hello_stranger/components/widgets.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('首頁')),
      body: Container(
        child: TextButton(
          child: const Text('測試'),
          onPressed: () {
            // Widgets.progressIndicator(
            //   context,
            //   vw: vw,
            //   value: 0.5,
            //   detail: 'detail',
            // );
          },
        ),
      ),
    );
  }
}
