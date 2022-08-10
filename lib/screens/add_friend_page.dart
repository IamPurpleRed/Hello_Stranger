import 'package:flutter/material.dart';

import '/components/widgets.dart';

class AddFriendPage extends StatefulWidget {
  AddFriendPage({Key? key}) : super(key: key);

  final phoneController = TextEditingController();

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double vh = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(height: vh * 0.1),
        Row(
          children: [
            Widgets.phoneTextField(
              enabled: true,
              controller: widget.phoneController,
            ),
          ],
        ),
      ],
    );
  }
}
