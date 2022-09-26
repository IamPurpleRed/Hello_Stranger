import 'package:flutter/material.dart';
import 'package:hello_stranger/config/userdata.dart';
import 'package:provider/provider.dart';

class MoreInfoPage extends StatefulWidget {
  const MoreInfoPage({Key? key}) : super(key: key);

  @override
  State<MoreInfoPage> createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Text(Provider.of<Userdata>(context, listen: false).accessibility.toString());
  }
}
