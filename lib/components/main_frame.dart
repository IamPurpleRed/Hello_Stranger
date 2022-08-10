import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/config/page_status.dart';
import '/config/palette.dart';
import '/screens/friends_page.dart';
import '/screens/home_page.dart';
import '/screens/messages_page.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double vh = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (context) => PageStatus(),
      child: Consumer<PageStatus>(
        builder: (context, pageStatus, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(pageStatus.title),
              actions: pageStatus.getAppBarActions(context),
            ),
            body: pageStatus.pageBody,
            floatingActionButton: SizedBox(
              width: vw * 0.18,
              height: vh * 0.18,
              child: FloatingActionButton(
                backgroundColor: Palette.primaryColor,
                child: LayoutBuilder(
                  builder: (context, constraints) => Icon(
                    Icons.add_comment,
                    size: constraints.maxWidth - 30,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {},
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: bottomAppBar(vw, pageStatus),
          );
        },
      ),
    );
  }

  /* INFO: 頁面內容 */
  Widget pageBody(int index) {
    if (index == 0) {
      return const HomePage();
    } else if (index == 1) {
      return const MessagesPage();
    } else if (index == 2) {
      return const FriendsPage();
    } else {
      return const HomePage();
    }
  }

  /* INFO: 底部導覽列 */
  BottomAppBar bottomAppBar(double vw, PageStatus pageStatus) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: vw * 0.4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  bottomAppBarItem(vw, pageStatus, 0),
                  bottomAppBarItem(vw, pageStatus, 1),
                ],
              ),
            ),
            SizedBox(
              width: vw * 0.4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  bottomAppBarItem(vw, pageStatus, 2),
                  bottomAppBarItem(vw, pageStatus, 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* INFO: 導覽列元素 */
  SizedBox bottomAppBarItem(double vw, PageStatus pageStatus, int index) {
    bool flag = false;
    if (pageStatus.currentIndex == index) {
      flag = true;
    }

    return SizedBox(
      width: vw * 0.15,
      child: InkWell(
        customBorder: const CircleBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PageStatus.navIcon[index],
              color: flag ? Palette.secondaryColor : Colors.grey,
            ),
            AutoSizeText(
              PageStatus.navTitle[index],
              style: TextStyle(
                color: flag ? Palette.secondaryColor : Colors.grey,
              ),
            ),
          ],
        ),
        onTap: () => pageStatus.switchPage(index),
      ),
    );
  }
}
