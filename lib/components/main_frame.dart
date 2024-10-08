import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/config/page_status.dart';
import '/config/palette.dart';

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
              title: Text(pageStatus.currentTitle),
              actions: pageStatus.getAppBarActions(context),
            ),
            body: pageStatus.pageBody,
            floatingActionButton: SizedBox(
              width: vw * 0.18,
              height: vh * 0.18,
              child: FloatingActionButton(
                backgroundColor: (pageStatus.currentIndex == 0) ? Palette.secondaryColor : Palette.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/app_logo_foreground.png'),
                ),
                onPressed: () => pageStatus.currentIndex = 0,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: bottomAppBar(vw, pageStatus),
          );
        },
      ),
    );
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
              child: bottomAppBarItem(vw, pageStatus, 1),
            ),
            SizedBox(
              width: vw * 0.4,
              child: bottomAppBarItem(vw, pageStatus, 2),
            ),
          ],
        ),
      ),
    );
  }

  /* INFO: 導覽列元素 */
  SizedBox bottomAppBarItem(double vw, PageStatus pageStatus, int index) {
    bool flag = (pageStatus.currentIndex == index) ? true : false;

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
              PageStatus.title[index],
              style: TextStyle(
                color: flag ? Palette.secondaryColor : Colors.grey,
              ),
            ),
          ],
        ),
        onTap: () => pageStatus.currentIndex = index,
      ),
    );
  }
}
