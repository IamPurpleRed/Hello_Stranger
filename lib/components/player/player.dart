import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/components/player/player_model.dart';
import '/config/palette.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerModel>(
      builder: (context, model, child) {
        return Row(
          children: [
            if (model.state == PlayerState.loading)
              const SizedBox(
                width: 50.0,
                height: 50.0,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Palette.secondaryColor),
                ),
              ),
            if (model.state != PlayerState.loading)
              SizedBox(
                width: 50.0,
                height: 50.0,
                child: IconButton(
                  onPressed: (model.state == PlayerState.paused) ? () => model.player!.play() : () => model.player!.pause(),
                  icon: (model.state == PlayerState.paused)
                      ? const Icon(
                          Icons.play_arrow,
                          color: Palette.secondaryColor,
                        )
                      : const Icon(
                          Icons.pause,
                          color: Palette.secondaryColor,
                        ),
                  iconSize: 30.0,
                  splashRadius: 25.0,
                ),
              ),
            const SizedBox(width: 10.0),
            Expanded(
              child: ProgressBar(
                total: model.total,
                progress: model.current,
                onSeek: (value) => model.player!.seek(value),
              ),
            ),
          ],
        );
      },
    );
  }
}
