import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/config/constants.dart';
import '/config/palette.dart';
import '/utils/local_storage_communication.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;

    return FutureBuilder(
      initialData: const Center(
        child: SpinKitThreeBounce(
          color: Palette.secondaryColor,
          size: 30.0,
        ),
      ),
      future: getHistoryList().then((list) => list.reversed.toList()),
      builder: (context, snapshot) {
        if (snapshot.data.runtimeType == List) {
          List historyList = snapshot.data! as List;
          return (historyList.isEmpty)
              ? const Center(
                  child: Text(
                    '還沒有任何足跡喔！',
                    style: TextStyle(fontSize: Constants.defaultTextSize),
                  ),
                )
              : historyListView(vw, historyList);
        } else {
          return snapshot.data as Widget;
        }
      },
    );
  }

  ListView historyListView(double vw, List historyList) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: historyList.length,
      itemBuilder: (context, idx) {
        DateTime now = DateTime.now();
        DateTime dt = DateTime.parse(historyList[idx]['datetime']);
        late String dateStr;
        if (dt.year == now.year) {
          if (dt.month == now.month && dt.day == now.day) {
            dateStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          } else {
            dateStr = '${dt.month}/${dt.day}';
          }
        } else {
          dateStr = '${dt.year}/${dt.month}/${dt.day}';
        }

        return Column(
          children: [
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  historyList[idx]['title'],
                  style: const TextStyle(
                    fontSize: Constants.headline3Size,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              subtitle: SizedBox(
                width: vw * 0.5,
                child: Text(
                  historyList[idx]['content'],
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: Constants.contentSize,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(dateStr),
              ),
              minVerticalPadding: 10.0,
            ),
            const Divider(color: Palette.dividerColor),
          ],
        );
      },
    );
  }
}
