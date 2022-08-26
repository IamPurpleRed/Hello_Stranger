// ignore_for_file: use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '/components/widgets.dart';
import '/config/constants.dart';
import '/config/palette.dart';
import '/config/userdata.dart';
import '/utils/firebase_communication.dart';
import '/utils/local_storage_communication.dart';

class NewMessagePage extends StatefulWidget {
  NewMessagePage({Key? key}) : super(key: key);

  final msgController = TextEditingController();

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  Map? selectedFriend;
  bool isWorking = false;

  @override
  Widget build(BuildContext context) {
    final List friendList = Provider.of<Userdata>(context).friends!;
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // 點擊螢幕任一處以轉移焦點
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('建立訊息')),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: (selectedFriend == null) ? chooseFriendArea(friendList) : messageArea(),
        ),
      ),
    );
  }

  Column chooseFriendArea(List friendList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10.0),
        const Text(
          '首先，選擇您想傳送的對象：',
          style: TextStyle(fontSize: Constants.defaultTextSize),
        ),
        const SizedBox(height: 10.0),
        const Text(
          '若您想傳送的對象無法點擊，代表您之前設定要傳給他的訊息尚未傳送。',
          style: TextStyle(color: Colors.grey, fontSize: Constants.contentSize),
        ),
        const SizedBox(height: 20.0),
        Expanded(
          child: (friendList.isEmpty)
              ? const AutoSizeText(
                  '您目前還沒有好友',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Constants.defaultTextSize,
                    color: Palette.secondaryColor,
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: friendList.length,
                  itemBuilder: (context, idx) {
                    return ListTile(
                      leading: Image.asset('assets/default_account_photo.png'),
                      trailing: (friendList[idx]['message'] == null) ? const Icon(Icons.arrow_forward_ios_rounded) : null,
                      title: Text(
                        friendList[idx]['displayName'],
                        style: const TextStyle(fontSize: Constants.defaultTextSize),
                      ),
                      subtitle: Text(friendList[idx]['phone']),
                      onTap: (friendList[idx]['message'] == null)
                          ? () {
                              setState(() => selectedFriend = friendList[idx]);
                            }
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Column messageArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10.0),
        const Text(
          '請輸入訊息內容',
          style: TextStyle(fontSize: Constants.defaultTextSize),
        ),
        const SizedBox(height: 10.0),
        const Text(
          'Hello Stranger 必須保持背景執行，才能成功傳送訊息',
          style: TextStyle(color: Colors.grey, fontSize: Constants.contentSize),
        ),
        const SizedBox(height: 30.0),
        const Text(
          '傳送對象 (點擊即可重新選擇)：',
          style: TextStyle(fontSize: Constants.contentSize),
        ),
        const SizedBox(height: 10.0),
        ListTile(
          leading: Image.asset('assets/default_account_photo.png'),
          title: Text(
            selectedFriend!['displayName'],
            style: const TextStyle(fontSize: Constants.defaultTextSize),
          ),
          subtitle: Text(selectedFriend!['phone']),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          onTap: () {
            setState(() => selectedFriend = null);
          },
        ),
        const SizedBox(height: 20.0),
        const Text(
          '訊息內容：',
          style: TextStyle(fontSize: Constants.contentSize),
        ),
        const SizedBox(height: 10.0),
        TextField(
          controller: widget.msgController,
          maxLines: 8,
          style: const TextStyle(fontSize: Constants.defaultTextSize),
          decoration: InputDecoration(
            hintText: '請輸入訊息內容',
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Palette.secondaryColor,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                Provider.of<Userdata>(context).friends![selectedFriend!['phone']]['message'] = widget.msgController.text;
                try {
                  await createMessage(selectedFriend!['phone'], widget.msgController.text);
                  await saveUserdataMap(Provider.of<Userdata>(context).map);
                } catch (e) {
                  Widgets.alertDialog(context, title: '發生錯誤', content: e.toString());
                  return;
                }
                Fluttertoast.showToast(
                  msg: '訊息建立成功',
                  timeInSecForIosWeb: 3,
                );
                Navigator.pop(context);
              },
              child: isWorking
                  ? const SpinKitThreeBounce(
                      color: Colors.white,
                      size: Constants.defaultTextSize,
                    )
                  : const Text(
                      '確認',
                      style: TextStyle(fontSize: Constants.defaultTextSize),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
