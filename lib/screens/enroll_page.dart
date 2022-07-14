import 'package:flutter/material.dart';

import '/config/palette.dart';

class EnrollPage extends StatelessWidget {
  const EnrollPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double vh = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.primaryColor,
        title: const Text('註冊'),
      ),
      body: Column(
        children: [
          const Text('歡迎新朋友，讓大家知道你是誰吧！'),
          SizedBox(
            width: vw * 0.6,
            height: vw * 0.6,
            child: Stack(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: vw * 0.6,
                    height: vw * 0.6,
                    child: const FittedBox(
                      fit: BoxFit.fill,
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: vw * 0.45,
                  bottom: vw * 0.05,
                  child: ClipOval(
                    child: Container(
                      width: vw * 0.12,
                      height: vw * 0.12,
                      color: Palette.secondaryColor,
                      child: IconButton(
                        icon: LayoutBuilder(
                          builder: (context, constraints) => Icon(
                            Icons.image_search,
                            size: constraints.biggest.width,
                          ),
                        ),
                        color: Colors.white,
                        splashRadius: vw * 0.06,
                        onPressed: () {},
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
