import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/components/player/accessibility_player.dart';
import '/components/player/player.dart';
import '/components/player/player_model.dart';
import '/config/constants.dart';
import '/config/palette.dart';
import '/utils/local_storage_communication.dart';

List<Widget> typeA({
  required double vw,
  required double vh,
  required bool accessibility,
  required PlayerModel playerModel,
  required String uniqueId,
  required String title,
  String? content,
  String? photoRef,
  String? audioRef,
}) {
  if (accessibility) {
    return [
      Expanded(
        child: (audioRef != null)
            ? ChangeNotifierProvider(
                create: (context) {
                  playerModel.init(uniqueId, audioRef);
                  return playerModel;
                },
                child: const AccessibilityPlayer(),
              )
            : Ink(
                color: Palette.primaryColor,
                child: const FittedBox(
                  child: Text('無音樂', style: TextStyle(color: Colors.white)),
                ),
              ),
      ),
    ];
  } else {
    return [
      SizedBox(
        width: vw,
        height: vh * 0.4,
        child: FittedBox(
          fit: BoxFit.fill,
          child: (photoRef != null)
              ? FutureBuilder(
                  initialData: Image.asset('assets/loading_image.gif'),
                  future: downloadDeviceImage(uniqueId, photoRef),
                  builder: (context, snapshot) => snapshot.data as Widget,
                )
              : Image.asset('assets/no_image.png'),
        ),
      ),
      const SizedBox(height: 20.0),
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: vw * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: Constants.headline1Size,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    '$content',
                    style: const TextStyle(
                      fontSize: Constants.contentSize,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (audioRef != null) const SizedBox(height: 15.0),
              if (audioRef != null)
                ChangeNotifierProvider(
                  create: (context) {
                    playerModel.init(uniqueId, audioRef);
                    return playerModel;
                  },
                  child: const Player(),
                ),
            ],
          ),
        ),
      ),
    ];
  }
}

List<Widget> typeB({
  required double vw,
  required double vh,
  required bool accessibility,
  required String title,
  String? photoRef,
}) {
  if (accessibility) {
    return [
      Expanded(
        child: FittedBox(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      SizedBox(
        height: vh * 0.3,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.green[400],
                child: const FittedBox(
                  child: Text(
                    '苓雅一路\n號誌',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.green[600],
                child: const FittedBox(
                  child: Text(
                    '文橫二路\n號誌',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  } else {
    return [];
  }
}
