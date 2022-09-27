import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hello_stranger/utils/local_storage_communication.dart';
import 'package:just_audio/just_audio.dart';

enum PlayerState { loading, playing, paused }

class PlayerModel extends ChangeNotifier {
  AudioPlayer? player;
  Duration total = Duration.zero;
  Duration current = Duration.zero;
  StreamSubscription<Duration>? currentStreamSub;
  PlayerState state = PlayerState.loading;
  StreamSubscription? stateStreamSub;

  Future<void> init(String uniqueId, String audioRef) async {
    player = AudioPlayer();

    try {
      File audio = await downloadDeviceAudio(uniqueId, audioRef);
      await player!.setFilePath(audio.path);
      total = player!.duration!;
    } catch (e) {}

    stateStreamSub = player!.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        state = PlayerState.loading;
      } else if (!playerState.playing) {
        state = PlayerState.paused;
      } else if (processingState != ProcessingState.completed) {
        state = PlayerState.playing;
      } else {
        player!.seek(Duration.zero);
        player!.pause();
        state = PlayerState.paused;
      }
      notifyListeners();
    });

    currentStreamSub = player!.positionStream.listen((position) {
      current = position;
      notifyListeners();
    });

    player!.play();
    notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {
    if (player != null) {
      player!.dispose();
    }
    total = Duration.zero;
    current = Duration.zero;
    currentStreamSub = null;
    state = PlayerState.loading;
    stateStreamSub = null;
  }
}
