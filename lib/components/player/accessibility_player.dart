import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/components/player/player_model.dart';
import '/config/palette.dart';

class AccessibilityPlayer extends StatelessWidget {
  const AccessibilityPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerModel>(
      builder: (context, model, child) {
        if (model.state == PlayerState.loading) {
          return Ink(
            color: Palette.primaryColor,
            child: const FittedBox(
              child: Text('音檔載入中...'),
            ),
          );
        } else {
          return Ink(
            color: Palette.primaryColor,
            child: GestureDetector(
              onDoubleTap: (model.state == PlayerState.paused) ? () => model.player!.play() : () => model.player!.pause(),
              onLongPress: () {
                model.player!.pause();
                model.player!.seek(Duration.zero);
              },
              child: FittedBox(
                child: Row(
                  children: [
                    if (model.state == PlayerState.paused) const Icon(Icons.play_arrow, color: Colors.white),
                    if (model.state != PlayerState.paused) const Icon(Icons.pause, color: Colors.white),
                    const Text('/', style: TextStyle(color: Colors.white)),
                    const Icon(Icons.stop, color: Colors.white),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
