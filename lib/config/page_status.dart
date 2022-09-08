import 'package:flutter/material.dart';

import '/screens/history_page.dart';
import '/screens/home_page.dart';
import '/screens/more_info_page.dart';

class PageStatus extends ChangeNotifier {
  /* INFO: private static variables */
  static const List<String> title = [
    'Hello Stranger',
    '歷史足跡',
    '更多',
  ];

  static const List<Widget> _pageBody = [
    HomePage(),
    HistoryPage(),
    MoreInfoPage(),
  ];

  /* INFO: public static variables */
  static const List<IconData?> navIcon = [
    null,
    Icons.directions_walk,
    Icons.more_horiz,
  ];

  /* INFO: variables */
  int _currentIndex = 0;

  /* INFO: getters */
  int get currentIndex => _currentIndex;
  String get currentTitle => title[_currentIndex];
  Widget get pageBody => _pageBody[_currentIndex];

  /* INFO: setters */
  /* NOTE: 使用底部導覽列切換頁面時需要呼叫的函式 */
  set currentIndex(int idx) {
    _currentIndex = idx;
    notifyListeners();
  }

  /* INFO: 取得當前頁面的 AppBar actions */
  List<Widget> getAppBarActions(BuildContext context) {
    return [];
  }
}
