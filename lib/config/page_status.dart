import 'package:flutter/material.dart';

class PageStatus extends ChangeNotifier {
  static const List<String> _title = ['Hello Stranger', '訊息', '好友名單', '更多'];
  static const List<Icon> navIcon = [Icon(Icons.home), Icon(Icons.forum), Icon(Icons.people_alt), Icon(Icons.more_horiz)];
  static const List<String> navTitle = ['首頁', '訊息', '好友', '更多'];

  int currentIndex = 0;
  String title = _title[0];

  void switchPage(int index) {
    currentIndex = index;
    title = _title[index];

    notifyListeners();
  }
}
