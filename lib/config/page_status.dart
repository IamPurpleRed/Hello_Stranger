import 'package:flutter/material.dart';

import '/screens/friends_page.dart';
import '/screens/home_page.dart';
import '/screens/messages_page.dart';

class PageStatus extends ChangeNotifier {
  /* INFO: private static variables */
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

  /* INFO: public static variables */
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

  /* INFO: variables */
  int _currentIndex = 0;

  /* INFO: getters */
  int get currentIndex => _currentIndex;
  String get title => _title[_currentIndex];
  Widget get pageBody => _pageBody[_currentIndex];

  /* INFO: setters */
  /* NOTE: 使用底部導覽列切換頁面時需要呼叫的函式 */
  set currentIndex(int idx) {
    _currentIndex = idx;
    notifyListeners();
  }

  /* INFO: 取得當前頁面的 AppBar actions */
  List<Widget> getAppBarActions(BuildContext context) {
    if (_currentIndex == 2) {
      return FriendsPage.appBarActions(context);
    }

    return [];
  }
}
