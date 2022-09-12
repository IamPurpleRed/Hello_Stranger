import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hello_stranger/utils/local_storage_communication.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: FutureBuilder(
        initialData: const Text('loading'),
        future: printHistoryJsonStr(),
        builder: (context, snapshot) => snapshot.data as Widget,
      ),
    );
  }

  Future printHistoryJsonStr() async {
    return Text(await File('${(await getAppDir()).path}/history.json').readAsString());
  }
}
