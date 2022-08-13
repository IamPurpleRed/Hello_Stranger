import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hello_stranger/utils/firebase_communication.dart';
import 'package:provider/provider.dart';

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
        onPressed: () => Navigator.pushNamed(context, '/main/addFriend'),
      ),
    ];
  }
}

class _FriendsPageState extends State<FriendsPage> {
  List<bool> expandedFlag = [false, false, true];

  @override
  Widget build(BuildContext context) {
    final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
    final ref = FirebaseFirestore.instance.collection('users').doc(phone);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            child: ExpansionPanelList(
              children: [
                friendRequestsPanel(ref),
                myRequestsPanel(),
                friendsPanel(),
              ],
              expansionCallback: (panelIndex, isExpanded) {
                setState(() => expandedFlag[panelIndex] = !expandedFlag[panelIndex]);
              },
            ),
          ),
        );
      },
    );
  }

  ExpansionPanel friendRequestsPanel(DocumentReference ref) {
    final stream = ref.collection('friendRequests').snapshots();

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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        //initialData: Provider.of<Userdata>(context).friendRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          List resultList = snapshot.data!.docs.map((doc) => doc.data()).toList();

          List<Widget> colChildren = [];
          for (Map person in resultList) {
            colChildren.add(const Divider(height: 0));
            colChildren.add(
              ListTile(
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipOval(
                    child: person['hasPhoto']
                        ? FutureBuilder(
                            future: fetchAccountPhotoToFile(context, fileName: person['phone']),
                            initialData: Image.asset('assets/default_account_photo.png'),
                            builder: (context, snapshot) {
                              return Image.file(snapshot.data as File);
                            },
                          )
                        : Image.asset('assets/default_account_photo.png'),
                  ),
                ),
                title: Text(
                  person['displayName'],
                  style: const TextStyle(fontSize: Constants.defaultTextSize),
                ),
                subtitle: Text(person['phone']),
                trailing: GestureDetector(
                  child: const Icon(Icons.check_circle, size: 40, color: Colors.green),
                  onTap: () {},
                ),
              ),
            );
          }

          return Column(children: colChildren);
        },
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
