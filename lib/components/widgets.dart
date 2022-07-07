import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/config/constants.dart';
import '/config/palette.dart';

class Widgets {
  static Widget loginButton(bool isWorking, Function() function) {
    return ElevatedButton(
      onPressed: isWorking ? () {} : function,
      child: isWorking
          ? const SpinKitThreeBounce(
              color: Colors.white,
              size: Constants.buttonFontSize,
            )
          : const Text(
              '送出',
              style: TextStyle(
                color: Colors.white,
                fontSize: Constants.buttonFontSize,
              ),
            ),
    );
  }
}
