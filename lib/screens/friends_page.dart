import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/components/widgets.dart';
import '/config/constants.dart';
import '/config/palette.dart';
import '/config/userdata.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();

  static List<Widget> appBarActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.person_add),
        onPressed: () {
          bool isWorking = false;
          final phoneController = TextEditingController();

          var dialog = (Platform.isAndroid)
              ? AlertDialog(
                  title: Text('新增好友'),
                  content: Widgets.phoneTextField(enabled: !isWorking, controller: phoneController),
                  scrollable: true,
                  actions: [
                    TextButton(
                      child: const Text('確認'),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                )
              : CupertinoAlertDialog(
                  title: Text('新增好友'),
                  content: Widgets.phoneTextField(enabled: !isWorking, controller: phoneController),
                  actions: [
                    TextButton(
                      child: const Text('確認'),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                );

          showDialog(context: context, builder: (BuildContext context) => dialog);
        },
      ),
    ];
  }
}

class _FriendsPageState extends State<FriendsPage> {
  List<bool> expandedFlag = [false, false, true];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            child: ExpansionPanelList(
              children: [friendRequestsPanel(), myRequestsPanel(), friendsPanel()],
              expansionCallback: (panelIndex, isExpanded) {
                setState(() => expandedFlag[panelIndex] = !expandedFlag[panelIndex]);
              },
            ),
          ),
        );
      },
    );
  }

  ExpansionPanel friendRequestsPanel() {
    return ExpansionPanel(
      canTapOnHeader: true,
      isExpanded: expandedFlag[0],
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: const Icon(
            Icons.mark_email_unread,
            color: Palette.secondaryColor,
          ),
          title: Text(
            '交友邀請確認 (${Provider.of<Userdata>(context).friendRequests!.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
      body: Column(
        children: [
          const Divider(height: 0),
          ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: ClipOval(
                child: Image.file(Provider.of<Userdata>(context).accountPhoto!),
              ),
            ),
            title: const Text(
              'PR',
              style: TextStyle(fontSize: Constants.defaultTextSize),
            ),
            subtitle: const Text('+886989030602'),
            trailing: GestureDetector(
              child: const Icon(Icons.check_circle, size: 40, color: Colors.green),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  ExpansionPanel myRequestsPanel() {
    return ExpansionPanel(
      canTapOnHeader: true,
      isExpanded: expandedFlag[1],
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: const Icon(
            Icons.schedule_send,
            color: Palette.secondaryColor,
          ),
          title: Text(
            '我發出的邀請 (${Provider.of<Userdata>(context).myRequests!.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
      body: Column(
        children: [
          const Divider(height: 0),
          ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: ClipOval(
                child: Image.file(Provider.of<Userdata>(context).accountPhoto!),
              ),
            ),
            title: const Text(
              'PR',
              style: TextStyle(fontSize: Constants.defaultTextSize),
            ),
            subtitle: const Text('+886989030602'),
          ),
        ],
      ),
    );
  }

  ExpansionPanel friendsPanel() {
    return ExpansionPanel(
      canTapOnHeader: true,
      isExpanded: expandedFlag[2],
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: const Icon(
            Icons.people_alt,
            color: Palette.secondaryColor,
          ),
          title: Text(
            '好友 (${Provider.of<Userdata>(context).friends!.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
      body: Column(
        children: [
          const Divider(height: 0),
          ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: ClipOval(
                child: Image.file(Provider.of<Userdata>(context).accountPhoto!),
              ),
            ),
            title: const Text(
              'PR',
              style: TextStyle(fontSize: Constants.defaultTextSize),
            ),
            subtitle: const Text('+886989030602'),
          ),
        ],
      ),
    );
  }
}
