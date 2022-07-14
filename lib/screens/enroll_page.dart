import 'package:flutter/material.dart';

import '/config/constants.dart';
import '/config/palette.dart';

class EnrollPage extends StatelessWidget {
  const EnrollPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.primaryColor,
        title: const Text('註冊'),
      ),
      body: SizedBox(
        width: vw,
        child: Column(
          children: [
            const Text(
              '歡迎新朋友，讓大家知道你是誰吧！',
              style: TextStyle(fontSize: Constants.contentSize),
            ),
            SizedBox(
              width: vw * 0.6,
              height: vw * 0.6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.asset('assets/default_account_photo.png'),
                    ),
                  ),
                  Positioned(
                    left: vw * 0.45,
                    bottom: 0,
                    child: ClipOval(
                      child: Container(
                        width: vw * 0.15,
                        height: vw * 0.15,
                        color: Palette.secondaryColor,
                        child: IconButton(
                          icon: LayoutBuilder(
                            builder: (context, constraints) => Icon(
                              Icons.image_search,
                              size: constraints.maxWidth,
                            ),
                          ),
                          color: Colors.white,
                          splashRadius: vw * 0.06,
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
