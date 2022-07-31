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
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
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
                  child: CircularProgressIndicator(
                    color: Palette.secondaryColor,
                    backgroundColor: Colors.grey,
                    strokeWidth: 10.0,
                    value: model.value,
                  ),
                ),
                const Text(
                  '註冊中...',
                  style: TextStyle(
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
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
