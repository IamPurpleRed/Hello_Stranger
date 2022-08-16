import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hello_stranger/utils/firebase_communication.dart';
import 'package:path_provider/path_provider.dart';
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
  final phone = FirebaseAuth.instance.currentUser!.phoneNumber;
  late DocumentReference<Map<String, dynamic>> ref;
  String? photoDir;

  List<bool> expandedFlag = [false, false, true];

  @override
  void initState() {
    super.initState();
    ref = FirebaseFirestore.instance.collection('users').doc(phone);
    getPhotoDir();
  }

  Future<void> getPhotoDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    setState(() => photoDir = '${appDir.path}/accountPhoto');
  }

  @override
  Widget build(BuildContext context) {
    if (photoDir == null) return const Center(child: Text('loading...'));
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            child: ExpansionPanelList(
              children: [
                friendRequestsPanel(),
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

  ExpansionPanel friendRequestsPanel() {
    return ExpansionPanel(
      canTapOnHeader: true,
      isExpanded: expandedFlag[0],
      headerBuilder: (context, isExpanded) {
        return const ListTile(
          leading: Icon(
            Icons.mark_email_unread,
            color: Palette.secondaryColor,
          ),
          title: Text(
            '交友邀請確認',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
      body: StreamBuilder(
        stream: ref.collection('friendRequests').snapshots(),
        initialData: Provider.of<Userdata>(context, listen: false).friendRequests!,
        builder: (context, snapshot) {
          late List resultList;
          if (snapshot.data is QuerySnapshot) {
            resultList = (snapshot.data as QuerySnapshot).docs.map((doc) => doc.data()).toList();
            Provider.of<Userdata>(context, listen: false).friendRequests = resultList;
          } else {
            resultList = snapshot.data as List;
          }

          List<Widget> colChildren = [];
          for (Map<String, dynamic> person in resultList) {
            colChildren.add(const Divider(height: 0));
            colChildren.add(
              ListTile(
                leading: accountPhoto(person),
                title: Text(
                  person['displayName'],
                  style: const TextStyle(fontSize: Constants.defaultTextSize),
                ),
                subtitle: Text(person['phone']),
                trailing: GestureDetector(
                  child: const Icon(Icons.check_circle, size: 40, color: Colors.green),
                  onTap: () => acceptFriendRequest(person, Provider.of<Userdata>(context, listen: false)),
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
        return const ListTile(
          leading: Icon(
            Icons.schedule_send,
            color: Palette.secondaryColor,
          ),
          title: Text(
            '我發出的邀請',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
      body: StreamBuilder(
        stream: ref.collection('myRequests').snapshots(),
        initialData: Provider.of<Userdata>(context, listen: false).myRequests!,
        builder: (context, snapshot) {
          late List resultList;
          if (snapshot.data is QuerySnapshot) {
            resultList = (snapshot.data as QuerySnapshot).docs.map((doc) => doc.data()).toList();
            Provider.of<Userdata>(context, listen: false).myRequests = resultList;
          } else {
            resultList = snapshot.data as List;
          }

          List<Widget> colChildren = [];
          for (Map<String, dynamic> person in resultList) {
            colChildren.add(const Divider(height: 0));
            colChildren.add(
              ListTile(
                leading: accountPhoto(person),
                title: Text(
                  person['displayName'],
                  style: const TextStyle(fontSize: Constants.defaultTextSize),
                ),
                subtitle: Text(person['phone']),
              ),
            );
          }

          return Column(children: colChildren);
        },
      ),
    );
  }

  ExpansionPanel friendsPanel() {
    return ExpansionPanel(
      canTapOnHeader: true,
      isExpanded: expandedFlag[2],
      headerBuilder: (context, isExpanded) {
        return const ListTile(
          leading: Icon(
            Icons.people_alt,
            color: Palette.secondaryColor,
          ),
          title: Text(
            '好友',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
      body: StreamBuilder(
        stream: ref.collection('friends').snapshots(),
        initialData: Provider.of<Userdata>(context, listen: false).friends!,
        builder: (context, snapshot) {
          late List resultList;
          if (snapshot.data is QuerySnapshot) {
            resultList = (snapshot.data as QuerySnapshot).docs.map((doc) => doc.data()).toList();
            Provider.of<Userdata>(context, listen: false).friends = resultList;
          } else {
            resultList = snapshot.data as List;
          }

          List<Widget> colChildren = [];
          for (Map<String, dynamic> person in resultList) {
            colChildren.add(const Divider(height: 0));
            colChildren.add(
              ListTile(
                leading: accountPhoto(person),
                title: Text(
                  person['displayName'],
                  style: const TextStyle(fontSize: Constants.defaultTextSize),
                ),
                subtitle: Text(person['phone']),
              ),
            );
          }

          return Column(children: colChildren);
        },
      ),
    );
  }

  SizedBox accountPhoto(Map<String, dynamic> person) {
    final defaultPhoto = Image.asset('assets/default_account_photo.png');
    return SizedBox(
      width: 50,
      height: 50,
      child: ClipOval(
        child: defaultPhoto,
        // FutureBuilder(
        //   future: fetchAccountPhotoToFile(phone: person['phone']),
        //   initialData: defaultPhoto,
        //   builder: (context, snapshot) {
        //     if (snapshot.hasError) {
        //       return defaultPhoto;
        //     } else if (snapshot.data is File) {
        //       return Image.file(snapshot.data as File);
        //     } else {
        //       return snapshot.data as Image;
        //     }
        //   },
        // ),
      ),
    );
  }
}
