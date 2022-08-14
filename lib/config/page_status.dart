import 'package:flutter/material.dart';

import '/screens/friends_page.dart';
import '/screens/home_page.dart';
import '/screens/messages_page.dart';

class PageStatus extends ChangeNotifier {
  static const List<String> _title = [
    'Hello Stranger',
    '訊息',
    '好友名單',
    '更多',
  ];

  static const List<Widget> _pageBody = [
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

  get title => _title[currentIndex];
  get pageBody => _pageBody[currentIndex];

  /* INFO: 使用底部導覽列切換頁面時需要呼叫的函式 */
  void switchPage(int index) {
    currentIndex = index;
    notifyListeners();
  }

  /* INFO: 取得當前頁面的 AppBar actions */
  List<Widget> getAppBarActions(BuildContext context) {
    if (currentIndex == 2) {
      return FriendsPage.appBarActions(context);
    }

    return [];
  }
}
