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
          return const FittedBox(
            child: Text('音檔載入中...'),
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: (model.state == PlayerState.paused)
                    ? Container(
                        color: Colors.green,
                        child: InkWell(
                          onTap: () => model.player!.play(),
                          child: const FittedBox(
                            child: Icon(Icons.play_arrow, color: Colors.white),
                          ),
                        ),
                      )
                    : Container(
                        color: Palette.primaryColor,
                        child: InkWell(
                          onTap: () => model.player!.pause(),
                          child: const FittedBox(
                            child: Icon(Icons.pause, color: Colors.white),
                          ),
                        ),
                      ),
              ),
              Expanded(
                child: Container(
                  color: Colors.purple,
                  child: InkWell(
                    onTap: () {
                      model.player!.pause();
                      model.player!.seek(Duration.zero);
                    },
                    child: const FittedBox(
                      child: Icon(Icons.stop, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
