import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/components/progress_dialog/progress_dialog_model.dart';
import '/config/constants.dart';
import '/config/palette.dart';

class ProgressDialog extends StatelessWidget {
  const ProgressDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;

    return Consumer<ProgressDialogModel>(
      builder: ((context, model, child) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            content: SizedBox(
              width: vw * 0.6,
              height: vw * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: vw * 0.2,
                    height: vw * 0.2,
                    child: mainIcon(model),
                  ),
                  Text(
                    model.error ? '發生錯誤' : '註冊中...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: Constants.headline3Size,
                    ),
                  ),
                  AutoSizeText(
                    model.detailedProgress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: Constants.defaultTextSize,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.all(0),
            actions: [
              if (model.value == 1 || model.error)
                TextButton(
                  child: const Text('確認'),
                  onPressed: () {
                    Navigator.pop(context);
                    if (model.value == 1) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                )
            ],
          ),
        );
      }),
    );
  }

  /* INFO: 根據情況顯示進度條、成功Icon或失敗Icon */
  Widget mainIcon(ProgressDialogModel model) {
    if (model.value == 1) {
      return const FittedBox(child: Icon(Icons.check_circle, color: Colors.green));
    } else if (model.error) {
      return const FittedBox(child: Icon(Icons.cancel, color: Colors.red));
    } else {
      return CircularProgressIndicator(
        color: Palette.secondaryColor,
        backgroundColor: Colors.grey,
        strokeWidth: 10.0,
        value: model.value,
      );
    }
  }
}
