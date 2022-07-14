import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '/config/constants.dart';
import '/config/palette.dart';
import '/components/widgets.dart';

class EnrollPage extends StatefulWidget {
  EnrollPage({Key? key}) : super(key: key);

  final ImagePicker picker = ImagePicker();

  @override
  State<EnrollPage> createState() => _EnrollPageState();
}

class _EnrollPageState extends State<EnrollPage> {
  File? accountPhoto;

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
                    child: ClipOval(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: (accountPhoto == null) ? Image.asset('assets/default_account_photo.png') : Image.file(accountPhoto!),
                      ),
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
                          onPressed: pickAndCropImage,
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

  void pickAndCropImage() async {
    try {
      final XFile? pickedImage = await widget.picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage == null) {
        return;
      } else {
        setState(() {
          accountPhoto = File(pickedImage.path);
        });
      }
    } on PlatformException catch (e) {
      Widgets.dialog(
        context,
        title: '上傳圖片失敗',
        content: '原因：${e.message ?? '未知的錯誤'}',
      );
    }
  }
}
