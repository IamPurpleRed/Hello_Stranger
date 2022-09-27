import 'package:flutter/material.dart';
import 'package:hello_stranger/components/player/accessibility_player.dart';
import 'package:provider/provider.dart';

import '/components/player/player.dart';
import '/components/player/player_model.dart';
import '/config/constants.dart';
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
        child: FittedBox(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      SizedBox(
        height: vh * 0.3,
        child: (audioRef != null)
            ? ChangeNotifierProvider(
                create: (context) {
                  playerModel.init(uniqueId, audioRef);
                  return playerModel;
                },
                child: const AccessibilityPlayer(),
              )
            : const SizedBox(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
