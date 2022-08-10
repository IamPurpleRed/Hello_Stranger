import 'package:flutter/material.dart';

import '/screens/friends_page.dart';
import '/screens/home_page.dart';
import '/screens/messages_page.dart';

class PageStatus extends ChangeNotifier {
  static const List<String> title = [
    'Hello Stranger',
    '訊息',
    '好友名單',
    '更多',
  ];
  static List<List<Widget>?> appbarActions = [
    [],
    [],
    FriendsPage.appBarActions(),
    [],
  ];

  static const List<Widget> pageBody = [
    HomePage(),
    MessagesPage(),
    FriendsPage(),
    HomePage(),
  ];

  static const List<IconData> navIcon = [
    Icons.home,
    Icons.forum,
    Icons.people_alt,
    Icons.more_horiz,
  ];
  static const List<String> navTitle = [
    '首頁',
    '訊息',
    '好友',
    '更多',
  ];

  int currentIndex = 0;

  void switchPage(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
